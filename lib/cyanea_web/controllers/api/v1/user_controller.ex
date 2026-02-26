defmodule CyaneaWeb.Api.V1.UserController do
  use CyaneaWeb, :controller

  alias Cyanea.{Accounts, Spaces}
  alias CyaneaWeb.Api.V1.ApiHelpers

  @doc "GET /api/v1/user — returns the authenticated user's profile"
  def me(conn, _params) do
    user = conn.assigns.current_user
    json(conn, %{data: ApiHelpers.serialize_user(user)})
  end

  @doc "GET /api/v1/users/:username — returns a user's public profile"
  def show(conn, %{"username" => username}) do
    case Accounts.get_user_by_username(username) do
      nil ->
        conn |> put_status(:not_found) |> json(%{error: %{status: 404, message: "User not found"}})

      user ->
        json(conn, %{data: ApiHelpers.serialize_user(user)})
    end
  end

  @doc "GET /api/v1/users/:username/spaces — returns a user's public spaces"
  def spaces(conn, %{"username" => username} = params) do
    case Accounts.get_user_by_username(username) do
      nil ->
        conn |> put_status(:not_found) |> json(%{error: %{status: 404, message: "User not found"}})

      user ->
        current_user = conn.assigns[:current_user]

        spaces =
          if current_user && current_user.id == user.id do
            Spaces.list_user_spaces(user.id)
          else
            Spaces.list_user_spaces(user.id, visibility: "public")
          end

        result = ApiHelpers.paginate(Enum.map(spaces, &ApiHelpers.serialize_space/1), params)

        json(conn, %{
          data: result.items,
          meta: %{page: result.page, per_page: result.per_page, total: result.total}
        })
    end
  end
end
