defmodule Cyanea.Notebooks.NotebookVersion do
  @moduledoc """
  Immutable version snapshot of a notebook's content.

  Sequential numbering per notebook, with deduplication by content hash.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "notebook_versions" do
    field :number, :integer
    field :label, :string
    field :content, :map
    field :content_hash, :string
    field :trigger, :string

    belongs_to :notebook, Cyanea.Notebooks.Notebook
    belongs_to :author, Cyanea.Accounts.User, foreign_key: :author_id

    field :created_at, :utc_datetime
  end

  @triggers ~w(manual run_all checkpoint auto)

  @doc false
  def changeset(version, attrs) do
    version
    |> cast(attrs, [:number, :label, :content, :content_hash, :trigger, :notebook_id, :author_id, :created_at])
    |> validate_required([:number, :content, :trigger, :notebook_id, :created_at])
    |> validate_inclusion(:trigger, @triggers)
    |> unique_constraint([:notebook_id, :number])
  end
end
