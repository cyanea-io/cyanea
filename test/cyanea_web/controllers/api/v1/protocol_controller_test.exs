defmodule CyaneaWeb.Api.V1.ProtocolControllerTest do
  use CyaneaWeb.ConnCase

  import Cyanea.AccountsFixtures
  import Cyanea.SpacesFixtures

  setup do
    user = user_fixture()
    space = space_fixture(owner_type: "user", owner_id: user.id, visibility: "public")

    {:ok, protocol} =
      Cyanea.Protocols.create_protocol(%{
        space_id: space.id,
        title: "Test Protocol",
        slug: "test-protocol",
        description: "A test protocol",
        version: "1.0.0"
      })

    %{user: user, space: space, protocol: protocol}
  end

  describe "GET /api/v1/spaces/:space_id/protocols" do
    test "lists protocols", %{conn: conn, space: space, protocol: protocol} do
      conn = get(conn, "/api/v1/spaces/#{space.id}/protocols")
      assert %{"data" => protocols} = json_response(conn, 200)
      assert Enum.any?(protocols, &(&1["id"] == protocol.id))
    end
  end

  describe "GET /api/v1/spaces/:space_id/protocols/:id" do
    test "returns a protocol", %{conn: conn, space: space, protocol: protocol} do
      conn = get(conn, "/api/v1/spaces/#{space.id}/protocols/#{protocol.id}")
      assert %{"data" => data} = json_response(conn, 200)
      assert data["title"] == "Test Protocol"
      assert data["version"] == "1.0.0"
    end

    test "returns 404 for wrong space", %{conn: conn, protocol: protocol} do
      other = user_fixture()
      other_space = space_fixture(owner_type: "user", owner_id: other.id, visibility: "public")
      conn = get(conn, "/api/v1/spaces/#{other_space.id}/protocols/#{protocol.id}")
      assert json_response(conn, 404)
    end
  end

  describe "POST /api/v1/spaces/:space_id/protocols" do
    test "creates a protocol", %{conn: conn, user: user, space: space} do
      conn =
        conn
        |> api_auth_conn(user)
        |> put_req_header("content-type", "application/json")
        |> post("/api/v1/spaces/#{space.id}/protocols", %{
          title: "New Protocol",
          slug: "new-protocol",
          description: "A new one"
        })

      assert %{"data" => data} = json_response(conn, 201)
      assert data["title"] == "New Protocol"
    end
  end

  describe "PATCH /api/v1/spaces/:space_id/protocols/:id" do
    test "updates a protocol", %{conn: conn, user: user, space: space, protocol: protocol} do
      conn =
        conn
        |> api_auth_conn(user)
        |> put_req_header("content-type", "application/json")
        |> patch("/api/v1/spaces/#{space.id}/protocols/#{protocol.id}", %{version: "2.0.0"})

      assert %{"data" => data} = json_response(conn, 200)
      assert data["version"] == "2.0.0"
    end
  end

  describe "DELETE /api/v1/spaces/:space_id/protocols/:id" do
    test "deletes a protocol", %{conn: conn, user: user, space: space, protocol: protocol} do
      conn =
        conn
        |> api_auth_conn(user)
        |> delete("/api/v1/spaces/#{space.id}/protocols/#{protocol.id}")

      assert %{"data" => %{"message" => "Protocol deleted"}} = json_response(conn, 200)
    end
  end
end
