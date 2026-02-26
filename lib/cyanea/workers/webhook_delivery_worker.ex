defmodule Cyanea.Workers.WebhookDeliveryWorker do
  @moduledoc """
  Oban worker for delivering webhook payloads.

  Computes an HMAC-SHA256 signature of the payload using the webhook's secret
  and sends it as a POST request with the `X-Cyanea-Signature` header.
  """
  use Oban.Worker, queue: :default, max_attempts: 5

  require Logger

  alias Cyanea.Webhooks

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"webhook_id" => webhook_id, "event" => event, "payload" => payload}}) do
    case Webhooks.get_webhook(webhook_id) do
      nil ->
        Logger.info("Webhook #{webhook_id} not found, skipping delivery")
        :ok

      %{active: false} ->
        Logger.info("Webhook #{webhook_id} is inactive, skipping delivery")
        :ok

      webhook ->
        deliver(webhook, event, payload)
    end
  end

  defp deliver(webhook, event, payload) do
    body = Jason.encode!(%{event: event, payload: payload, timestamp: DateTime.utc_now() |> DateTime.to_iso8601()})
    signature = compute_signature(body, webhook.secret)

    case Req.post(webhook.url,
           body: body,
           headers: [
             {"content-type", "application/json"},
             {"x-cyanea-signature", "sha256=#{signature}"},
             {"x-cyanea-event", event},
             {"user-agent", "Cyanea-Webhooks/1.0"}
           ],
           receive_timeout: 15_000,
           retry: false
         ) do
      {:ok, %{status: status}} when status in 200..299 ->
        Webhooks.record_delivery(webhook.id, event, payload, %{
          status: "success",
          response_status: status,
          attempts: 1,
          completed_at: DateTime.utc_now() |> DateTime.truncate(:second)
        })

        :ok

      {:ok, %{status: status, body: resp_body}} ->
        resp_body_str = if is_binary(resp_body), do: String.slice(resp_body, 0, 1000), else: inspect(resp_body)

        Webhooks.record_delivery(webhook.id, event, payload, %{
          status: "failed",
          response_status: status,
          response_body: resp_body_str,
          attempts: 1,
          completed_at: DateTime.utc_now() |> DateTime.truncate(:second)
        })

        Logger.warning("Webhook delivery to #{webhook.url} failed: HTTP #{status}")
        {:error, "HTTP #{status}"}

      {:error, reason} ->
        Webhooks.record_delivery(webhook.id, event, payload, %{
          status: "failed",
          response_body: inspect(reason),
          attempts: 1,
          completed_at: DateTime.utc_now() |> DateTime.truncate(:second)
        })

        Logger.warning("Webhook delivery to #{webhook.url} failed: #{inspect(reason)}")
        {:error, reason}
    end
  end

  defp compute_signature(body, secret) do
    :crypto.mac(:hmac, :sha256, secret, body)
    |> Base.encode16(case: :lower)
  end
end
