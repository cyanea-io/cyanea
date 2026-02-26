defmodule Cyanea.ApiTokens.ApiToken do
  @moduledoc """
  Schema for API tokens — long-lived bearer tokens for programmatic access.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @valid_scopes ~w(read write admin)

  schema "api_tokens" do
    field :name, :string
    field :token_prefix, :string
    field :token_hash, :string
    field :scopes, {:array, :string}, default: ["read"]
    field :last_used_at, :utc_datetime
    field :expires_at, :utc_datetime
    field :revoked_at, :utc_datetime

    belongs_to :user, Cyanea.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def changeset(token, attrs) do
    token
    |> cast(attrs, [:name, :token_prefix, :token_hash, :scopes, :expires_at, :user_id])
    |> validate_required([:name, :token_prefix, :token_hash, :user_id])
    |> validate_length(:name, min: 1, max: 100)
    |> validate_scopes()
    |> unique_constraint(:token_hash)
  end

  defp validate_scopes(changeset) do
    validate_change(changeset, :scopes, fn :scopes, scopes ->
      if Enum.all?(scopes, &(&1 in @valid_scopes)) do
        []
      else
        [scopes: "must only contain valid scopes: #{Enum.join(@valid_scopes, ", ")}"]
      end
    end)
  end

  def valid_scopes, do: @valid_scopes
end
