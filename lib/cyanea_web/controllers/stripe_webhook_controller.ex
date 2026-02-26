defmodule CyaneaWeb.StripeWebhookController do
  @moduledoc """
  Handles Stripe webhook events for subscription lifecycle management.

  Verifies webhook signatures using the raw request body, then dispatches
  to the appropriate Billing context function.
  """
  use CyaneaWeb, :controller

  require Logger

  alias Cyanea.Billing

  def create(conn, _params) do
    raw_body = get_raw_body(conn)
    signature = get_stripe_signature(conn)
    signing_secret = Application.get_env(:stripity_stripe, :signing_secret)

    case Stripe.Webhook.construct_event(raw_body, signature, signing_secret) do
      {:ok, %Stripe.Event{} = event} ->
        handle_event(event)
        json(conn, %{status: "ok"})

      {:error, reason} ->
        Logger.warning("Stripe webhook signature verification failed: #{inspect(reason)}")

        conn
        |> put_status(400)
        |> json(%{error: "Invalid signature"})
    end
  end

  defp handle_event(%Stripe.Event{type: "checkout.session.completed", data: %{object: session}}) do
    case Stripe.Subscription.retrieve(session.subscription) do
      {:ok, subscription} ->
        # Carry over metadata from the checkout session to the subscription
        subscription = maybe_add_metadata(subscription, session)
        Billing.upsert_subscription_from_stripe(subscription)

      {:error, error} ->
        Logger.error("Failed to retrieve subscription after checkout: #{inspect(error)}")
    end
  end

  defp handle_event(%Stripe.Event{type: "customer.subscription.updated", data: %{object: subscription}}) do
    Billing.upsert_subscription_from_stripe(subscription)
  end

  defp handle_event(%Stripe.Event{type: "customer.subscription.deleted", data: %{object: subscription}}) do
    Billing.handle_subscription_deleted(subscription)
  end

  defp handle_event(%Stripe.Event{type: "invoice.payment_failed", data: %{object: invoice}}) do
    Logger.warning("Stripe invoice payment failed: #{invoice.id}, customer: #{invoice.customer}")
  end

  defp handle_event(%Stripe.Event{type: type}) do
    Logger.debug("Unhandled Stripe event: #{type}")
  end

  defp get_raw_body(conn) do
    case conn.assigns[:raw_body] do
      chunks when is_list(chunks) -> chunks |> Enum.reverse() |> IO.iodata_to_binary()
      _ -> ""
    end
  end

  defp get_stripe_signature(conn) do
    case Plug.Conn.get_req_header(conn, "stripe-signature") do
      [sig | _] -> sig
      _ -> ""
    end
  end

  defp maybe_add_metadata(subscription, session) do
    if session.metadata && map_size(session.metadata) > 0 do
      existing = subscription.metadata || %{}
      %{subscription | metadata: Map.merge(existing, session.metadata)}
    else
      subscription
    end
  end
end
