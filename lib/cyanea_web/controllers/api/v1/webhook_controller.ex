defmodule CyaneaWeb.Api.V1.WebhookController do
  use CyaneaWeb, :controller

  alias Cyanea.Webhooks
  alias CyaneaWeb.Api.V1.ApiHelpers

  action_fallback CyaneaWeb.Api.V1.FallbackController

  plug CyaneaWeb.Plugs.RequireScope, [scope: "write"] when action in [:create, :update, :delete]

  @doc "GET /api/v1/webhooks"
  def index(conn, _params) do
    user = conn.assigns.current_user
    webhooks = Webhooks.list_user_webhooks(user.id)
    json(conn, %{data: Enum.map(webhooks, &ApiHelpers.serialize_webhook/1)})
  end

  @doc "POST /api/v1/webhooks"
  def create(conn, params) do
    user = conn.assigns.current_user

    attrs = %{
      url: params["url"],
      events: params["events"] || [],
      active: Map.get(params, "active", true),
      description: params["description"],
      space_id: params["space_id"]
    }

    case Webhooks.create_webhook(user.id, attrs) do
      {:ok, webhook} ->
        # Include secret in creation response (shown once)
        data =
          ApiHelpers.serialize_webhook(webhook)
          |> Map.put(:secret, webhook.secret)

        conn |> put_status(:created) |> json(%{data: data})

      {:error, changeset} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: %{status: 422, message: "Validation failed", details: ApiHelpers.format_errors(changeset)}})
    end
  end

  @doc "PATCH /api/v1/webhooks/:id"
  def update(conn, %{"id" => id} = params) do
    user = conn.assigns.current_user

    with {:ok, webhook} <- fetch_webhook(id, user.id) do
      attrs =
        params
        |> Map.take(["url", "events", "active", "description", "space_id"])
        |> atomize_keys()

      case Webhooks.update_webhook(webhook, attrs) do
        {:ok, webhook} ->
          json(conn, %{data: ApiHelpers.serialize_webhook(webhook)})

        {:error, changeset} ->
          conn |> put_status(:unprocessable_entity) |> json(%{error: %{status: 422, message: "Validation failed", details: ApiHelpers.format_errors(changeset)}})
      end
    end
  end

  @doc "DELETE /api/v1/webhooks/:id"
  def delete(conn, %{"id" => id}) do
    user = conn.assigns.current_user

    with {:ok, webhook} <- fetch_webhook(id, user.id),
         {:ok, _} <- Webhooks.delete_webhook(webhook) do
      json(conn, %{data: %{message: "Webhook deleted"}})
    end
  end

  @doc "GET /api/v1/webhooks/:id/deliveries"
  def deliveries(conn, %{"id" => id} = params) do
    user = conn.assigns.current_user

    with {:ok, _webhook} <- fetch_webhook(id, user.id) do
      limit = ApiHelpers.parse_int(params["limit"], 50)
      deliveries = Webhooks.list_deliveries(id, limit: limit)
      json(conn, %{data: Enum.map(deliveries, &ApiHelpers.serialize_webhook_delivery/1)})
    end
  end

  ## Private

  defp fetch_webhook(id, user_id) do
    try do
      webhook = Webhooks.get_webhook!(id)

      if webhook.user_id == user_id do
        {:ok, webhook}
      else
        {:error, :not_found}
      end
    rescue
      Ecto.NoResultsError -> {:error, :not_found}
    end
  end

  defp atomize_keys(map) do
    Map.new(map, fn {k, v} -> {String.to_existing_atom(k), v} end)
  rescue
    ArgumentError -> Map.new(map, fn {k, v} -> {String.to_atom(k), v} end)
  end
end
