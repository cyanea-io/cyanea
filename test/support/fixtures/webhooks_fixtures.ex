defmodule Cyanea.WebhooksFixtures do
  @moduledoc "Test fixtures for webhooks."

  alias Cyanea.Webhooks

  def valid_webhook_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      url: "https://example.com/webhook/#{System.unique_integer([:positive])}",
      events: ["space.created", "space.updated"]
    })
  end

  def webhook_fixture(user_id, attrs \\ %{}) do
    attrs = valid_webhook_attributes(attrs)
    {:ok, webhook} = Webhooks.create_webhook(user_id, attrs)
    webhook
  end
end
