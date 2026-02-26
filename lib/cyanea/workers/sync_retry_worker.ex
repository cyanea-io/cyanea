defmodule Cyanea.Workers.SyncRetryWorker do
  @moduledoc """
  Oban cron worker that picks up retryable sync entries and
  re-enqueues the appropriate push/pull workers.

  Runs every 5 minutes.
  """
  use Oban.Worker, queue: :federation, max_attempts: 1

  alias Cyanea.Federation
  alias Cyanea.Workers.PublishWorker
  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{}) do
    entries = Federation.retryable_syncs()

    if entries != [] do
      Logger.info("Retrying #{length(entries)} failed sync entries")
    end

    Enum.each(entries, fn entry ->
      case entry.direction do
        "push" ->
          %{sync_entry_id: entry.id}
          |> PublishWorker.new()
          |> Oban.insert()

        "pull" ->
          %{node_id: entry.node_id}
          |> Cyanea.Workers.SyncPullWorker.new()
          |> Oban.insert()
      end
    end)

    :ok
  end
end
