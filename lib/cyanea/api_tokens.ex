defmodule Cyanea.ApiTokens do
  @moduledoc """
  Context for managing API tokens — creation, verification, and revocation.
  """
  import Ecto.Query

  alias Cyanea.ApiTokens.ApiToken
  alias Cyanea.Repo

  @token_prefix "cyn_"
  @token_bytes 40

  @doc """
  Creates a new API token for a user.

  Returns `{:ok, api_token, raw_token}` where `raw_token` is the full token
  string shown once to the user.
  """
  def create_token(user, attrs) do
    raw_token = generate_raw_token()
    token_hash = hash_token(raw_token)
    token_prefix = String.slice(raw_token, 0, 8)

    token_attrs =
      attrs
      |> Map.merge(%{
        token_hash: token_hash,
        token_prefix: token_prefix,
        user_id: user.id
      })

    case %ApiToken{} |> ApiToken.changeset(token_attrs) |> Repo.insert() do
      {:ok, api_token} -> {:ok, api_token, raw_token}
      {:error, changeset} -> {:error, changeset}
    end
  end

  @doc """
  Verifies a raw token string. Checks hash, expiry, and revocation.
  Updates `last_used_at` on success.

  Returns `{:ok, api_token}` or `{:error, reason}`.
  """
  def verify_token(raw_token) do
    token_hash = hash_token(raw_token)

    case Repo.get_by(ApiToken, token_hash: token_hash) do
      nil ->
        {:error, :invalid_token}

      %ApiToken{revoked_at: revoked_at} when not is_nil(revoked_at) ->
        {:error, :token_revoked}

      %ApiToken{expires_at: expires_at} = token when not is_nil(expires_at) ->
        if DateTime.compare(expires_at, DateTime.utc_now()) == :lt do
          {:error, :token_expired}
        else
          touch_last_used(token)
          {:ok, Repo.preload(token, :user)}
        end

      %ApiToken{} = token ->
        touch_last_used(token)
        {:ok, Repo.preload(token, :user)}
    end
  end

  @doc """
  Lists tokens for a user. Never includes the hash or raw token.
  """
  def list_user_tokens(user_id) do
    from(t in ApiToken,
      where: t.user_id == ^user_id and is_nil(t.revoked_at),
      order_by: [desc: t.inserted_at],
      select: %{
        id: t.id,
        name: t.name,
        token_prefix: t.token_prefix,
        scopes: t.scopes,
        last_used_at: t.last_used_at,
        expires_at: t.expires_at,
        inserted_at: t.inserted_at
      }
    )
    |> Repo.all()
  end

  @doc """
  Revokes a token by setting `revoked_at`.
  """
  def revoke_token(token_id, user_id) do
    case Repo.get_by(ApiToken, id: token_id, user_id: user_id) do
      nil ->
        {:error, :not_found}

      token ->
        token
        |> Ecto.Changeset.change(revoked_at: DateTime.utc_now() |> DateTime.truncate(:second))
        |> Repo.update()
    end
  end

  @doc """
  Hard-deletes a token.
  """
  def delete_token(token_id, user_id) do
    case Repo.get_by(ApiToken, id: token_id, user_id: user_id) do
      nil -> {:error, :not_found}
      token -> Repo.delete(token)
    end
  end

  @doc """
  Checks if an API token has the required scope.
  admin implies write, write implies read.
  """
  def has_scope?(%ApiToken{scopes: scopes}, required) do
    cond do
      required in scopes -> true
      required == "read" && ("write" in scopes || "admin" in scopes) -> true
      required == "write" && "admin" in scopes -> true
      true -> false
    end
  end

  ## Private

  defp generate_raw_token do
    @token_prefix <> Base.url_encode64(:crypto.strong_rand_bytes(@token_bytes), padding: false)
  end

  defp hash_token(raw_token) do
    :crypto.hash(:sha256, raw_token) |> Base.encode16(case: :lower)
  end

  defp touch_last_used(token) do
    token
    |> Ecto.Changeset.change(last_used_at: DateTime.utc_now() |> DateTime.truncate(:second))
    |> Repo.update()
  end
end
