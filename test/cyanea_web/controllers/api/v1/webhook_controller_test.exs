defmodule CyaneaWeb.Api.V1.WebhookControllerTest do
  use CyaneaWeb.ConnCase

  import Cyanea.AccountsFixtures

  setup do
    user = user_fixture()
    %{user: user}
  end

  describe "GET /api/v1/webhooks" do
    test "lists user's webhooks", %{conn: conn, user: user} do
      Cyanea.Webhooks.create_webhook(user.id, %{
        url: "https://example.com/hook",
        events: ["space.created"]
      })

      conn =
        conn
        |> api_auth_conn(user)
        |> get("/api/v1/webhooks")

      assert %{"data" => webhooks} = json_response(conn, 200)
      assert length(webhooks) == 1
    end
  end

  describe "POST /api/v1/webhooks" do
    test "creates a webhook", %{conn: conn, user: user} do
      conn =
        conn
        |> api_auth_conn(user)
        |> put_req_header("content-type", "application/json")
        |> post("/api/v1/webhooks", %{
          url: "https://example.com/hook",
          events: ["space.created", "space.updated"],
          description: "My webhook"
        })

      assert %{"data" => data} = json_response(conn, 201)
      assert data["url"] == "https://example.com/hook"
      assert data["events"] == ["space.created", "space.updated"]
      # Secret should be returned on creation
      assert data["secret"] != nil
    end

    test "rejects invalid events", %{conn: conn, user: user} do
      conn =
        conn
        |> api_auth_conn(user)
        |> put_req_header("content-type", "application/json")
        |> post("/api/v1/webhooks", %{
          url: "https://example.com/hook",
          events: ["invalid.event"]
        })

      assert json_response(conn, 422)
    end
  end

  describe "PATCH /api/v1/webhooks/:id" do
    test "updates a webhook", %{conn: conn, user: user} do
      {:ok, webhook} =
        Cyanea.Webhooks.create_webhook(user.id, %{
          url: "https://example.com/hook",
          events: ["space.created"]
        })

      conn =
        conn
        |> api_auth_conn(user)
        |> put_req_header("content-type", "application/json")
        |> patch("/api/v1/webhooks/#{webhook.id}", %{active: false})

      assert %{"data" => data} = json_response(conn, 200)
      assert data["active"] == false
    end

    test "returns 404 for other user's webhook", %{conn: conn} do
      other_user = user_fixture()

      {:ok, webhook} =
        Cyanea.Webhooks.create_webhook(other_user.id, %{
          url: "https://example.com/hook",
          events: ["space.created"]
        })

      user = user_fixture()

      conn =
        conn
        |> api_auth_conn(user)
        |> put_req_header("content-type", "application/json")
        |> patch("/api/v1/webhooks/#{webhook.id}", %{active: false})

      assert json_response(conn, 404)
    end
  end

  describe "DELETE /api/v1/webhooks/:id" do
    test "deletes a webhook", %{conn: conn, user: user} do
      {:ok, webhook} =
        Cyanea.Webhooks.create_webhook(user.id, %{
          url: "https://example.com/hook",
          events: ["space.created"]
        })

      conn =
        conn
        |> api_auth_conn(user)
        |> delete("/api/v1/webhooks/#{webhook.id}")

      assert %{"data" => %{"message" => "Webhook deleted"}} = json_response(conn, 200)
    end
  end

  describe "GET /api/v1/webhooks/:id/deliveries" do
    test "lists deliveries", %{conn: conn, user: user} do
      {:ok, webhook} =
        Cyanea.Webhooks.create_webhook(user.id, %{
          url: "https://example.com/hook",
          events: ["space.created"]
        })

      Cyanea.Webhooks.record_delivery(webhook.id, "space.created", %{}, %{status: "success", attempts: 1})

      conn =
        conn
        |> api_auth_conn(user)
        |> get("/api/v1/webhooks/#{webhook.id}/deliveries")

      assert %{"data" => deliveries} = json_response(conn, 200)
      assert length(deliveries) == 1
    end
  end
end
