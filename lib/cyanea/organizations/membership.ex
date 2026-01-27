defmodule Cyanea.Organizations.Membership do
  @moduledoc """
  Membership schema - links users to organizations with roles.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @roles ~w(owner admin member viewer)

  schema "memberships" do
    field :role, :string, default: "member"

    belongs_to :user, Cyanea.Accounts.User
    belongs_to :organization, Cyanea.Organizations.Organization

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(membership, attrs) do
    membership
    |> cast(attrs, [:role, :user_id, :organization_id])
    |> validate_required([:role, :user_id, :organization_id])
    |> validate_inclusion(:role, @roles)
    |> unique_constraint([:user_id, :organization_id])
  end

  def roles, do: @roles
end
