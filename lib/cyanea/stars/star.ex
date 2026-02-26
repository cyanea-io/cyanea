defmodule Cyanea.Stars.Star do
  @moduledoc """
  Star schema — user bookmarks on spaces.

  Immutable (inserted_at only, no updated_at). The unique constraint
  on (user_id, space_id) ensures a user can only star a space once.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @timestamps_opts [inserted_at: :inserted_at, updated_at: false]

  schema "stars" do
    belongs_to :user, Cyanea.Accounts.User
    belongs_to :space, Cyanea.Spaces.Space

    field :inserted_at, :utc_datetime
  end

  @doc false
  def changeset(star, attrs) do
    star
    |> cast(attrs, [:user_id, :space_id])
    |> validate_required([:user_id, :space_id])
    |> unique_constraint([:user_id, :space_id])
    |> put_inserted_at()
  end

  defp put_inserted_at(changeset) do
    if get_field(changeset, :inserted_at) do
      changeset
    else
      put_change(changeset, :inserted_at, DateTime.utc_now() |> DateTime.truncate(:second))
    end
  end
end
