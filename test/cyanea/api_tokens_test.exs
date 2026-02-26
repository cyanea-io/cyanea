defmodule Cyanea.ApiTokensTest do
  use Cyanea.DataCase

  alias Cyanea.ApiTokens

  import Cyanea.AccountsFixtures

  setup do
    %{user: user_fixture()}
  end

  describe "create_token/2" do
    test "creates a token with valid attributes", %{user: user} do
      {:ok, token, raw_token} = ApiTokens.create_token(user, %{name: "My Token", scopes: ["read"]})

      assert token.name == "My Token"
      assert token.scopes == ["read"]
      assert token.user_id == user.id
      assert String.starts_with?(raw_token, "cyn_")
      assert String.length(raw_token) > 10
    end

    test "rejects invalid scopes", %{user: user} do
      {:error, changeset} = ApiTokens.create_token(user, %{name: "Bad", scopes: ["invalid"]})
      assert %{scopes: _} = errors_on(changeset)
    end

    test "requires a name", %{user: user} do
      {:error, changeset} = ApiTokens.create_token(user, %{name: "", scopes: ["read"]})
      assert %{name: _} = errors_on(changeset)
    end
  end

  describe "verify_token/1" do
    test "verifies a valid token", %{user: user} do
      {:ok, _token, raw_token} = ApiTokens.create_token(user, %{name: "Test", scopes: ["read"]})
      {:ok, verified} = ApiTokens.verify_token(raw_token)
      assert verified.user.id == user.id
    end

    test "rejects invalid token" do
      assert {:error, :invalid_token} = ApiTokens.verify_token("cyn_invalid")
    end

    test "rejects revoked token", %{user: user} do
      {:ok, token, raw_token} = ApiTokens.create_token(user, %{name: "Test", scopes: ["read"]})
      {:ok, _} = ApiTokens.revoke_token(token.id, user.id)
      assert {:error, :token_revoked} = ApiTokens.verify_token(raw_token)
    end

    test "rejects expired token", %{user: user} do
      past = DateTime.utc_now() |> DateTime.add(-3600) |> DateTime.truncate(:second)

      {:ok, _token, raw_token} =
        ApiTokens.create_token(user, %{name: "Test", scopes: ["read"], expires_at: past})

      assert {:error, :token_expired} = ApiTokens.verify_token(raw_token)
    end
  end

  describe "list_user_tokens/1" do
    test "lists non-revoked tokens", %{user: user} do
      {:ok, token1, _} = ApiTokens.create_token(user, %{name: "Token 1", scopes: ["read"]})
      {:ok, _token2, _} = ApiTokens.create_token(user, %{name: "Token 2", scopes: ["write"]})
      ApiTokens.revoke_token(token1.id, user.id)

      tokens = ApiTokens.list_user_tokens(user.id)
      assert length(tokens) == 1
      assert hd(tokens).name == "Token 2"
    end
  end

  describe "has_scope?/2" do
    test "admin implies write and read", %{user: user} do
      {:ok, token, _} = ApiTokens.create_token(user, %{name: "Admin", scopes: ["admin"]})
      assert ApiTokens.has_scope?(token, "admin")
      assert ApiTokens.has_scope?(token, "write")
      assert ApiTokens.has_scope?(token, "read")
    end

    test "write implies read", %{user: user} do
      {:ok, token, _} = ApiTokens.create_token(user, %{name: "Write", scopes: ["write"]})
      assert ApiTokens.has_scope?(token, "write")
      assert ApiTokens.has_scope?(token, "read")
      refute ApiTokens.has_scope?(token, "admin")
    end

    test "read only", %{user: user} do
      {:ok, token, _} = ApiTokens.create_token(user, %{name: "Read", scopes: ["read"]})
      assert ApiTokens.has_scope?(token, "read")
      refute ApiTokens.has_scope?(token, "write")
      refute ApiTokens.has_scope?(token, "admin")
    end
  end
end
