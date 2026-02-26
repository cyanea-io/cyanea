defmodule Cyanea.Blobs.Blob do
  @moduledoc """
  Blob schema — content-addressed, deduplicated file storage.

  Blobs are immutable binary objects identified by their SHA-256 hash.
  Multiple space files or dataset files can reference the same blob,
  enabling automatic deduplication.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "blobs" do
    field :sha256, :string
    field :size, :integer
    field :mime_type, :string
    field :s3_key, :string

    has_many :space_files, Cyanea.Blobs.SpaceFile
    has_many :dataset_files, Cyanea.Datasets.DatasetFile

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(blob, attrs) do
    blob
    |> cast(attrs, [:sha256, :size, :mime_type, :s3_key])
    |> validate_required([:sha256, :size, :s3_key])
    |> validate_format(:sha256, ~r/^[a-f0-9]{64}$/, message: "must be a 64-character hex string")
    |> unique_constraint(:sha256)
  end
end
