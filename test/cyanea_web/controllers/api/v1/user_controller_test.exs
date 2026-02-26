defmodule CyaneaWeb.Api.V1.UserControllerTest do
  use CyaneaWeb.ConnCase

  import Cyanea.AccountsFixtures
  import Cyanea.SpacesFixtures

  setup do
    user = user_fixture()
    space = space_fixture(owner_type: "user", owner_id: user.id, visibility: "public")
    %{user: user, space: space}
  end

  describe "GET /api/v1/user" do
    test "returns authenticated user profile", %{conn: conn, user: user} do
      conn =
        conn
        |> api_auth_conn(user)
        |> get("/api/v1/user")

      assert %{"data" => data} = json_response(conn, 200)
      assert data["id"] == user.id
      assert data["username"] == user.username
      # Ensure sensitive fields are not included
      refute Map.has_key?(data, "email")
      refute Map.has_key?(data, "password_hash")
    end

    test "returns 401 when not authenticated", %{conn: conn} do
      conn = get(conn, "/api/v1/user")
      assert json_response(conn, 401)
    end
  end

  describe "GET /api/v1/users/:username" do
    test "returns user profile", %{conn: conn, user: user} do
      conn = get(conn, "/api/v1/users/#{user.username}")
      assert %{"data" => data} = json_response(conn, 200)
      assert data["username"] == user.username
    end

    test "returns 404 for nonexistent user", %{conn: conn} do
      conn = get(conn, "/api/v1/users/nonexistentuser")
      assert json_response(conn, 404)
    end
  end

  describe "GET /api/v1/users/:username/spaces" do
    test "returns user's public spaces", %{conn: conn, user: user, space: space} do
      conn = get(conn, "/api/v1/users/#{user.username}/spaces")
      assert %{"data" => spaces} = json_response(conn, 200)
      assert Enum.any?(spaces, &(&1["id"] == space.id))
    end

    test "includes private spaces for the owner", %{conn: conn, user: user} do
      _private = space_fixture(owner_type: "user", owner_id: user.id, visibility: "private")

      conn =
        conn
        |> api_auth_conn(user)
        |> get("/api/v1/users/#{user.username}/spaces")

      assert %{"data" => spaces} = json_response(conn, 200)
      assert Enum.any?(spaces, &(&1["visibility"] == "private"))
    end
  end
end
