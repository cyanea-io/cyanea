defmodule Cyanea.Billing do
  @moduledoc """
  Billing stub for the open-source Cyanea node.
  All limits are permissive — self-hosted nodes have no artificial restrictions.
  Full Stripe billing lives in cyanea-hub (app.cyanea.bio).
  """

  @default_storage_quota 100 * 1_073_741_824
  @default_max_file_size 500 * 1_048_576

  def pro?(_), do: true
  def storage_quota(_), do: @default_storage_quota
  def can_have_private_spaces?(_), do: true
  def max_file_size(_), do: @default_max_file_size
  def check_file_size(_, _), do: :ok
  def max_versions_per_notebook(_), do: :unlimited
  def can_server_execute?(_), do: true
  def max_org_members(_), do: 1_000
  def check_org_member_limit(_), do: :ok
  def compute_credits(_), do: :unlimited
  def credit_overage_rate, do: 0
  def check_storage_quota(_, _), do: :ok
  def increment_storage_cache(_, _, _), do: :ok

  def limits_for(_) do
    %{
      storage_quota: @default_storage_quota,
      max_file_size: @default_max_file_size,
      max_versions_per_notebook: :unlimited,
      can_server_execute: true,
      can_have_private_spaces: true,
      max_org_members: 1_000,
      compute_credits: :unlimited
    }
  end

  def storage_info(_), do: %{bytes_used: 0, quota: @default_storage_quota, percentage: 0.0}

  # Stripe stubs — no-op on open-source node
  def ensure_stripe_customer(_), do: {:error, :not_available}
  def create_checkout_session(_, _, _), do: {:error, :not_available}
  def create_portal_session(_, _), do: {:error, :not_available}
  def get_active_subscription(_, _), do: nil
  def upsert_subscription_from_stripe(_), do: {:error, :not_available}
  def handle_subscription_deleted(_), do: {:error, :not_available}
  def get_storage_used(_, _), do: 0
  def refresh_storage_cache(_, _), do: 0
  def compute_storage_used(_, _), do: 0
end
