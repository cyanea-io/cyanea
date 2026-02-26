defmodule Cyanea.WebhooksTest do
  use Cyanea.DataCase
  use Oban.Testing, repo: Cyanea.Repo

  alias Cyanea.Webhooks

  import Cyanea.AccountsFixtures
  import Cyanea.SpacesFixtures

  setup do
    user = user_fixture()
    space = space_fixture(owner_type: "user", owner_id: user.id, visibility: "public")
    %{user: user, space: space}
  end

  describe "create_webhook/2" do
    test "creates webhook with auto-generated secret", %{user: user} do
      {:ok, webhook} =
        Webhooks.create_webhook(user.id, %{
          url: "https://example.com/hook",
          events: ["space.created"]
        })

      assert webhook.url == "https://example.com/hook"
      assert webhook.events == ["space.created"]
      assert webhook.active == true
      assert webhook.secret != nil
      assert String.length(webhook.secret) == 64
    end

    test "rejects invalid URL", %{user: user} do
      {:error, changeset} =
        Webhooks.create_webhook(user.id, %{
          url: "not-a-url",
          events: ["space.created"]
        })

      assert %{url: _} = errors_on(changeset)
    end

    test "rejects invalid events", %{user: user} do
      {:error, changeset} =
        Webhooks.create_webhook(user.id, %{
          url: "https://example.com/hook",
          events: ["invalid.event"]
        })

      assert %{events: _} = errors_on(changeset)
    end
  end

  describe "update_webhook/2" do
    test "updates webhook fields", %{user: user} do
      {:ok, webhook} =
        Webhooks.create_webhook(user.id, %{
          url: "https://example.com/hook",
          events: ["space.created"]
        })

      {:ok, updated} = Webhooks.update_webhook(webhook, %{active: false, description: "Test"})
      assert updated.active == false
      assert updated.description == "Test"
    end

    test "cannot change secret via update", %{user: user} do
      {:ok, webhook} =
        Webhooks.create_webhook(user.id, %{
          url: "https://example.com/hook",
          events: ["space.created"]
        })

      original_secret = webhook.secret
      {:ok, updated} = Webhooks.update_webhook(webhook, %{secret: "new_secret"})
      assert updated.secret == original_secret
    end
  end

  describe "list_user_webhooks/1" do
    test "lists webhooks for a user", %{user: user} do
      {:ok, _} = Webhooks.create_webhook(user.id, %{url: "https://a.com/hook", events: ["space.created"]})
      {:ok, _} = Webhooks.create_webhook(user.id, %{url: "https://b.com/hook", events: ["space.updated"]})

      webhooks = Webhooks.list_user_webhooks(user.id)
      assert length(webhooks) == 2
    end
  end

  describe "delete_webhook/1" do
    test "deletes a webhook", %{user: user} do
      {:ok, webhook} =
        Webhooks.create_webhook(user.id, %{url: "https://example.com/hook", events: ["space.created"]})

      {:ok, _} = Webhooks.delete_webhook(webhook)
      assert Webhooks.list_user_webhooks(user.id) == []
    end
  end

  describe "dispatch_event/3" do
    test "dispatches to matching webhooks", %{user: user, space: space} do
      {:ok, _webhook} =
        Webhooks.create_webhook(user.id, %{
          url: "https://example.com/hook",
          events: ["space.created"]
        })

      assert :ok = Webhooks.dispatch_event("space.created", space, %{test: true})
      # With Oban testing: :manual, jobs are enqueued but not executed
      assert_enqueued(worker: Cyanea.Workers.WebhookDeliveryWorker)
    end

    test "skips inactive webhooks", %{user: user, space: space} do
      {:ok, webhook} =
        Webhooks.create_webhook(user.id, %{
          url: "https://example.com/hook",
          events: ["space.created"]
        })

      Webhooks.update_webhook(webhook, %{active: false})
      assert :ok = Webhooks.dispatch_event("space.created", space, %{test: true})
      refute_enqueued(worker: Cyanea.Workers.WebhookDeliveryWorker)
    end
  end

  describe "record_delivery/4" do
    test "records a delivery", %{user: user} do
      {:ok, webhook} =
        Webhooks.create_webhook(user.id, %{url: "https://example.com/hook", events: ["space.created"]})

      {:ok, delivery} =
        Webhooks.record_delivery(webhook.id, "space.created", %{test: true}, %{
          status: "success",
          response_status: 200,
          attempts: 1,
          completed_at: DateTime.utc_now() |> DateTime.truncate(:second)
        })

      assert delivery.status == "success"
      assert delivery.response_status == 200
    end
  end

  describe "list_deliveries/2" do
    test "lists deliveries for a webhook", %{user: user} do
      {:ok, webhook} =
        Webhooks.create_webhook(user.id, %{url: "https://example.com/hook", events: ["space.created"]})

      Webhooks.record_delivery(webhook.id, "space.created", %{}, %{status: "success", attempts: 1})
      Webhooks.record_delivery(webhook.id, "space.updated", %{}, %{status: "failed", attempts: 1})

      deliveries = Webhooks.list_deliveries(webhook.id)
      assert length(deliveries) == 2
    end
  end
end
