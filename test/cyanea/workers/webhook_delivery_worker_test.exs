defmodule Cyanea.Workers.WebhookDeliveryWorkerTest do
  use Cyanea.DataCase

  import Cyanea.AccountsFixtures

  alias Cyanea.Workers.WebhookDeliveryWorker

  setup do
    user = user_fixture()

    {:ok, webhook} =
      Cyanea.Webhooks.create_webhook(user.id, %{
        url: "https://example.com/hook",
        events: ["space.created"]
      })

    %{user: user, webhook: webhook}
  end

  describe "perform/1" do
    test "skips delivery for nonexistent webhook" do
      job = %Oban.Job{
        args: %{
          "webhook_id" => Ecto.UUID.generate(),
          "event" => "space.created",
          "payload" => %{"test" => true}
        }
      }

      assert :ok = WebhookDeliveryWorker.perform(job)
    end

    test "skips delivery for inactive webhook", %{webhook: webhook} do
      Cyanea.Webhooks.update_webhook(webhook, %{active: false})

      job = %Oban.Job{
        args: %{
          "webhook_id" => webhook.id,
          "event" => "space.created",
          "payload" => %{"test" => true}
        }
      }

      assert :ok = WebhookDeliveryWorker.perform(job)
    end

    # Note: actual HTTP delivery is not tested here since it requires
    # a running HTTP server. The delivery logic is exercised through
    # integration tests.
  end
end
