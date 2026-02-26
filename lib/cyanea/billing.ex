defmodule Cyanea.Billing do
  @moduledoc """
  The Billing context — plan checks, Stripe integration, and storage quotas.

  Handles Pro tier enforcement, subscription lifecycle, and storage quota
  management. The subscription table is the source of truth for billing state;
  the denormalized `plan` field on User/Organization is updated atomically
  via webhook processing.
  """
  import Ecto.Query

  alias Cyanea.Accounts.User
  alias Cyanea.Billing.{StorageUsage, Subscription}
  alias Cyanea.Organizations.Organization
  alias Cyanea.Repo

  # Storage quotas in bytes
  @free_user_quota 1 * 1_073_741_824
  @free_org_quota 2 * 1_073_741_824
  @pro_user_quota 50 * 1_073_741_824
  @pro_org_quota 200 * 1_073_741_824

  # File size limits in bytes
  @free_max_file_size 50 * 1_048_576
  @pro_max_file_size 200 * 1_048_576

  # Version limits
  @free_max_versions_per_notebook 20

  # Org member limits
  @free_max_org_members 1

  # Cache staleness threshold
  @cache_ttl_seconds 300

  ## Plan Checking

  @doc """
  Returns true if the owner is on the Pro plan.
  """
  def pro?(%User{plan: "pro"}), do: true
  def pro?(%Organization{plan: "pro"}), do: true
  def pro?(_), do: false

  @doc """
  Returns the storage quota in bytes for the given owner.
  """
  def storage_quota(%User{plan: "pro"}), do: @pro_user_quota
  def storage_quota(%User{}), do: @free_user_quota
  def storage_quota(%Organization{plan: "pro"}), do: @pro_org_quota
  def storage_quota(%Organization{}), do: @free_org_quota

  @doc """
  Returns true if the owner can have private spaces.
  """
  def can_have_private_spaces?(owner), do: pro?(owner)

  @doc """
  Returns the maximum file upload size in bytes for the given owner.
  """
  def max_file_size(owner) do
    if pro?(owner), do: @pro_max_file_size, else: @free_max_file_size
  end

  @doc """
  Checks if a file of the given size is within the owner's upload limit.
  Returns `:ok` or `{:error, :file_too_large}`.
  """
  def check_file_size(owner, file_size) do
    if file_size <= max_file_size(owner) do
      :ok
    else
      {:error, :file_too_large}
    end
  end

  @doc """
  Returns the max number of versions per notebook for the given owner.
  Returns an integer or `:unlimited`.
  """
  def max_versions_per_notebook(owner) do
    if pro?(owner), do: :unlimited, else: @free_max_versions_per_notebook
  end

  @doc """
  Returns true if the owner can run server-side execution (Elixir cells).
  Free users are limited to WASM-only (client-side) execution.
  """
  def can_server_execute?(owner), do: pro?(owner)

  @doc """
  Returns the maximum org members for the given owner.
  Returns an integer or `:unlimited`.
  """
  def max_org_members(owner) do
    if pro?(owner), do: :unlimited, else: @free_max_org_members
  end

  @doc """
  Checks if adding a member to the org would exceed the member limit.
  Returns `:ok` or `{:error, :member_limit_reached}`.
  """
  def check_org_member_limit(%Organization{} = org) do
    limit = max_org_members(org)

    if limit == :unlimited do
      :ok
    else
      current_count = count_org_members(org.id)

      if current_count < limit do
        :ok
      else
        {:error, :member_limit_reached}
      end
    end
  end

  @doc """
  Returns a map of all limits for the given owner, for display in UI.
  """
  def limits_for(owner) do
    %{
      storage_quota: storage_quota(owner),
      max_file_size: max_file_size(owner),
      max_versions_per_notebook: max_versions_per_notebook(owner),
      can_server_execute: can_server_execute?(owner),
      can_have_private_spaces: can_have_private_spaces?(owner),
      max_org_members: max_org_members(owner)
    }
  end

  ## Stripe Customer Management

  @doc """
  Lazily creates a Stripe customer for the owner.
  Returns `{:ok, stripe_customer_id}`.
  """
  def ensure_stripe_customer(%User{stripe_customer_id: id}) when is_binary(id) and id != "" do
    {:ok, id}
  end

  def ensure_stripe_customer(%User{} = user) do
    case Stripe.Customer.create(%{
           email: user.email,
           name: user.name || user.username,
           metadata: %{owner_type: "user", owner_id: user.id}
         }) do
      {:ok, customer} ->
        user
        |> Ecto.Changeset.change(%{stripe_customer_id: customer.id})
        |> Repo.update()

        {:ok, customer.id}

      {:error, error} ->
        {:error, error}
    end
  end

  def ensure_stripe_customer(%Organization{stripe_customer_id: id}) when is_binary(id) and id != "" do
    {:ok, id}
  end

  def ensure_stripe_customer(%Organization{} = org) do
    case Stripe.Customer.create(%{
           name: org.name,
           metadata: %{owner_type: "organization", owner_id: org.id}
         }) do
      {:ok, customer} ->
        org
        |> Ecto.Changeset.change(%{stripe_customer_id: customer.id})
        |> Repo.update()

        {:ok, customer.id}

      {:error, error} ->
        {:error, error}
    end
  end

  ## Checkout & Portal

  @doc """
  Creates a Stripe Checkout session for upgrading to Pro.
  """
  def create_checkout_session(%User{} = user, success_url, cancel_url) do
    prices = Application.get_env(:cyanea, :stripe_prices)

    with {:ok, customer_id} <- ensure_stripe_customer(user) do
      Stripe.Checkout.Session.create(%{
        customer: customer_id,
        mode: "subscription",
        line_items: [%{price: prices[:pro_monthly_user], quantity: 1}],
        success_url: success_url,
        cancel_url: cancel_url,
        metadata: %{owner_type: "user", owner_id: user.id}
      })
    end
  end

  def create_checkout_session(%Organization{} = org, success_url, cancel_url) do
    prices = Application.get_env(:cyanea, :stripe_prices)
    member_count = count_org_members(org.id)

    with {:ok, customer_id} <- ensure_stripe_customer(org) do
      Stripe.Checkout.Session.create(%{
        customer: customer_id,
        mode: "subscription",
        line_items: [%{price: prices[:pro_monthly_org], quantity: member_count}],
        success_url: success_url,
        cancel_url: cancel_url,
        metadata: %{owner_type: "organization", owner_id: org.id}
      })
    end
  end

  @doc """
  Creates a Stripe Customer Portal session for managing billing.
  """
  def create_portal_session(%User{} = user, return_url) do
    with {:ok, customer_id} <- ensure_stripe_customer(user) do
      Stripe.BillingPortal.Session.create(%{
        customer: customer_id,
        return_url: return_url
      })
    end
  end

  def create_portal_session(%Organization{} = org, return_url) do
    with {:ok, customer_id} <- ensure_stripe_customer(org) do
      Stripe.BillingPortal.Session.create(%{
        customer: customer_id,
        return_url: return_url
      })
    end
  end

  ## Subscription Management

  @doc """
  Returns the active subscription for the given owner, if any.
  Active means status is active, trialing, or past_due.
  """
  def get_active_subscription(owner_type, owner_id) do
    from(s in Subscription,
      where:
        s.owner_type == ^owner_type and
          s.owner_id == ^owner_id and
          s.status in ~w(active trialing past_due)
    )
    |> Repo.one()
  end

  @doc """
  Idempotent upsert of a subscription from a Stripe subscription object.
  Updates both the subscription record and the owner's `plan` field atomically.
  """
  def upsert_subscription_from_stripe(%Stripe.Subscription{} = stripe_sub) do
    {owner_type, owner_id} = resolve_owner_from_stripe(stripe_sub)
    plan = if stripe_sub.status in ~w(active trialing), do: "pro", else: "free"

    sub_attrs = %{
      stripe_subscription_id: stripe_sub.id,
      stripe_price_id: extract_price_id(stripe_sub),
      status: stripe_sub.status,
      current_period_start: from_unix(stripe_sub.current_period_start),
      current_period_end: from_unix(stripe_sub.current_period_end),
      cancel_at: from_unix(stripe_sub.cancel_at),
      canceled_at: from_unix(stripe_sub.canceled_at),
      quantity: extract_quantity(stripe_sub),
      owner_type: owner_type,
      owner_id: owner_id
    }

    Ecto.Multi.new()
    |> Ecto.Multi.run(:subscription, fn repo, _changes ->
      case repo.get_by(Subscription, stripe_subscription_id: stripe_sub.id) do
        nil ->
          %Subscription{}
          |> Subscription.changeset(sub_attrs)
          |> repo.insert()

        existing ->
          existing
          |> Subscription.changeset(sub_attrs)
          |> repo.update()
      end
    end)
    |> Ecto.Multi.run(:update_plan, fn repo, _changes ->
      update_owner_plan(repo, owner_type, owner_id, plan)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{subscription: sub}} -> {:ok, sub}
      {:error, _step, reason, _changes} -> {:error, reason}
    end
  end

  @doc """
  Handles a subscription deletion from Stripe.
  Sets the subscription status to canceled and the owner plan to free.
  """
  def handle_subscription_deleted(%Stripe.Subscription{} = stripe_sub) do
    {owner_type, owner_id} = resolve_owner_from_stripe(stripe_sub)

    Ecto.Multi.new()
    |> Ecto.Multi.run(:subscription, fn repo, _changes ->
      case repo.get_by(Subscription, stripe_subscription_id: stripe_sub.id) do
        nil ->
          {:ok, nil}

        existing ->
          existing
          |> Subscription.changeset(%{status: "canceled", canceled_at: DateTime.utc_now()})
          |> repo.update()
      end
    end)
    |> Ecto.Multi.run(:update_plan, fn repo, _changes ->
      update_owner_plan(repo, owner_type, owner_id, "free")
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{subscription: sub}} -> {:ok, sub}
      {:error, _step, reason, _changes} -> {:error, reason}
    end
  end

  ## Storage Quotas

  @doc """
  Computes the actual storage used by an owner by summing blob sizes
  across space_files and dataset_files.
  """
  def compute_storage_used(owner_type, owner_id) do
    space_files_query =
      from(sf in Cyanea.Blobs.SpaceFile,
        join: s in Cyanea.Spaces.Space,
        on: sf.space_id == s.id,
        join: b in Cyanea.Blobs.Blob,
        on: sf.blob_id == b.id,
        where: s.owner_type == ^owner_type and s.owner_id == ^owner_id,
        select: coalesce(sum(b.size), 0)
      )

    dataset_files_query =
      from(df in Cyanea.Datasets.DatasetFile,
        join: d in Cyanea.Datasets.Dataset,
        on: df.dataset_id == d.id,
        join: s in Cyanea.Spaces.Space,
        on: d.space_id == s.id,
        join: b in Cyanea.Blobs.Blob,
        on: df.blob_id == b.id,
        where: s.owner_type == ^owner_type and s.owner_id == ^owner_id,
        select: coalesce(sum(b.size), 0)
      )

    space_bytes = Repo.one(space_files_query) |> to_integer()
    dataset_bytes = Repo.one(dataset_files_query) |> to_integer()

    space_bytes + dataset_bytes
  end

  @doc """
  Returns cached storage usage, recomputing if stale (>5 min).
  """
  def get_storage_used(owner_type, owner_id) do
    case Repo.one(
           from(su in StorageUsage,
             where: su.owner_type == ^owner_type and su.owner_id == ^owner_id
           )
         ) do
      nil ->
        refresh_storage_cache(owner_type, owner_id)

      %StorageUsage{bytes_used: bytes, computed_at: computed_at} ->
        if DateTime.diff(DateTime.utc_now(), computed_at) > @cache_ttl_seconds do
          refresh_storage_cache(owner_type, owner_id)
        else
          bytes
        end
    end
  end

  @doc """
  Recomputes and upserts the storage usage cache.
  """
  def refresh_storage_cache(owner_type, owner_id) do
    bytes = compute_storage_used(owner_type, owner_id)
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    %StorageUsage{}
    |> StorageUsage.changeset(%{
      owner_type: owner_type,
      owner_id: owner_id,
      bytes_used: bytes,
      computed_at: now
    })
    |> Repo.insert(
      on_conflict: [set: [bytes_used: bytes, computed_at: now, updated_at: now]],
      conflict_target: [:owner_type, :owner_id]
    )

    bytes
  end

  @doc """
  Atomically increments the cached storage usage after an upload.
  """
  def increment_storage_cache(owner_type, owner_id, delta) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    from(su in StorageUsage,
      where: su.owner_type == ^owner_type and su.owner_id == ^owner_id,
      update: [inc: [bytes_used: ^delta], set: [updated_at: ^now]]
    )
    |> Repo.update_all([])
    |> case do
      {0, _} ->
        # No cache entry yet; create one from scratch
        refresh_storage_cache(owner_type, owner_id)

      {1, _} ->
        :ok
    end
  end

  @doc """
  Checks if an upload of the given size would exceed the owner's quota.
  Returns `:ok` or `{:error, :storage_quota_exceeded}`.
  """
  def check_storage_quota(owner, upload_size) do
    {owner_type, owner_id} = owner_type_and_id(owner)
    used = get_storage_used(owner_type, owner_id)
    quota = storage_quota(owner)

    if used + upload_size <= quota do
      :ok
    else
      {:error, :storage_quota_exceeded}
    end
  end

  @doc """
  Returns storage info for display: `{bytes_used, quota, percentage}`.
  """
  def storage_info(owner) do
    {owner_type, owner_id} = owner_type_and_id(owner)
    bytes_used = get_storage_used(owner_type, owner_id)
    quota = storage_quota(owner)
    pct = if quota > 0, do: Float.round(bytes_used / quota * 100, 1), else: 0.0

    %{bytes_used: bytes_used, quota: quota, percentage: pct}
  end

  ## Helpers

  defp owner_type_and_id(%User{id: id}), do: {"user", id}
  defp owner_type_and_id(%Organization{id: id}), do: {"organization", id}

  defp resolve_owner_from_stripe(%Stripe.Subscription{} = sub) do
    metadata = sub.metadata || %{}
    owner_type = metadata["owner_type"]
    owner_id = metadata["owner_id"]

    cond do
      owner_type && owner_id ->
        {owner_type, owner_id}

      true ->
        # Fall back to looking up by customer ID
        customer_id =
          case sub.customer do
            %{id: id} -> id
            id when is_binary(id) -> id
          end

        case Repo.get_by(User, stripe_customer_id: customer_id) do
          %User{id: id} -> {"user", id}
          nil ->
            case Repo.get_by(Organization, stripe_customer_id: customer_id) do
              %Organization{id: id} -> {"organization", id}
              nil -> raise "Cannot resolve owner for Stripe customer #{customer_id}"
            end
        end
    end
  end

  defp update_owner_plan(repo, "user", owner_id, plan) do
    case repo.get(User, owner_id) do
      nil -> {:error, :user_not_found}
      user ->
        user
        |> Ecto.Changeset.change(%{plan: plan})
        |> repo.update()
    end
  end

  defp update_owner_plan(repo, "organization", owner_id, plan) do
    case repo.get(Organization, owner_id) do
      nil -> {:error, :organization_not_found}
      org ->
        org
        |> Ecto.Changeset.change(%{plan: plan})
        |> repo.update()
    end
  end

  defp extract_price_id(%Stripe.Subscription{items: %{data: [item | _]}}) do
    case item.price do
      %{id: id} -> id
      id when is_binary(id) -> id
    end
  end

  defp extract_price_id(_), do: "unknown"

  defp extract_quantity(%Stripe.Subscription{items: %{data: [item | _]}}) do
    item.quantity || 1
  end

  defp extract_quantity(_), do: 1

  defp from_unix(nil), do: nil
  defp from_unix(ts) when is_integer(ts), do: DateTime.from_unix!(ts) |> DateTime.truncate(:second)
  defp from_unix(%DateTime{} = dt), do: dt

  defp to_integer(nil), do: 0
  defp to_integer(%Decimal{} = d), do: Decimal.to_integer(d)
  defp to_integer(n) when is_integer(n), do: n

  defp count_org_members(org_id) do
    from(m in Cyanea.Organizations.Membership, where: m.organization_id == ^org_id)
    |> Repo.aggregate(:count)
    |> max(1)
  end
end
