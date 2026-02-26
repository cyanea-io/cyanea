defmodule Cyanea.Workers.SyncPullWorker do
  @moduledoc """
  Oban worker that pulls new manifests from a remote federation node.

  Fetches the list of published manifests from a remote node and stores
  any new or updated ones locally for cross-node discovery.
  """
  use Oban.Worker, queue: :federation, max_attempts: 3

  alias Cyanea.Federation
  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"node_id" => node_id}}) do
    node = Federation.get_node!(node_id)

    if node.status != "active" do
      Logger.info("Skipping sync pull from inactive node #{node.name}")
      :ok
    else
      pull_manifests_from_node(node)
    end
  end

  defp pull_manifests_from_node(node) do
    url = String.trim_trailing(node.url, "/") <> "/api/federation/manifests"

    case http_get(url) do
      {:ok, %{status: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"manifests" => manifests}} ->
            imported = import_manifests(manifests, node)
            Federation.touch_node_sync(node)
            Logger.info("Pulled #{imported} manifests from #{node.name}")
            :ok

          {:error, _} ->
            Logger.warning("Invalid JSON response from #{node.name}")
            {:error, "invalid response"}
        end

      {:ok, %{status: status}} ->
        Logger.warning("Failed to pull from #{node.name}: HTTP #{status}")
        {:error, "HTTP #{status}"}

      {:error, reason} ->
        Logger.warning("Failed to pull from #{node.name}: #{inspect(reason)}")
        {:error, reason}
    end
  end

  defp import_manifests(manifests, node) do
    manifests
    |> Enum.reduce(0, fn manifest_data, count ->
      attrs = %{
        global_id: manifest_data["global_id"],
        content_hash: manifest_data["content_hash"],
        payload: manifest_data["payload"],
        revision_number: manifest_data["revision_number"],
        node_id: node.id,
        space_id: manifest_data["space_id"]
      }

      case Federation.receive_remote_manifest(attrs) do
        {:ok, _} -> count + 1
        {:error, _} -> count
      end
    end)
  end

  defp http_get(url) do
    :httpc.request(:get, {String.to_charlist(url), []}, [timeout: 30_000], [])
    |> case do
      {:ok, {{_, status, _}, _headers, body}} ->
        {:ok, %{status: status, body: List.to_string(body)}}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
