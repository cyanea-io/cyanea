defmodule Cyanea.Datasets.Dataset do
  @moduledoc """
  Dataset schema — structured data collections within a space.

  Supports local, S3, or external storage types. Files are attached
  via the DatasetFile join table.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @storage_types ~w(local s3 external)

  schema "datasets" do
    field :name, :string
    field :slug, :string
    field :description, :string
    field :storage_type, :string, default: "local"
    field :external_url, :string
    field :metadata, :map, default: %{}
    field :tags, {:array, :string}, default: []
    field :position, :integer, default: 0

    belongs_to :space, Cyanea.Spaces.Space
    has_many :dataset_files, Cyanea.Datasets.DatasetFile

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(dataset, attrs) do
    dataset
    |> cast(attrs, [
      :name,
      :slug,
      :description,
      :storage_type,
      :external_url,
      :metadata,
      :tags,
      :position,
      :space_id
    ])
    |> validate_required([:name, :slug, :space_id])
    |> validate_format(:slug, ~r/^[a-z0-9][a-z0-9._-]*$/,
      message:
        "must start with a letter/number and contain only lowercase letters, numbers, dots, hyphens, and underscores"
    )
    |> validate_length(:slug, min: 1, max: 100)
    |> validate_length(:name, min: 1, max: 200)
    |> validate_inclusion(:storage_type, @storage_types)
    |> unique_constraint([:space_id, :slug], error_key: :slug)
  end

  def storage_types, do: @storage_types
end
