defmodule Cyanea.NotebookVersionsFixtures do
  @moduledoc """
  Test helpers for creating notebook version entities.
  """

  alias Cyanea.Notebooks

  def version_fixture(%{notebook: notebook} = attrs) do
    trigger = Map.get(attrs, :trigger, "manual")
    author_id = Map.get(attrs, :author_id, nil)
    label = Map.get(attrs, :label, nil)

    {:ok, version} = Notebooks.create_version(notebook, trigger, author_id, label)
    version
  end
end
