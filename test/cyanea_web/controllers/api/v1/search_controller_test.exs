defmodule CyaneaWeb.Api.V1.SearchControllerTest do
  use CyaneaWeb.ConnCase

  describe "GET /api/v1/search" do
    test "returns empty results for empty query", %{conn: conn} do
      conn = get(conn, "/api/v1/search", %{q: ""})
      assert %{"data" => [], "meta" => %{"query" => ""}} = json_response(conn, 200)
    end

    test "returns results structure for a query", %{conn: conn} do
      # Search is disabled in tests, so we get empty results
      conn = get(conn, "/api/v1/search", %{q: "test", type: "spaces"})
      assert %{"data" => _data, "meta" => %{"query" => "test"}} = json_response(conn, 200)
    end

    test "defaults to spaces type", %{conn: conn} do
      conn = get(conn, "/api/v1/search", %{q: "test"})
      assert %{"meta" => %{"type" => "spaces"}} = json_response(conn, 200)
    end
  end
end
