defmodule CyaneaWeb.Api.V1.NotebookController do
  use CyaneaWeb, :controller

  alias Cyanea.{Notebooks, Organizations, Spaces}
  alias Cyanea.Notebooks.JupyterImport
  alias CyaneaWeb.Api.V1.ApiHelpers

  action_fallback CyaneaWeb.Api.V1.FallbackController

  plug CyaneaWeb.Plugs.RequireScope,
       [scope: "write"] when action in [:create, :update, :delete, :import_jupyter]

  @doc "GET /api/v1/spaces/:space_id/notebooks"
  def index(conn, %{"space_id" => space_id}) do
    with {:ok, space} <- fetch_space(space_id),
         :ok <- check_access(space, conn.assigns[:current_user]) do
      notebooks = Notebooks.list_space_notebooks(space_id)
      json(conn, %{data: Enum.map(notebooks, &ApiHelpers.serialize_notebook/1)})
    end
  end

  @doc "GET /api/v1/spaces/:space_id/notebooks/:id"
  def show(conn, %{"space_id" => space_id, "id" => id}) do
    with {:ok, space} <- fetch_space(space_id),
         :ok <- check_access(space, conn.assigns[:current_user]) do
      try do
        notebook = Notebooks.get_notebook!(id)

        if notebook.space_id == space_id do
          json(conn, %{data: ApiHelpers.serialize_notebook(notebook)})
        else
          conn |> put_status(:not_found) |> json(%{error: %{status: 404, message: "Notebook not found"}})
        end
      rescue
        Ecto.NoResultsError ->
          conn |> put_status(:not_found) |> json(%{error: %{status: 404, message: "Notebook not found"}})
      end
    end
  end

  @doc "POST /api/v1/spaces/:space_id/notebooks"
  def create(conn, %{"space_id" => space_id} = params) do
    user = conn.assigns.current_user

    with {:ok, space} <- fetch_space(space_id),
         :ok <- authorize_write(space, user) do
      attrs = %{
        space_id: space_id,
        title: params["title"],
        slug: params["slug"],
        content: params["content"] || %{},
        position: params["position"] || 0
      }

      case Notebooks.create_notebook(attrs) do
        {:ok, notebook} ->
          conn |> put_status(:created) |> json(%{data: ApiHelpers.serialize_notebook(notebook)})

        {:error, changeset} ->
          conn |> put_status(:unprocessable_entity) |> json(%{error: %{status: 422, message: "Validation failed", details: ApiHelpers.format_errors(changeset)}})
      end
    end
  end

  @doc "PATCH /api/v1/spaces/:space_id/notebooks/:id"
  def update(conn, %{"space_id" => space_id, "id" => id} = params) do
    user = conn.assigns.current_user

    with {:ok, space} <- fetch_space(space_id),
         :ok <- authorize_write(space, user),
         {:ok, notebook} <- fetch_notebook(id, space_id) do
      attrs =
        params
        |> Map.take(["title", "slug", "content", "position"])
        |> atomize_keys()

      case Notebooks.update_notebook(notebook, attrs) do
        {:ok, notebook} ->
          json(conn, %{data: ApiHelpers.serialize_notebook(notebook)})

        {:error, changeset} ->
          conn |> put_status(:unprocessable_entity) |> json(%{error: %{status: 422, message: "Validation failed", details: ApiHelpers.format_errors(changeset)}})
      end
    end
  end

  @doc "DELETE /api/v1/spaces/:space_id/notebooks/:id"
  def delete(conn, %{"space_id" => space_id, "id" => id}) do
    user = conn.assigns.current_user

    with {:ok, space} <- fetch_space(space_id),
         :ok <- authorize_write(space, user),
         {:ok, notebook} <- fetch_notebook(id, space_id),
         {:ok, _} <- Notebooks.delete_notebook(notebook) do
      json(conn, %{data: %{message: "Notebook deleted"}})
    end
  end

  @doc "POST /api/v1/spaces/:space_id/notebooks/import"
  def import_jupyter(conn, %{"space_id" => space_id} = params) do
    user = conn.assigns.current_user

    with {:ok, space} <- fetch_space(space_id),
         :ok <- authorize_write(space, user) do
      ipynb_json = params["ipynb"] || params["content"]

      case JupyterImport.parse(ipynb_json) do
        {:ok, %{title: title, content: content}} ->
          slug = params["slug"] || slugify(title)

          attrs = %{
            space_id: space_id,
            title: params["title"] || title,
            slug: slug,
            content: content
          }

          case Notebooks.create_notebook(attrs) do
            {:ok, notebook} ->
              conn |> put_status(:created) |> json(%{data: ApiHelpers.serialize_notebook(notebook)})

            {:error, changeset} ->
              conn |> put_status(:unprocessable_entity) |> json(%{error: %{status: 422, message: "Validation failed", details: ApiHelpers.format_errors(changeset)}})
          end

        {:error, reason} ->
          message = if is_binary(reason), do: reason, else: inspect(reason)
          conn |> put_status(:bad_request) |> json(%{error: %{status: 400, message: "Import failed: #{message}"}})
      end
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

  defp fetch_notebook(id, space_id) do
    try do
      notebook = Notebooks.get_notebook!(id)
      if notebook.space_id == space_id, do: {:ok, notebook}, else: {:error, :not_found}
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

  defp slugify(title) do
    title
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9\s-]/, "")
    |> String.replace(~r/\s+/, "-")
    |> String.trim("-")
    |> String.slice(0, 100)
    |> case do
      "" -> "imported-notebook"
      slug -> slug
    end
  end

  defp atomize_keys(map) do
    Map.new(map, fn {k, v} -> {String.to_existing_atom(k), v} end)
  rescue
    ArgumentError -> Map.new(map, fn {k, v} -> {String.to_atom(k), v} end)
  end
end
