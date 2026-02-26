defmodule CyaneaWeb.Plugs.ApiAuth do
  @moduledoc """
  Plug that authenticates API requests via Bearer token.

  Supports two token types:
  - API keys (prefixed with `cyn_`) — verified via ApiTokens context
  - JWTs — verified via Guardian
  """
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    case get_bearer_token(conn) do
      nil ->
        assign(conn, :current_user, nil)

      "cyn_" <> _ = raw_token ->
        authenticate_api_key(conn, raw_token)

      jwt_token ->
        authenticate_jwt(conn, jwt_token)
    end
  end

  defp get_bearer_token(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] -> String.trim(token)
      _ -> nil
    end
  end

  defp authenticate_api_key(conn, raw_token) do
    case Cyanea.ApiTokens.verify_token(raw_token) do
      {:ok, api_token} ->
        conn
        |> assign(:current_user, api_token.user)
        |> assign(:api_token, api_token)

      {:error, _reason} ->
        conn
        |> put_status(:unauthorized)
        |> Phoenix.Controller.json(%{error: %{status: 401, message: "Invalid or expired API key"}})
        |> halt()
    end
  end

  defp authenticate_jwt(conn, jwt_token) do
    with {:ok, claims} <- Cyanea.Guardian.decode_and_verify(jwt_token),
         {:ok, user} <- Cyanea.Guardian.resource_from_claims(claims) do
      conn
      |> assign(:current_user, user)
      |> assign(:jwt_claims, claims)
    else
      _ ->
        conn
        |> put_status(:unauthorized)
        |> Phoenix.Controller.json(%{error: %{status: 401, message: "Invalid or expired JWT"}})
        |> halt()
    end
  end
end
