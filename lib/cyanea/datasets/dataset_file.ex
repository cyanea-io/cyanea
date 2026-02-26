defmodule Cyanea.Datasets.DatasetFile do
  @moduledoc """
  DatasetFile schema — links a blob to a dataset at a given file path.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "dataset_files" do
    field :path, :string
    field :size, :integer

    belongs_to :dataset, Cyanea.Datasets.Dataset
    belongs_to :blob, Cyanea.Blobs.Blob

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(dataset_file, attrs) do
    dataset_file
    |> cast(attrs, [:path, :size, :dataset_id, :blob_id])
    |> validate_required([:path, :dataset_id, :blob_id])
    |> unique_constraint([:dataset_id, :path])
  end
end
