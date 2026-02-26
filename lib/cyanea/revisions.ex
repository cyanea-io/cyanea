defmodule Cyanea.Revisions do
  @moduledoc """
  The Revisions context — append-only space snapshots.

  Each revision is immutable and sequentially numbered per space.
  Creating a revision also updates the space's `current_revision_id`.
  """
  import Ecto.Query

  alias Cyanea.Repo
  alias Cyanea.Revisions.Revision
  alias Cyanea.Spaces.Space

  ## Create

  @doc """
  Creates a revision for a space.

  Uses Ecto.Multi to atomically:
  1. Compute the next sequential number
  2. Insert the revision
  3. Update the space's current_revision_id
  """
  def create_revision(attrs) do
    space_id = attrs[:space_id] || attrs["space_id"]

    Ecto.Multi.new()
    |> Ecto.Multi.run(:next_number, fn repo, _changes ->
      number =
        repo.one(
          from(r in Revision,
            where: r.space_id == ^space_id,
            select: coalesce(max(r.number), 0)
          )
        ) + 1

      {:ok, number}
    end)
    |> Ecto.Multi.insert(:revision, fn %{next_number: number} ->
      Revision.changeset(%Revision{}, Map.put(attrs, :number, number))
    end)
    |> Ecto.Multi.update(:space, fn %{revision: revision} ->
      Space
      |> Repo.get!(space_id)
      |> Ecto.Changeset.change(current_revision_id: revision.id)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{revision: revision}} -> {:ok, revision}
      {:error, :revision, changeset, _} -> {:error, changeset}
    end
  end

  ## Listing

  @doc """
  Lists revisions for a space, ordered by number descending (newest first).
  """
  def list_revisions(space_id, opts \\ []) do
    limit = Keyword.get(opts, :limit, 50)

    from(r in Revision,
      where: r.space_id == ^space_id,
      order_by: [desc: r.number],
      limit: ^limit,
      preload: [:author]
    )
    |> Repo.all()
  end

  ## Fetching

  @doc """
  Gets a single revision by ID. Raises if not found.
  """
  def get_revision!(id) do
    Revision
    |> Repo.get!(id)
    |> Repo.preload([:author, :space])
  end

  @doc """
  Gets the latest (current) revision for a space.
  """
  def get_latest_revision(space_id) do
    from(r in Revision,
      where: r.space_id == ^space_id,
      order_by: [desc: r.number],
      limit: 1,
      preload: [:author]
    )
    |> Repo.one()
  end
end
