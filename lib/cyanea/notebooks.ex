defmodule Cyanea.Notebooks do
  @moduledoc """
  The Notebooks context — computational notebooks within spaces.
  """
  import Ecto.Query

  alias Cyanea.Notebooks.{Notebook, NotebookVersion, ExecutionResult}
  alias Cyanea.Repo

  ## Listing

  @doc """
  Lists notebooks in a space, ordered by position then title.
  """
  def list_space_notebooks(space_id) do
    from(n in Notebook,
      where: n.space_id == ^space_id,
      order_by: [asc: n.position, asc: n.title]
    )
    |> Repo.all()
  end

  ## Fetching

  @doc """
  Gets a single notebook by ID. Raises if not found.
  """
  def get_notebook!(id), do: Repo.get!(Notebook, id)

  @doc """
  Gets a notebook by space ID and slug.
  """
  def get_notebook_by_slug(space_id, slug) do
    Repo.get_by(Notebook, space_id: space_id, slug: String.downcase(slug))
  end

  ## Create / Update / Delete

  @doc """
  Creates a notebook in a space.
  """
  def create_notebook(attrs) do
    %Notebook{}
    |> Notebook.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a notebook.
  """
  def update_notebook(%Notebook{} = notebook, attrs) do
    notebook
    |> Notebook.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a notebook.
  """
  def delete_notebook(%Notebook{} = notebook) do
    Repo.delete(notebook)
  end

  @doc """
  Returns a changeset for tracking notebook changes in forms.
  """
  def change_notebook(%Notebook{} = notebook, attrs \\ %{}) do
    Notebook.changeset(notebook, attrs)
  end

  ## Cell Management

  @doc """
  Adds a cell to a notebook at the given position.

  If position is nil, appends to the end.
  """
  def add_cell(%Notebook{} = notebook, type, position \\ nil) do
    cells = get_cells(notebook)
    position = position || length(cells)

    new_cell = %{
      "id" => Ecto.UUID.generate(),
      "type" => to_string(type),
      "source" => "",
      "position" => position
    }

    new_cell =
      if type in ["code", :code] do
        Map.put(new_cell, "language", "cyanea")
      else
        new_cell
      end

    cells =
      cells
      |> List.insert_at(position, new_cell)
      |> reindex_positions()

    update_notebook(notebook, %{content: %{"cells" => cells}})
  end

  @doc """
  Removes a cell from a notebook by cell ID.
  """
  def remove_cell(%Notebook{} = notebook, cell_id) do
    cells =
      notebook
      |> get_cells()
      |> Enum.reject(&(&1["id"] == cell_id))
      |> reindex_positions()

    update_notebook(notebook, %{content: %{"cells" => cells}})
  end

  @doc """
  Updates a cell's attributes (source, language, etc.).
  """
  def update_cell(%Notebook{} = notebook, cell_id, attrs) do
    cells =
      notebook
      |> get_cells()
      |> Enum.map(fn cell ->
        if cell["id"] == cell_id do
          Map.merge(cell, stringify_keys(attrs))
        else
          cell
        end
      end)

    update_notebook(notebook, %{content: %{"cells" => cells}})
  end

  @doc """
  Moves a cell up or down by one position.
  """
  def move_cell(%Notebook{} = notebook, cell_id, direction) when direction in [:up, :down] do
    cells = get_cells(notebook)
    idx = Enum.find_index(cells, &(&1["id"] == cell_id))

    cond do
      is_nil(idx) ->
        {:ok, notebook}

      direction == :up and idx == 0 ->
        {:ok, notebook}

      direction == :down and idx == length(cells) - 1 ->
        {:ok, notebook}

      true ->
        swap_idx = if direction == :up, do: idx - 1, else: idx + 1

        cells =
          cells
          |> List.replace_at(idx, Enum.at(cells, swap_idx))
          |> List.replace_at(swap_idx, Enum.at(cells, idx))
          |> reindex_positions()

        update_notebook(notebook, %{content: %{"cells" => cells}})
    end
  end

  @doc """
  Returns the list of cells from a notebook's content.
  """
  def get_cells(%Notebook{content: content}) when is_map(content) do
    Map.get(content, "cells", [])
  end

  def get_cells(%Notebook{}), do: []

  @doc """
  Returns true if the cell is an executable code cell (cyanea or elixir).
  """
  def executable_cell?(%{"type" => "code", "language" => "cyanea"}), do: true
  def executable_cell?(%{"type" => "code", "language" => "elixir"}), do: true
  def executable_cell?(_), do: false

  @doc """
  Returns true if the cell executes server-side (elixir).
  """
  def server_executable_cell?(%{"type" => "code", "language" => "elixir"}), do: true
  def server_executable_cell?(_), do: false

  defp reindex_positions(cells) do
    cells
    |> Enum.with_index()
    |> Enum.map(fn {cell, idx} -> Map.put(cell, "position", idx) end)
  end

  defp stringify_keys(map) do
    Map.new(map, fn {k, v} -> {to_string(k), v} end)
  end

  ## Versioning

  @doc """
  Creates a version snapshot of the notebook's current content.

  Uses Ecto.Multi to atomically determine the next version number.
  Deduplicates by content_hash — returns existing version if hash matches latest.
  """
  def create_version(%Notebook{} = notebook, trigger, author_id \\ nil, label \\ nil) do
    content = notebook.content || %{}
    content_hash = content_hash(content)

    Ecto.Multi.new()
    |> Ecto.Multi.run(:next_number, fn repo, _ ->
      result =
        from(v in NotebookVersion,
          where: v.notebook_id == ^notebook.id,
          select: coalesce(max(v.number), 0) + 1
        )
        |> repo.one()

      {:ok, result}
    end)
    |> Ecto.Multi.run(:check_dedup, fn repo, %{next_number: next_number} ->
      # If the latest version has the same content hash, skip creation
      latest =
        from(v in NotebookVersion,
          where: v.notebook_id == ^notebook.id and v.number == ^(next_number - 1) and v.content_hash == ^content_hash
        )
        |> repo.one()

      {:ok, latest}
    end)
    |> Ecto.Multi.run(:version, fn repo, %{next_number: next_number, check_dedup: dedup} ->
      if dedup do
        {:ok, dedup}
      else
        %NotebookVersion{}
        |> NotebookVersion.changeset(%{
          number: next_number,
          label: label,
          content: content,
          content_hash: content_hash,
          trigger: trigger,
          notebook_id: notebook.id,
          author_id: author_id,
          created_at: DateTime.utc_now() |> DateTime.truncate(:second)
        })
        |> repo.insert()
      end
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{version: version}} -> {:ok, version}
      {:error, _step, changeset, _changes} -> {:error, changeset}
    end
  end

  @doc "Lists versions for a notebook, descending by number."
  def list_versions(notebook_id, opts \\ []) do
    limit = Keyword.get(opts, :limit, 50)

    from(v in NotebookVersion,
      where: v.notebook_id == ^notebook_id,
      order_by: [desc: v.number],
      limit: ^limit,
      preload: [:author]
    )
    |> Repo.all()
  end

  @doc "Gets a single version by ID."
  def get_version!(id), do: Repo.get!(NotebookVersion, id) |> Repo.preload(:author)

  @doc "Gets the latest version for a notebook."
  def get_latest_version(notebook_id) do
    from(v in NotebookVersion,
      where: v.notebook_id == ^notebook_id,
      order_by: [desc: v.number],
      limit: 1
    )
    |> Repo.one()
  end

  @doc """
  Restores a notebook to a previous version's content.

  Creates a "Before restore" version of current content, then updates the notebook.
  """
  def restore_version(%Notebook{} = notebook, version_id, author_id \\ nil) do
    version = get_version!(version_id)

    Ecto.Multi.new()
    |> Ecto.Multi.run(:snapshot, fn _repo, _ ->
      create_version(notebook, "manual", author_id, "Before restore")
    end)
    |> Ecto.Multi.run(:restore, fn _repo, _ ->
      update_notebook(notebook, %{content: version.content})
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{restore: notebook}} -> {:ok, notebook}
      {:error, _step, changeset, _changes} -> {:error, changeset}
    end
  end

  defp content_hash(content) do
    content
    |> Jason.encode!()
    |> then(&:crypto.hash(:sha256, &1))
    |> Base.encode16(case: :lower)
  end

  ## Execution Results

  @doc "Upserts an execution result for a cell (one result per notebook+cell)."
  def upsert_execution_result(attrs) do
    %ExecutionResult{}
    |> ExecutionResult.changeset(attrs)
    |> Repo.insert(
      on_conflict: {:replace, [:status, :output, :user_id]},
      conflict_target: [:notebook_id, :cell_id]
    )
  end

  @doc "Loads all execution results for a notebook as a map of cell_id => output."
  def load_execution_results(notebook_id) do
    from(r in ExecutionResult,
      where: r.notebook_id == ^notebook_id,
      select: {r.cell_id, r.output}
    )
    |> Repo.all()
    |> Map.new()
  end
end
