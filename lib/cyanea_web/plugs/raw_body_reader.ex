defmodule CyaneaWeb.Plugs.RawBodyReader do
  @moduledoc """
  Caches the raw request body for Stripe webhook signature verification.

  Stripe requires the raw body (before JSON parsing) to verify the webhook
  signature. This module is used as the `body_reader` option in Plug.Parsers.
  """

  def read_body(conn, opts) do
    case Plug.Conn.read_body(conn, opts) do
      {:ok, body, conn} ->
        conn = update_in(conn.assigns[:raw_body], &[body | &1 || []])
        {:ok, body, conn}

      {:more, body, conn} ->
        conn = update_in(conn.assigns[:raw_body], &[body | &1 || []])
        {:more, body, conn}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
