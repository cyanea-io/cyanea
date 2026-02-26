defmodule Cyanea.Workers.NodeHealthWorker do
  @moduledoc """
  Oban cron worker that periodically checks health of all active
  federation nodes.

  Runs every 15 minutes. If a node is unreachable for 3 consecutive
  checks (tracked via metadata), it is automatically deactivated.
  """
  use Oban.Worker, queue: :federation, max_attempts: 1

  alias Cyanea.Federation
  require Logger

  @consecutive_failures_before_deactivate 3

  @impl Oban.Worker
  def perform(%Oban.Job{}) do
    active_nodes = Federation.list_nodes(status: "active")
    Logger.info("Checking health of #{length(active_nodes)} active federation nodes")

    Enum.each(active_nodes, &check_and_update/1)
    :ok
  end

  defp check_and_update(node) do
    case Federation.check_node_health(node) do
      :ok ->
        # Reset failure count on success
        if (node.metadata["consecutive_failures"] || 0) > 0 do
          node
          |> Cyanea.Federation.Node.changeset(%{
            metadata: Map.put(node.metadata || %{}, "consecutive_failures", 0)
          })
          |> Cyanea.Repo.update()
        end

        Logger.debug("Node #{node.name} is healthy")

      {:error, reason} ->
        failures = (node.metadata["consecutive_failures"] || 0) + 1
        Logger.warning("Node #{node.name} health check failed (#{failures}x): #{reason}")

        new_metadata =
          Map.merge(node.metadata || %{}, %{
            "consecutive_failures" => failures,
            "last_failure" => DateTime.utc_now() |> DateTime.to_iso8601(),
            "last_failure_reason" => reason
          })

        if failures >= @consecutive_failures_before_deactivate do
          Logger.error("Deactivating node #{node.name} after #{failures} consecutive failures")
          {:ok, updated} = Federation.deactivate_node(node)

          updated
          |> Cyanea.Federation.Node.changeset(%{metadata: new_metadata})
          |> Cyanea.Repo.update()
        else
          node
          |> Cyanea.Federation.Node.changeset(%{metadata: new_metadata})
          |> Cyanea.Repo.update()
        end
    end
  end
end
