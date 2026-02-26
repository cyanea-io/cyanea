defmodule Cyanea.Blobs.SpaceFile do
  @moduledoc """
  SpaceFile schema — links a blob to a space at a given file path.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "space_files" do
    field :path, :string
    field :name, :string

    belongs_to :space, Cyanea.Spaces.Space
    belongs_to :blob, Cyanea.Blobs.Blob

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(space_file, attrs) do
    space_file
    |> cast(attrs, [:path, :name, :space_id, :blob_id])
    |> validate_required([:path, :name, :space_id, :blob_id])
    |> unique_constraint([:space_id, :path])
  end
end
