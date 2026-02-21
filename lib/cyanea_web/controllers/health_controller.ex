defmodule CyaneaWeb.HealthController do
  use CyaneaWeb, :controller

  def live(conn, _params) do
    json(conn, %{status: "ok"})
  end

  def ready(conn, _params) do
    case Ecto.Adapters.SQL.query(Cyanea.Repo, "SELECT 1") do
      {:ok, _} ->
        json(conn, %{status: "ok"})

      {:error, reason} ->
        conn
        |> put_status(:service_unavailable)
        |> json(%{status: "error", reason: inspect(reason)})
    end
  end
end
