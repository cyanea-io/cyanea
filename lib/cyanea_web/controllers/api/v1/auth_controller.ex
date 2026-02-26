defmodule CyaneaWeb.Api.V1.AuthController do
  use CyaneaWeb, :controller

  alias Cyanea.Accounts
  alias Cyanea.ApiTokens
  alias CyaneaWeb.Api.V1.ApiHelpers

  plug CyaneaWeb.Plugs.RequireScope, [scope: "write"] when action in [:create_api_key]

  @doc "POST /api/v1/auth/token — exchange email+password for a JWT"
  def create_jwt(conn, %{"email" => email, "password" => password}) do
    case Accounts.authenticate_by_email_password(email, password) do
      {:ok, user} ->
        {:ok, jwt, _claims} = Cyanea.Guardian.encode_and_sign(user, %{}, ttl: {1, :hour})

        json(conn, %{data: %{token: jwt, token_type: "Bearer", expires_in: 3600}})

      {:error, _reason} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: %{status: 401, message: "Invalid email or password"}})
    end
  end

  def create_jwt(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: %{status: 400, message: "Missing required fields: email, password"}})
  end

  @doc "POST /api/v1/auth/tokens — create a new API key"
  def create_api_key(conn, params) do
    user = conn.assigns.current_user
    name = params["name"] || "API Key"
    scopes = params["scopes"] || ["read"]
    expires_at = parse_expires_at(params["expires_at"])

    attrs = %{name: name, scopes: scopes, expires_at: expires_at}

    case ApiTokens.create_token(user, attrs) do
      {:ok, api_token, raw_token} ->
        conn
        |> put_status(:created)
        |> json(%{
          data: %{
            id: api_token.id,
            name: api_token.name,
            token: raw_token,
            token_prefix: api_token.token_prefix,
            scopes: api_token.scopes,
            expires_at: api_token.expires_at && DateTime.to_iso8601(api_token.expires_at),
            message: "Save this token — it will not be shown again."
          }
        })

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: %{status: 422, message: "Validation failed", details: ApiHelpers.format_errors(changeset)}})
    end
  end

  @doc "GET /api/v1/auth/tokens — list the user's API keys"
  def list_api_keys(conn, _params) do
    user = conn.assigns.current_user
    tokens = ApiTokens.list_user_tokens(user.id)
    json(conn, %{data: tokens})
  end

  @doc "DELETE /api/v1/auth/tokens/:id — revoke an API key"
  def revoke_api_key(conn, %{"id" => id}) do
    user = conn.assigns.current_user

    case ApiTokens.revoke_token(id, user.id) do
      {:ok, _token} ->
        json(conn, %{data: %{message: "Token revoked"}})

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: %{status: 404, message: "Token not found"}})
    end
  end

  defp parse_expires_at(nil), do: nil

  defp parse_expires_at(str) when is_binary(str) do
    case DateTime.from_iso8601(str) do
      {:ok, dt, _offset} -> DateTime.truncate(dt, :second)
      _ -> nil
    end
  end

  defp parse_expires_at(_), do: nil
end
