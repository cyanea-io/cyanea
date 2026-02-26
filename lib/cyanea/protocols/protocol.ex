defmodule Cyanea.Protocols.Protocol do
  @moduledoc """
  Protocol schema — versioned experimental procedures within a space.

  Content is stored as JSONB containing steps, materials, and parameters.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "protocols" do
    field :title, :string
    field :slug, :string
    field :description, :string
    field :content, :map, default: %{}
    field :version, :string, default: "1.0.0"
    field :position, :integer, default: 0

    belongs_to :space, Cyanea.Spaces.Space

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(protocol, attrs) do
    protocol
    |> cast(attrs, [:title, :slug, :description, :content, :version, :position, :space_id])
    |> validate_required([:title, :slug, :space_id])
    |> validate_format(:slug, ~r/^[a-z0-9][a-z0-9._-]*$/,
      message:
        "must start with a letter/number and contain only lowercase letters, numbers, dots, hyphens, and underscores"
    )
    |> validate_length(:slug, min: 1, max: 100)
    |> validate_length(:title, min: 1, max: 200)
    |> validate_format(:version, ~r/^\d+\.\d+\.\d+$/,
      message: "must be a semantic version (e.g. 1.0.0)"
    )
    |> unique_constraint([:space_id, :slug], error_key: :slug)
  end
end
