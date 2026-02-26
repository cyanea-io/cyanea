defmodule CyaneaWeb.Api.V1.NotebookControllerTest do
  use CyaneaWeb.ConnCase

  import Cyanea.AccountsFixtures
  import Cyanea.SpacesFixtures
  import Cyanea.NotebooksFixtures

  setup do
    user = user_fixture()
    space = space_fixture(owner_type: "user", owner_id: user.id, visibility: "public")
    notebook = notebook_fixture(space_id: space.id)
    %{user: user, space: space, notebook: notebook}
  end

  describe "GET /api/v1/spaces/:space_id/notebooks" do
    test "lists notebooks in a space", %{conn: conn, space: space, notebook: notebook} do
      conn = get(conn, "/api/v1/spaces/#{space.id}/notebooks")
      assert %{"data" => notebooks} = json_response(conn, 200)
      assert Enum.any?(notebooks, &(&1["id"] == notebook.id))
    end

    test "returns 404 for private space without access", %{conn: conn} do
      other_user = user_fixture()
      private_space = space_fixture(owner_type: "user", owner_id: other_user.id, visibility: "private")
      conn = get(conn, "/api/v1/spaces/#{private_space.id}/notebooks")
      assert json_response(conn, 404)
    end
  end

  describe "GET /api/v1/spaces/:space_id/notebooks/:id" do
    test "returns a notebook", %{conn: conn, space: space, notebook: notebook} do
      conn = get(conn, "/api/v1/spaces/#{space.id}/notebooks/#{notebook.id}")
      assert %{"data" => data} = json_response(conn, 200)
      assert data["id"] == notebook.id
      assert data["title"] == notebook.title
    end

    test "returns 404 for wrong space", %{conn: conn, notebook: notebook} do
      other_user = user_fixture()
      other_space = space_fixture(owner_type: "user", owner_id: other_user.id, visibility: "public")
      conn = get(conn, "/api/v1/spaces/#{other_space.id}/notebooks/#{notebook.id}")
      assert json_response(conn, 404)
    end
  end

  describe "POST /api/v1/spaces/:space_id/notebooks" do
    test "creates a notebook", %{conn: conn, user: user, space: space} do
      conn =
        conn
        |> api_auth_conn(user)
        |> put_req_header("content-type", "application/json")
        |> post("/api/v1/spaces/#{space.id}/notebooks", %{
          title: "New Notebook",
          slug: "new-notebook"
        })

      assert %{"data" => data} = json_response(conn, 201)
      assert data["title"] == "New Notebook"
      assert data["space_id"] == space.id
    end

    test "returns 403 for non-owner", %{conn: conn, space: space} do
      other_user = user_fixture()

      conn =
        conn
        |> api_auth_conn(other_user)
        |> put_req_header("content-type", "application/json")
        |> post("/api/v1/spaces/#{space.id}/notebooks", %{title: "Bad", slug: "bad"})

      assert json_response(conn, 403)
    end
  end

  describe "PATCH /api/v1/spaces/:space_id/notebooks/:id" do
    test "updates a notebook", %{conn: conn, user: user, space: space, notebook: notebook} do
      conn =
        conn
        |> api_auth_conn(user)
        |> put_req_header("content-type", "application/json")
        |> patch("/api/v1/spaces/#{space.id}/notebooks/#{notebook.id}", %{title: "Updated Title"})

      assert %{"data" => data} = json_response(conn, 200)
      assert data["title"] == "Updated Title"
    end
  end

  describe "DELETE /api/v1/spaces/:space_id/notebooks/:id" do
    test "deletes a notebook", %{conn: conn, user: user, space: space, notebook: notebook} do
      conn =
        conn
        |> api_auth_conn(user)
        |> delete("/api/v1/spaces/#{space.id}/notebooks/#{notebook.id}")

      assert %{"data" => %{"message" => "Notebook deleted"}} = json_response(conn, 200)
    end
  end

  describe "POST /api/v1/spaces/:space_id/notebooks/import" do
    test "imports a Jupyter notebook", %{conn: conn, user: user, space: space} do
      ipynb = Jason.encode!(%{
        nbformat: 4,
        metadata: %{kernelspec: %{display_name: "Python 3"}},
        cells: [
          %{cell_type: "markdown", source: ["# Test Import"]},
          %{cell_type: "code", source: ["x = 1"]}
        ]
      })

      conn =
        conn
        |> api_auth_conn(user)
        |> put_req_header("content-type", "application/json")
        |> post("/api/v1/spaces/#{space.id}/notebooks/import", %{
          ipynb: ipynb,
          slug: "imported-test"
        })

      assert %{"data" => data} = json_response(conn, 201)
      assert data["title"] == "Test Import"
      assert data["slug"] == "imported-test"
    end

    test "returns 400 for invalid ipynb", %{conn: conn, user: user, space: space} do
      conn =
        conn
        |> api_auth_conn(user)
        |> put_req_header("content-type", "application/json")
        |> post("/api/v1/spaces/#{space.id}/notebooks/import", %{ipynb: "not json"})

      assert %{"error" => %{"status" => 400}} = json_response(conn, 400)
    end
  end
end
