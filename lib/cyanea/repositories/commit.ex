defmodule Cyanea.Repositories.Commit do
  @moduledoc """
  Commit schema - version control for repository content.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "commits" do
    field :sha, :string
    field :message, :string
    field :parent_sha, :string
    field :tree_sha, :string
    field :authored_at, :utc_datetime

    belongs_to :repository, Cyanea.Repositories.Repository
    belongs_to :author, Cyanea.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(commit, attrs) do
    commit
    |> cast(attrs, [:sha, :message, :parent_sha, :tree_sha, :authored_at, :repository_id, :author_id])
    |> validate_required([:sha, :message, :repository_id, :author_id])
    |> validate_length(:sha, is: 40)
    |> unique_constraint([:sha, :repository_id])
  end
end
