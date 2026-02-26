defmodule Cyanea.Webhooks do
  @moduledoc """
  Context for managing webhooks and dispatching events.
  """
  import Ecto.Query

  alias Cyanea.Repo
  alias Cyanea.Webhooks.{Webhook, WebhookDelivery}

  @doc """
  Creates a webhook with an auto-generated HMAC signing secret.
  """
  def create_webhook(user_id, attrs) do
    secret = :crypto.strong_rand_bytes(32) |> Base.encode16(case: :lower)

    attrs =
      attrs
      |> Map.merge(%{user_id: user_id, secret: secret})

    %Webhook{}
    |> Webhook.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a webhook's mutable fields (url, events, active, description).
  Does not allow changing the secret.
  """
  def update_webhook(%Webhook{} = webhook, attrs) do
    # Prevent secret from being changed via update
    attrs = Map.drop(attrs, [:secret, "secret"])

    webhook
    |> Webhook.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a webhook and its delivery history.
  """
  def delete_webhook(%Webhook{} = webhook) do
    Repo.delete(webhook)
  end

  @doc """
  Lists webhooks for a user.
  """
  def list_user_webhooks(user_id) do
    from(w in Webhook,
      where: w.user_id == ^user_id,
      order_by: [desc: w.inserted_at]
    )
    |> Repo.all()
  end

  @doc """
  Gets a webhook by ID. Raises if not found.
  """
  def get_webhook!(id), do: Repo.get!(Webhook, id)

  @doc """
  Gets a webhook by ID, returns nil if not found.
  """
  def get_webhook(id), do: Repo.get(Webhook, id)

  @doc """
  Dispatches an event to all matching webhooks.

  Finds webhooks matching the event type that are either:
  - Scoped to the specific space, or
  - Not scoped to any space (global for the user)

  Enqueues an Oban job for each matching webhook.
  """
  def dispatch_event(event_type, %{id: space_id, owner_type: owner_type, owner_id: owner_id}, payload) do
    # Find the user_ids who own or are members of the space's owner
    user_ids = resolve_user_ids(owner_type, owner_id)

    webhooks =
      from(w in Webhook,
        where:
          w.user_id in ^user_ids and
            w.active == true and
            ^event_type in w.events and
            (is_nil(w.space_id) or w.space_id == ^space_id),
        select: w
      )
      |> Repo.all()

    Enum.each(webhooks, fn webhook ->
      %{
        webhook_id: webhook.id,
        event: event_type,
        payload: payload
      }
      |> Cyanea.Workers.WebhookDeliveryWorker.new()
      |> Oban.insert()
    end)

    :ok
  end

  defp resolve_user_ids("user", user_id), do: [user_id]

  defp resolve_user_ids("organization", org_id) do
    from(m in Cyanea.Organizations.Membership,
      where: m.organization_id == ^org_id,
      select: m.user_id
    )
    |> Repo.all()
  end

  @doc """
  Records a delivery attempt result.
  """
  def record_delivery(webhook_id, event, payload, result) do
    attrs =
      %{
        webhook_id: webhook_id,
        event: event,
        payload: payload
      }
      |> Map.merge(result)

    %WebhookDelivery{}
    |> WebhookDelivery.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Lists delivery records for a webhook, ordered by most recent.
  """
  def list_deliveries(webhook_id, opts \\ []) do
    limit = Keyword.get(opts, :limit, 50)

    from(d in WebhookDelivery,
      where: d.webhook_id == ^webhook_id,
      order_by: [desc: d.inserted_at],
      limit: ^limit
    )
    |> Repo.all()
  end
end
