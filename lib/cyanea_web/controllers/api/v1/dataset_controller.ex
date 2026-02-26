defmodule CyaneaWeb.Api.V1.DatasetController do
  use CyaneaWeb, :controller

  alias Cyanea.{Datasets, Organizations, Spaces}
  alias CyaneaWeb.Api.V1.ApiHelpers

  action_fallback CyaneaWeb.Api.V1.FallbackController

  plug CyaneaWeb.Plugs.RequireScope, [scope: "write"] when action in [:create, :update, :delete]

  @doc "GET /api/v1/spaces/:space_id/datasets"
  def index(conn, %{"space_id" => space_id}) do
    with {:ok, space} <- fetch_space(space_id),
         :ok <- check_access(space, conn.assigns[:current_user]) do
      datasets = Datasets.list_space_datasets(space_id)
      json(conn, %{data: Enum.map(datasets, &ApiHelpers.serialize_dataset/1)})
    end
  end

  @doc "GET /api/v1/spaces/:space_id/datasets/:id"
  def show(conn, %{"space_id" => space_id, "id" => id}) do
    with {:ok, space} <- fetch_space(space_id),
         :ok <- check_access(space, conn.assigns[:current_user]) do
      try do
        dataset = Datasets.get_dataset!(id)

        if dataset.space_id == space_id do
          json(conn, %{data: ApiHelpers.serialize_dataset(dataset)})
        else
          conn |> put_status(:not_found) |> json(%{error: %{status: 404, message: "Dataset not found"}})
        end
      rescue
        Ecto.NoResultsError ->
          conn |> put_status(:not_found) |> json(%{error: %{status: 404, message: "Dataset not found"}})
      end
    end
  end

  @doc "POST /api/v1/spaces/:space_id/datasets"
  def create(conn, %{"space_id" => space_id} = params) do
    user = conn.assigns.current_user

    with {:ok, space} <- fetch_space(space_id),
         :ok <- authorize_write(space, user) do
      attrs = %{
        space_id: space_id,
        name: params["name"],
        slug: params["slug"],
        description: params["description"],
        storage_type: params["storage_type"] || "local",
        external_url: params["external_url"],
        metadata: params["metadata"] || %{},
        tags: params["tags"] || [],
        position: params["position"] || 0
      }

      case Datasets.create_dataset(attrs) do
        {:ok, dataset} ->
          conn |> put_status(:created) |> json(%{data: ApiHelpers.serialize_dataset(dataset)})

        {:error, changeset} ->
          conn |> put_status(:unprocessable_entity) |> json(%{error: %{status: 422, message: "Validation failed", details: ApiHelpers.format_errors(changeset)}})
      end
    end
  end

  @doc "PATCH /api/v1/spaces/:space_id/datasets/:id"
  def update(conn, %{"space_id" => space_id, "id" => id} = params) do
    user = conn.assigns.current_user

    with {:ok, space} <- fetch_space(space_id),
         :ok <- authorize_write(space, user),
         {:ok, dataset} <- fetch_dataset(id, space_id) do
      attrs =
        params
        |> Map.take(["name", "slug", "description", "storage_type", "external_url", "metadata", "tags", "position"])
        |> atomize_keys()

      case Datasets.update_dataset(dataset, attrs) do
        {:ok, dataset} ->
          json(conn, %{data: ApiHelpers.serialize_dataset(dataset)})

        {:error, changeset} ->
          conn |> put_status(:unprocessable_entity) |> json(%{error: %{status: 422, message: "Validation failed", details: ApiHelpers.format_errors(changeset)}})
      end
    end
  end

  @doc "DELETE /api/v1/spaces/:space_id/datasets/:id"
  def delete(conn, %{"space_id" => space_id, "id" => id}) do
    user = conn.assigns.current_user

    with {:ok, space} <- fetch_space(space_id),
         :ok <- authorize_write(space, user),
         {:ok, dataset} <- fetch_dataset(id, space_id),
         {:ok, _} <- Datasets.delete_dataset(dataset) do
      json(conn, %{data: %{message: "Dataset deleted"}})
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

  defp fetch_dataset(id, space_id) do
    try do
      dataset = Datasets.get_dataset!(id)
      if dataset.space_id == space_id, do: {:ok, dataset}, else: {:error, :not_found}
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
