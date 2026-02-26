defmodule Cyanea.Webhooks.WebhookDelivery do
  @moduledoc """
  Schema for webhook delivery records — tracks each delivery attempt.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @valid_statuses ~w(pending success failed)

  schema "webhook_deliveries" do
    field :event, :string
    field :payload, :map
    field :response_status, :integer
    field :response_body, :string
    field :status, :string, default: "pending"
    field :attempts, :integer, default: 0
    field :completed_at, :utc_datetime
    field :inserted_at, :utc_datetime, read_after_writes: true

    belongs_to :webhook, Cyanea.Webhooks.Webhook
  end

  def changeset(delivery, attrs) do
    delivery
    |> cast(attrs, [
      :event,
      :payload,
      :response_status,
      :response_body,
      :status,
      :attempts,
      :completed_at,
      :webhook_id
    ])
    |> validate_required([:event, :payload, :webhook_id])
    |> validate_inclusion(:status, @valid_statuses)
  end
end
