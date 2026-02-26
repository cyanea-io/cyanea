defmodule CyaneaWeb.Api.V1.ProtocolController do
  use CyaneaWeb, :controller

  alias Cyanea.{Organizations, Protocols, Spaces}
  alias CyaneaWeb.Api.V1.ApiHelpers

  action_fallback CyaneaWeb.Api.V1.FallbackController

  plug CyaneaWeb.Plugs.RequireScope, [scope: "write"] when action in [:create, :update, :delete]

  @doc "GET /api/v1/spaces/:space_id/protocols"
  def index(conn, %{"space_id" => space_id}) do
    with {:ok, space} <- fetch_space(space_id),
         :ok <- check_access(space, conn.assigns[:current_user]) do
      protocols = Protocols.list_space_protocols(space_id)
      json(conn, %{data: Enum.map(protocols, &ApiHelpers.serialize_protocol/1)})
    end
  end

  @doc "GET /api/v1/spaces/:space_id/protocols/:id"
  def show(conn, %{"space_id" => space_id, "id" => id}) do
    with {:ok, space} <- fetch_space(space_id),
         :ok <- check_access(space, conn.assigns[:current_user]) do
      try do
        protocol = Protocols.get_protocol!(id)

        if protocol.space_id == space_id do
          json(conn, %{data: ApiHelpers.serialize_protocol(protocol)})
        else
          conn |> put_status(:not_found) |> json(%{error: %{status: 404, message: "Protocol not found"}})
        end
      rescue
        Ecto.NoResultsError ->
          conn |> put_status(:not_found) |> json(%{error: %{status: 404, message: "Protocol not found"}})
      end
    end
  end

  @doc "POST /api/v1/spaces/:space_id/protocols"
  def create(conn, %{"space_id" => space_id} = params) do
    user = conn.assigns.current_user

    with {:ok, space} <- fetch_space(space_id),
         :ok <- authorize_write(space, user) do
      attrs = %{
        space_id: space_id,
        title: params["title"],
        slug: params["slug"],
        description: params["description"],
        content: params["content"] || %{},
        version: params["version"] || "1.0.0",
        position: params["position"] || 0
      }

      case Protocols.create_protocol(attrs) do
        {:ok, protocol} ->
          conn |> put_status(:created) |> json(%{data: ApiHelpers.serialize_protocol(protocol)})

        {:error, changeset} ->
          conn |> put_status(:unprocessable_entity) |> json(%{error: %{status: 422, message: "Validation failed", details: ApiHelpers.format_errors(changeset)}})
      end
    end
  end

  @doc "PATCH /api/v1/spaces/:space_id/protocols/:id"
  def update(conn, %{"space_id" => space_id, "id" => id} = params) do
    user = conn.assigns.current_user

    with {:ok, space} <- fetch_space(space_id),
         :ok <- authorize_write(space, user),
         {:ok, protocol} <- fetch_protocol(id, space_id) do
      attrs =
        params
        |> Map.take(["title", "slug", "description", "content", "version", "position"])
        |> atomize_keys()

      case Protocols.update_protocol(protocol, attrs) do
        {:ok, protocol} ->
          json(conn, %{data: ApiHelpers.serialize_protocol(protocol)})

        {:error, changeset} ->
          conn |> put_status(:unprocessable_entity) |> json(%{error: %{status: 422, message: "Validation failed", details: ApiHelpers.format_errors(changeset)}})
      end
    end
  end

  @doc "DELETE /api/v1/spaces/:space_id/protocols/:id"
  def delete(conn, %{"space_id" => space_id, "id" => id}) do
    user = conn.assigns.current_user

    with {:ok, space} <- fetch_space(space_id),
         :ok <- authorize_write(space, user),
         {:ok, protocol} <- fetch_protocol(id, space_id),
         {:ok, _} <- Protocols.delete_protocol(protocol) do
      json(conn, %{data: %{message: "Protocol deleted"}})
    end
  end

  ## Private

  defp fetch_space(id) do
    try do
      {:ok, Spaces.get_space!(id)}
    rescue
      Ecto.NoResultsError -> {:error, :not_found}
    end
  end

  defp fetch_protocol(id, space_id) do
    try do
      protocol = Protocols.get_protocol!(id)
      if protocol.space_id == space_id, do: {:ok, protocol}, else: {:error, :not_found}
    rescue
      Ecto.NoResultsError -> {:error, :not_found}
    end
  end

  defp check_access(space, user) do
    if Spaces.can_access?(space, user), do: :ok, else: {:error, :not_found}
  end

  defp authorize_write(space, user) do
    cond do
      Spaces.owner?(space, user) -> :ok
      space.owner_type == "organization" ->
        case Organizations.authorize(user.id, space.owner_id, "admin") do
          {:ok, _} -> :ok
          _ -> {:error, :forbidden}
        end
      true -> {:error, :forbidden}
    end
  end

  defp atomize_keys(map) do
    Map.new(map, fn {k, v} -> {String.to_existing_atom(k), v} end)
  rescue
    ArgumentError -> Map.new(map, fn {k, v} -> {String.to_atom(k), v} end)
  end
end
