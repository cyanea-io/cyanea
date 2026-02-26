defmodule Cyanea.Notebooks do
  @moduledoc """
  The Notebooks context — computational notebooks within spaces.
  """
  import Ecto.Query

  alias Cyanea.Notebooks.Notebook
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
end
