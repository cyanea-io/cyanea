defmodule CyaneaWeb.Api.V1.OrganizationControllerTest do
  use CyaneaWeb.ConnCase

  import Cyanea.AccountsFixtures
  import Cyanea.SpacesFixtures

  setup do
    user = user_fixture()
    {:ok, org} = Cyanea.Organizations.create_organization(%{name: "Test Org", slug: "test-org"}, user.id)
    space = space_fixture(owner_type: "organization", owner_id: org.id, visibility: "public")
    %{user: user, org: org, space: space}
  end

  describe "GET /api/v1/orgs/:slug" do
    test "returns organization", %{conn: conn, org: org} do
      conn = get(conn, "/api/v1/orgs/#{org.slug}")
      assert %{"data" => data} = json_response(conn, 200)
      assert data["slug"] == org.slug
      assert data["name"] == org.name
    end

    test "returns 404 for nonexistent org", %{conn: conn} do
      conn = get(conn, "/api/v1/orgs/nonexistent")
      assert json_response(conn, 404)
    end
  end

  describe "GET /api/v1/orgs/:slug/spaces" do
    test "returns org's public spaces", %{conn: conn, org: org, space: space} do
      conn = get(conn, "/api/v1/orgs/#{org.slug}/spaces")
      assert %{"data" => spaces} = json_response(conn, 200)
      assert Enum.any?(spaces, &(&1["id"] == space.id))
    end
  end

  describe "GET /api/v1/orgs/:slug/members" do
    test "returns org members", %{conn: conn, org: org, user: user} do
      conn = get(conn, "/api/v1/orgs/#{org.slug}/members")
      assert %{"data" => members} = json_response(conn, 200)
      assert length(members) >= 1
      assert Enum.any?(members, fn m -> m["user"]["id"] == user.id end)
    end
  end
end
