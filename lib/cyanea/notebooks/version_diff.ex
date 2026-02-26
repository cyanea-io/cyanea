defmodule Cyanea.Notebooks.VersionDiff do
  @moduledoc """
  Cell-level diff between two notebook version snapshots.

  Compares cells by ID and reports changes:
  - `:unchanged` — same source
  - `:modified` — source changed (includes old + new)
  - `:added` — cell only in new version
  - `:removed` — cell only in old version
  - `:moved` — same source, different position
  """

  @type change_type :: :unchanged | :modified | :added | :removed | :moved

  @type cell_diff :: %{
          cell_id: String.t(),
          type: change_type,
          cell_type: String.t() | nil,
          language: String.t() | nil,
          old_source: String.t() | nil,
          new_source: String.t() | nil,
          old_position: integer() | nil,
          new_position: integer() | nil
        }

  @doc """
  Computes a list of cell-level diffs between two version content snapshots.

  Each content map should have a `"cells"` key containing a list of cell maps.
  """
  @spec diff(map(), map()) :: [cell_diff()]
  def diff(old_content, new_content) do
    old_cells = Map.get(old_content, "cells", [])
    new_cells = Map.get(new_content, "cells", [])

    old_by_id = Map.new(old_cells, &{&1["id"], &1})
    new_by_id = Map.new(new_cells, &{&1["id"], &1})

    old_ids = MapSet.new(Map.keys(old_by_id))
    new_ids = MapSet.new(Map.keys(new_by_id))

    # Cells in both versions
    common_ids = MapSet.intersection(old_ids, new_ids)

    common_diffs =
      common_ids
      |> Enum.map(fn id ->
        old_cell = old_by_id[id]
        new_cell = new_by_id[id]
        diff_cell(old_cell, new_cell)
      end)
      |> Enum.sort_by(& &1.new_position)

    # Added cells (only in new)
    added =
      new_ids
      |> MapSet.difference(old_ids)
      |> Enum.map(fn id ->
        cell = new_by_id[id]

        %{
          cell_id: id,
          type: :added,
          cell_type: cell["type"],
          language: cell["language"],
          old_source: nil,
          new_source: cell["source"],
          old_position: nil,
          new_position: cell["position"]
        }
      end)
      |> Enum.sort_by(& &1.new_position)

    # Removed cells (only in old)
    removed =
      old_ids
      |> MapSet.difference(new_ids)
      |> Enum.map(fn id ->
        cell = old_by_id[id]

        %{
          cell_id: id,
          type: :removed,
          cell_type: cell["type"],
          language: cell["language"],
          old_source: cell["source"],
          new_source: nil,
          old_position: cell["position"],
          new_position: nil
        }
      end)
      |> Enum.sort_by(& &1.old_position)

    common_diffs ++ added ++ removed
  end

  defp diff_cell(old_cell, new_cell) do
    old_source = old_cell["source"] || ""
    new_source = new_cell["source"] || ""
    old_pos = old_cell["position"]
    new_pos = new_cell["position"]

    type =
      cond do
        old_source == new_source && old_pos == new_pos -> :unchanged
        old_source == new_source && old_pos != new_pos -> :moved
        true -> :modified
      end

    %{
      cell_id: old_cell["id"],
      type: type,
      cell_type: new_cell["type"],
      language: new_cell["language"],
      old_source: old_source,
      new_source: new_source,
      old_position: old_pos,
      new_position: new_pos
    }
  end
end
