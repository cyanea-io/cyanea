defmodule CyaneaWeb.Plugs.ApiAuthTest do
  use CyaneaWeb.ConnCase

  import Cyanea.AccountsFixtures

  alias CyaneaWeb.Plugs.ApiAuth

  setup do
    %{user: user_fixture()}
  end

  describe "API key authentication" do
    test "authenticates with valid API key", %{conn: conn, user: user} do
      {:ok, _token, raw_token} =
        Cyanea.ApiTokens.create_token(user, %{name: "Test", scopes: ["read"]})

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{raw_token}")
        |> ApiAuth.call([])

      assert conn.assigns.current_user.id == user.id
      assert conn.assigns.api_token != nil
    end

    test "rejects invalid API key", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer cyn_invalid_token")
        |> ApiAuth.call([])

      assert conn.halted
      assert conn.status == 401
    end
  end

  describe "JWT authentication" do
    test "authenticates with valid JWT", %{conn: conn, user: user} do
      {:ok, jwt, _claims} = Cyanea.Guardian.encode_and_sign(user)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{jwt}")
        |> ApiAuth.call([])

      assert conn.assigns.current_user.id == user.id
      assert conn.assigns[:jwt_claims] != nil
    end

    test "rejects invalid JWT", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer invalid.jwt.token")
        |> ApiAuth.call([])

      assert conn.halted
      assert conn.status == 401
    end
  end

  describe "no authentication" do
    test "assigns nil current_user when no auth header", %{conn: conn} do
      conn = ApiAuth.call(conn, [])
      assert conn.assigns.current_user == nil
      refute conn.halted
    end
  end
end
