defmodule Cyanea.Billing.StorageUsage do
  @moduledoc """
  StorageUsage schema — cached storage usage per owner.

  Periodically recomputed by the StorageRecalcWorker and
  incrementally updated on file upload/deletion.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "storage_usage" do
    field :owner_type, :string
    field :owner_id, :binary_id
    field :bytes_used, :integer, default: 0
    field :computed_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(storage_usage, attrs) do
    storage_usage
    |> cast(attrs, [:owner_type, :owner_id, :bytes_used, :computed_at])
    |> validate_required([:owner_type, :owner_id, :bytes_used, :computed_at])
    |> validate_inclusion(:owner_type, ~w(user organization))
    |> unique_constraint([:owner_type, :owner_id])
  end
end
