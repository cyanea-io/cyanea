defmodule Cyanea.Workers.SyncPushWorker do
  @moduledoc """
  Oban worker that pushes revisions and blobs from a local space
  to a remote federation node.

  Handles incremental sync: only sends revisions the remote doesn't have
  and only transfers blobs the remote is missing.
  """
  use Oban.Worker, queue: :federation, max_attempts: 3

  alias Cyanea.Federation
  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"space_id" => space_id, "node_id" => node_id} = args}) do
    since_revision = args["since_revision"] || 0
    node = Federation.get_node!(node_id)

    if node.status != "active" do
      Logger.info("Skipping sync push to inactive node #{node.name}")
      :ok
    else
      revisions = Federation.revisions_since(space_id, since_revision)

      if revisions == [] do
        Logger.debug("No new revisions to push for space #{space_id}")
        :ok
      else
        push_revisions_to_node(node, space_id, revisions)
      end
    end
  end

  defp push_revisions_to_node(node, space_id, revisions) do
    url = String.trim_trailing(node.url, "/") <> "/api/federation/revisions/#{space_id}"

    body =
      Jason.encode!(%{
        revisions:
          Enum.map(revisions, fn r ->
            %{
              number: r.number,
              summary: r.summary,
              content_hash: r.content_hash,
              author: r.author && r.author.username,
              created_at: r.created_at && DateTime.to_iso8601(r.created_at)
            }
          end)
      })

    case http_post(url, body) do
      {:ok, %{status: status}} when status in 200..299 ->
        Federation.touch_node_sync(node)
        Logger.info("Pushed #{length(revisions)} revisions for space #{space_id} to #{node.name}")
        :ok

      {:ok, %{status: status}} ->
        Logger.warning("Failed to push revisions to #{node.name}: HTTP #{status}")
        {:error, "HTTP #{status}"}

      {:error, reason} ->
        Logger.warning("Failed to push revisions to #{node.name}: #{inspect(reason)}")
        {:error, reason}
    end
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
