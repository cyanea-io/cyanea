defmodule CyaneaWeb.Api.V1.FallbackController do
  @moduledoc """
  Handles error tuples returned from `with` chains in API v1 controllers.
  """
  use CyaneaWeb, :controller

  alias CyaneaWeb.Api.V1.ApiHelpers

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> json(%{error: %{status: 404, message: "Not found"}})
  end

  def call(conn, {:error, :forbidden}) do
    conn
    |> put_status(:forbidden)
    |> json(%{error: %{status: 403, message: "Not authorized"}})
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:forbidden)
    |> json(%{error: %{status: 403, message: "Not authorized"}})
  end

  def call(conn, {:error, :pro_required}) do
    conn
    |> put_status(:forbidden)
    |> json(%{error: %{status: 403, message: "Pro plan required"}})
  end

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{error: %{status: 422, message: "Validation failed", details: ApiHelpers.format_errors(changeset)}})
  end
end
