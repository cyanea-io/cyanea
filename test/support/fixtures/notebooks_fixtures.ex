defmodule Cyanea.NotebooksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Cyanea.Notebooks` context.
  """

  def unique_notebook_title, do: "Notebook #{System.unique_integer([:positive])}"
  def unique_notebook_slug, do: "notebook-#{System.unique_integer([:positive])}"

  def valid_notebook_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      title: unique_notebook_title(),
      slug: unique_notebook_slug(),
      content: %{
        "cells" => [
          %{
            "id" => Ecto.UUID.generate(),
            "type" => "markdown",
            "source" => "# Analysis\n\nThis notebook contains a sample analysis.",
            "position" => 0
          },
          %{
            "id" => Ecto.UUID.generate(),
            "type" => "code",
            "source" => "IO.puts(\"Hello from Cyanea!\")",
            "language" => "elixir",
            "position" => 1
          }
        ]
      },
      position: 0
    })
  end

  def notebook_fixture(attrs \\ %{}) do
    attrs = valid_notebook_attributes(attrs)

    unless Map.has_key?(attrs, :space_id) do
      raise "notebook_fixture requires :space_id"
    end

    {:ok, notebook} = Cyanea.Notebooks.create_notebook(attrs)
    notebook
  end
end
