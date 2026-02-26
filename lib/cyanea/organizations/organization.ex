defmodule Cyanea.Organizations.Organization do
  @moduledoc """
  Organization schema - labs, institutions, teams.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "organizations" do
    field :name, :string
    field :slug, :string
    field :description, :string
    field :avatar_url, :string
    field :website, :string
    field :location, :string
    field :verified, :boolean, default: false
    field :plan, :string, default: "free"
    field :stripe_customer_id, :string

    has_many :memberships, Cyanea.Organizations.Membership
    has_many :members, through: [:memberships, :user]
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(organization, attrs) do
    organization
    |> cast(attrs, [:name, :slug, :description, :avatar_url, :website, :location])
    |> validate_required([:name, :slug])
    |> validate_format(:slug, ~r/^[a-z0-9][a-z0-9-]*$/, message: "must start with a letter/number and contain only lowercase letters, numbers, and hyphens")
    |> validate_length(:slug, min: 2, max: 39)
    |> validate_length(:name, min: 1, max: 100)
    |> unique_constraint(:slug)
  end
end
