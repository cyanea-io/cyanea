defmodule Cyanea.Files.File do
  @moduledoc """
  File schema - tracks files within repositories.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @file_types ~w(file directory)

  schema "files" do
    field :path, :string
    field :name, :string
    field :type, :string, default: "file"
    field :size, :integer
    field :sha256, :string
    field :mime_type, :string
    field :s3_key, :string

    # For life science specific metadata
    field :metadata, :map, default: %{}

    belongs_to :repository, Cyanea.Repositories.Repository
    belongs_to :commit, Cyanea.Repositories.Commit

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(file, attrs) do
    file
    |> cast(attrs, [:path, :name, :type, :size, :sha256, :mime_type, :s3_key, :metadata, :repository_id, :commit_id])
    |> validate_required([:path, :name, :type, :repository_id])
    |> validate_inclusion(:type, @file_types)
    |> unique_constraint([:path, :commit_id])
  end

  def file_types, do: @file_types
end
