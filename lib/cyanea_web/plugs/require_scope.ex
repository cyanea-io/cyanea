defmodule CyaneaWeb.Plugs.RequireScope do
  @moduledoc """
  Plug that checks if the current API token has the required scope.
  JWT-authenticated users are granted all scopes.

  Usage: `plug RequireScope, scope: "write"`
  """
  import Plug.Conn

  def init(opts), do: opts

  def call(%{assigns: %{jwt_claims: _}} = conn, _opts) do
    # JWT users get all scopes
    conn
  end

  def call(%{assigns: %{api_token: api_token}} = conn, opts) do
    required = Keyword.fetch!(opts, :scope)

    if Cyanea.ApiTokens.has_scope?(api_token, required) do
      conn
    else
      conn
      |> put_status(:forbidden)
      |> Phoenix.Controller.json(%{
        error: %{status: 403, message: "Insufficient scope. Required: #{required}"}
      })
      |> halt()
    end
  end

  def call(conn, _opts), do: conn
end
