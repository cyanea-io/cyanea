defmodule CyaneaWeb.Plugs.RequireApiAuth do
  @moduledoc """
  Plug that halts with 401 if no authenticated user is present.
  """
  import Plug.Conn

  def init(opts), do: opts

  def call(%{assigns: %{current_user: %{id: _}}} = conn, _opts), do: conn

  def call(conn, _opts) do
    conn
    |> put_status(:unauthorized)
    |> Phoenix.Controller.json(%{error: %{status: 401, message: "Authentication required"}})
    |> halt()
  end
end
