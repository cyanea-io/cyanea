defmodule Cyanea.Accounts.User do
  @moduledoc """
  User schema for authentication and profile.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "users" do
    field :email, :string
    field :username, :string
    field :name, :string
    field :password_hash, :string
    field :password, :string, virtual: true
    field :orcid_id, :string
    field :avatar_url, :string
    field :bio, :string
    field :affiliation, :string
    field :confirmed_at, :utc_datetime
    field :plan, :string, default: "free"
    field :stripe_customer_id, :string

    has_many :memberships, Cyanea.Organizations.Membership
    has_many :organizations, through: [:memberships, :organization]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :username, :name, :password, :orcid_id, :avatar_url, :bio, :affiliation])
    |> validate_required([:email, :username])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> validate_format(:username, ~r/^[a-z0-9][a-z0-9_-]*$/, message: "must start with a letter/number and contain only lowercase letters, numbers, hyphens, and underscores")
    |> validate_length(:username, min: 2, max: 39)
    |> validate_length(:password, min: 8, max: 72)
    |> unique_constraint(:email)
    |> unique_constraint(:username)
    |> unique_constraint(:orcid_id)
    |> hash_password()
  end

  @doc false
  def oauth_changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :username, :name, :orcid_id, :avatar_url])
    |> validate_required([:email, :orcid_id])
    |> unique_constraint(:email)
    |> unique_constraint(:username)
    |> unique_constraint(:orcid_id)
  end

  defp hash_password(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, password_hash: Bcrypt.hash_pwd_salt(password))
  end

  defp hash_password(changeset), do: changeset
end
