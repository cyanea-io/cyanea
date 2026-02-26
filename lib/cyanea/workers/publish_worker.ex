defmodule Cyanea.Workers.PublishWorker do
  @moduledoc """
  Oban worker that publishes a space's manifest to a specific remote node.

  Enqueued by `Federation.publish_space/2`. For each active node, a separate
  job is created so failures are isolated per-node.
  """
  use Oban.Worker, queue: :federation, max_attempts: 5

  alias Cyanea.Federation
  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"sync_entry_id" => sync_entry_id}}) do
    entry = Cyanea.Repo.get!(Federation.SyncEntry, sync_entry_id)
    node = Federation.get_node!(entry.node_id)

    case node.status do
      "active" ->
        push_manifest_to_node(entry, node)

      status ->
        Logger.info("Skipping publish to node #{node.name} (status: #{status})")
        Federation.complete_sync(entry, bytes_transferred: 0)
        :ok
    end
  end

  def perform(%Oban.Job{args: %{"space_id" => space_id}}) do
    space = Cyanea.Spaces.get_space!(space_id)

    case Federation.publish_space(space) do
      {:ok, _manifest} ->
        Logger.info("Published space #{space.name} to federation")
        :ok

      {:error, reason} ->
        Logger.error("Failed to publish space #{space.name}: #{inspect(reason)}")
        {:error, reason}
    end
  end

  defp push_manifest_to_node(entry, node) do
    manifest = Federation.get_active_manifest(entry.resource_id)

    if manifest do
      push_url = String.trim_trailing(node.url, "/") <> "/api/federation/sync/push"
      this_node_url = federation_node_url()

      body =
        Jason.encode!(%{
          node_url: this_node_url,
          manifest: %{
            global_id: manifest.global_id,
            content_hash: manifest.content_hash,
            payload: manifest.payload,
            revision_number: manifest.revision_number,
            space_id: manifest.space_id
          }
        })

      case http_post(push_url, body) do
        {:ok, %{status: status}} when status in 200..299 ->
          Federation.complete_sync(entry, bytes_transferred: byte_size(body))
          Federation.touch_node_sync(node)
          :ok

        {:ok, %{status: status, body: resp_body}} ->
          error = "HTTP #{status}: #{resp_body}"
          Federation.fail_sync(entry, error)
          {:error, error}

        {:error, reason} ->
          error = "Network error: #{inspect(reason)}"
          Federation.fail_sync(entry, error)
          {:error, error}
      end
    else
      Federation.complete_sync(entry, bytes_transferred: 0)
      :ok
    end
  end

  defp federation_node_url do
    System.get_env("FEDERATION_NODE_URL") ||
      "https://" <> (Application.get_env(:cyanea, CyaneaWeb.Endpoint)[:url][:host] || "localhost")
  end

  defp http_post(url, body) do
    headers = [{~c"content-type", ~c"application/json"}]

    :httpc.request(
      :post,
      {String.to_charlist(url), headers, ~c"application/json", String.to_charlist(body)},
      [timeout: 30_000],
      []
    )
    |> case do
      {:ok, {{_, status, _}, _headers, resp_body}} ->
        {:ok, %{status: status, body: List.to_string(resp_body)}}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
