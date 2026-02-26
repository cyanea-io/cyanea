defmodule Cyanea.Workers.StorageRecalcWorker do
  @moduledoc """
  Periodic Oban worker that recomputes stale storage usage caches.

  Runs hourly via Oban Cron to correct any drift from incremental updates.
  Recomputes all storage_usage entries that are more than 1 hour old.
  """
  use Oban.Worker, queue: :default, max_attempts: 3

  import Ecto.Query

  alias Cyanea.Billing
  alias Cyanea.Billing.StorageUsage
  alias Cyanea.Repo

  @stale_threshold_seconds 3600

  @impl Oban.Worker
  def perform(_job) do
    cutoff = DateTime.utc_now() |> DateTime.add(-@stale_threshold_seconds, :second)

    stale_entries =
      from(su in StorageUsage,
        where: su.computed_at < ^cutoff,
        select: {su.owner_type, su.owner_id}
      )
      |> Repo.all()

    Enum.each(stale_entries, fn {owner_type, owner_id} ->
      Billing.refresh_storage_cache(owner_type, owner_id)
    end)

    :ok
  end
end
