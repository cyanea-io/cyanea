defmodule CyaneaWeb.Api.V1.DatasetControllerTest do
  use CyaneaWeb.ConnCase

  import Cyanea.AccountsFixtures
  import Cyanea.SpacesFixtures

  setup do
    user = user_fixture()
    space = space_fixture(owner_type: "user", owner_id: user.id, visibility: "public")

    {:ok, dataset} =
      Cyanea.Datasets.create_dataset(%{
        space_id: space.id,
        name: "Test Dataset",
        slug: "test-dataset",
        description: "A test dataset"
      })

    %{user: user, space: space, dataset: dataset}
  end

  describe "GET /api/v1/spaces/:space_id/datasets" do
    test "lists datasets", %{conn: conn, space: space, dataset: dataset} do
      conn = get(conn, "/api/v1/spaces/#{space.id}/datasets")
      assert %{"data" => datasets} = json_response(conn, 200)
      assert Enum.any?(datasets, &(&1["id"] == dataset.id))
    end
  end

  describe "GET /api/v1/spaces/:space_id/datasets/:id" do
    test "returns a dataset", %{conn: conn, space: space, dataset: dataset} do
      conn = get(conn, "/api/v1/spaces/#{space.id}/datasets/#{dataset.id}")
      assert %{"data" => data} = json_response(conn, 200)
      assert data["name"] == "Test Dataset"
    end
  end

  describe "POST /api/v1/spaces/:space_id/datasets" do
    test "creates a dataset", %{conn: conn, user: user, space: space} do
      conn =
        conn
        |> api_auth_conn(user)
        |> put_req_header("content-type", "application/json")
        |> post("/api/v1/spaces/#{space.id}/datasets", %{
          name: "New Dataset",
          slug: "new-dataset"
        })

      assert %{"data" => data} = json_response(conn, 201)
      assert data["name"] == "New Dataset"
    end
  end

  describe "PATCH /api/v1/spaces/:space_id/datasets/:id" do
    test "updates a dataset", %{conn: conn, user: user, space: space, dataset: dataset} do
      conn =
        conn
        |> api_auth_conn(user)
        |> put_req_header("content-type", "application/json")
        |> patch("/api/v1/spaces/#{space.id}/datasets/#{dataset.id}", %{description: "Updated"})

      assert %{"data" => data} = json_response(conn, 200)
      assert data["description"] == "Updated"
    end
  end

  describe "DELETE /api/v1/spaces/:space_id/datasets/:id" do
    test "deletes a dataset", %{conn: conn, user: user, space: space, dataset: dataset} do
      conn =
        conn
        |> api_auth_conn(user)
        |> delete("/api/v1/spaces/#{space.id}/datasets/#{dataset.id}")

      assert %{"data" => %{"message" => "Dataset deleted"}} = json_response(conn, 200)
    end
  end
end
