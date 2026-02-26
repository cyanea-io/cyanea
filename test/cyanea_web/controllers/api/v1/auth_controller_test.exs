defmodule CyaneaWeb.Api.V1.AuthControllerTest do
  use CyaneaWeb.ConnCase

  import Cyanea.AccountsFixtures

  setup do
    user = user_fixture()
    %{user: user}
  end

  describe "POST /api/v1/auth/token" do
    test "returns JWT for valid credentials", %{conn: conn, user: user} do
      conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> post("/api/v1/auth/token", %{email: user.email, password: valid_user_password()})

      assert %{"data" => %{"token" => token, "token_type" => "Bearer"}} = json_response(conn, 200)
      assert is_binary(token)
    end

    test "returns 401 for invalid credentials", %{conn: conn, user: user} do
      conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> post("/api/v1/auth/token", %{email: user.email, password: "wrongpassword"})

      assert %{"error" => %{"status" => 401}} = json_response(conn, 401)
    end

    test "returns 400 for missing fields", %{conn: conn} do
      conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> post("/api/v1/auth/token", %{})

      assert %{"error" => %{"status" => 400}} = json_response(conn, 400)
    end
  end

  describe "POST /api/v1/auth/tokens" do
    test "creates API key when authenticated", %{conn: conn, user: user} do
      conn =
        conn
        |> jwt_auth_conn(user)
        |> put_req_header("content-type", "application/json")
        |> post("/api/v1/auth/tokens", %{name: "My Key", scopes: ["read", "write"]})

      assert %{"data" => data} = json_response(conn, 201)
      assert data["name"] == "My Key"
      assert String.starts_with?(data["token"], "cyn_")
    end

    test "returns 401 when not authenticated", %{conn: conn} do
      conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> post("/api/v1/auth/tokens", %{name: "My Key"})

      assert json_response(conn, 401)
    end
  end

  describe "GET /api/v1/auth/tokens" do
    test "lists API keys", %{conn: conn, user: user} do
      # Create a token first
      Cyanea.ApiTokens.create_token(user, %{name: "Token 1", scopes: ["read"]})

      conn =
        conn
        |> jwt_auth_conn(user)
        |> get("/api/v1/auth/tokens")

      assert %{"data" => tokens} = json_response(conn, 200)
      assert length(tokens) >= 1
    end
  end

  describe "DELETE /api/v1/auth/tokens/:id" do
    test "revokes an API key", %{conn: conn, user: user} do
      {:ok, token, _raw} = Cyanea.ApiTokens.create_token(user, %{name: "To Revoke", scopes: ["read"]})

      conn =
        conn
        |> jwt_auth_conn(user)
        |> delete("/api/v1/auth/tokens/#{token.id}")

      assert %{"data" => %{"message" => "Token revoked"}} = json_response(conn, 200)
    end

    test "returns 404 for nonexistent token", %{conn: conn, user: user} do
      conn =
        conn
        |> jwt_auth_conn(user)
        |> delete("/api/v1/auth/tokens/#{Ecto.UUID.generate()}")

      assert %{"error" => %{"status" => 404}} = json_response(conn, 404)
    end
  end
end
