defmodule Cyanea.Revisions.Revision do
  @moduledoc """
  Revision schema — immutable, sequential snapshots of a space.

  Revisions form an append-only history. Each revision has a sequential
  number within its space and an optional parent revision for branching.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @timestamps_opts [inserted_at: false, updated_at: false]

  schema "revisions" do
    field :number, :integer
    field :summary, :string
    field :content_hash, :string
    field :created_at, :utc_datetime

    belongs_to :space, Cyanea.Spaces.Space
    belongs_to :parent_revision, __MODULE__
    belongs_to :author, Cyanea.Accounts.User
  end

  @doc false
  def changeset(revision, attrs) do
    revision
    |> cast(attrs, [:number, :summary, :content_hash, :space_id, :parent_revision_id, :author_id])
    |> validate_required([:number, :space_id, :author_id])
    |> unique_constraint([:space_id, :number])
    |> put_created_at()
  end

  defp put_created_at(changeset) do
    if get_field(changeset, :created_at) do
      changeset
    else
      put_change(changeset, :created_at, DateTime.utc_now() |> DateTime.truncate(:second))
    end
  end
end
