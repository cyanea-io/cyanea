defmodule CyaneaWeb.Api.V1.SearchController do
  use CyaneaWeb, :controller

  alias Cyanea.Search
  alias CyaneaWeb.Api.V1.ApiHelpers

  @doc "GET /api/v1/search?q=query&type=spaces|users&limit=20"
  def search(conn, params) do
    query = params["q"] || ""
    type = params["type"] || "spaces"
    limit = ApiHelpers.parse_int(params["limit"], 20) |> min(100)

    if query == "" do
      json(conn, %{data: [], meta: %{query: query, type: type}})
    else
      results = do_search(type, query, limit)
      json(conn, %{data: results, meta: %{query: query, type: type}})
    end
  end

  defp do_search("spaces", query, limit) do
    case Search.search_spaces(query, limit: limit) do
      {:ok, %{"hits" => hits}} -> hits
      _ -> []
    end
  end

  defp do_search("users", query, limit) do
    case Search.search_users(query, limit: limit) do
      {:ok, %{"hits" => hits}} -> hits
      _ -> []
    end
  end

  defp do_search(_type, _query, _limit), do: []
end
