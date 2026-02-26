defmodule Cyanea.Billing.Subscription do
  @moduledoc """
  Subscription schema — tracks Stripe subscription state.

  The subscription is authoritative; the denormalized `plan` field
  on User/Organization is updated transactionally via webhook processing.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "subscriptions" do
    field :stripe_subscription_id, :string
    field :stripe_price_id, :string
    field :status, :string
    field :current_period_start, :utc_datetime
    field :current_period_end, :utc_datetime
    field :cancel_at, :utc_datetime
    field :canceled_at, :utc_datetime
    field :quantity, :integer, default: 1
    field :owner_type, :string
    field :owner_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [
      :stripe_subscription_id,
      :stripe_price_id,
      :status,
      :current_period_start,
      :current_period_end,
      :cancel_at,
      :canceled_at,
      :quantity,
      :owner_type,
      :owner_id
    ])
    |> validate_required([:stripe_subscription_id, :stripe_price_id, :status, :owner_type, :owner_id])
    |> validate_inclusion(:status, ~w(active trialing past_due canceled unpaid incomplete incomplete_expired paused))
    |> validate_inclusion(:owner_type, ~w(user organization))
    |> unique_constraint(:stripe_subscription_id)
  end
end
