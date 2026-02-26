defmodule Cyanea.Notebooks.Notebook do
  @moduledoc """
  Notebook schema — computational notebooks within a space.

  Content is stored as JSONB containing cells (code, markdown, output).
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "notebooks" do
    field :title, :string
    field :slug, :string
    field :content, :map, default: %{}
    field :position, :integer, default: 0

    belongs_to :space, Cyanea.Spaces.Space

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(notebook, attrs) do
    notebook
    |> cast(attrs, [:title, :slug, :content, :position, :space_id])
    |> validate_required([:title, :slug, :space_id])
    |> validate_format(:slug, ~r/^[a-z0-9][a-z0-9._-]*$/,
      message:
        "must start with a letter/number and contain only lowercase letters, numbers, dots, hyphens, and underscores"
    )
    |> validate_length(:slug, min: 1, max: 100)
    |> validate_length(:title, min: 1, max: 200)
    |> unique_constraint([:space_id, :slug], error_key: :slug)
  end
end
