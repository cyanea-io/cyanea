defmodule Cyanea.Datasets do
  @moduledoc """
  The Datasets context — structured data collections within spaces.
  """
  import Ecto.Query

  alias Cyanea.Datasets.{Dataset, DatasetFile}
  alias Cyanea.Repo

  ## Listing

  @doc """
  Lists datasets in a space, ordered by position then name.
  """
  def list_space_datasets(space_id) do
    from(d in Dataset,
      where: d.space_id == ^space_id,
      order_by: [asc: d.position, asc: d.name]
    )
    |> Repo.all()
  end

  ## Fetching

  @doc """
  Gets a single dataset by ID. Raises if not found.
  """
  def get_dataset!(id), do: Repo.get!(Dataset, id)

  @doc """
  Gets a dataset by space ID and slug.
  """
  def get_dataset_by_slug(space_id, slug) do
    Repo.get_by(Dataset, space_id: space_id, slug: String.downcase(slug))
  end

  ## Create / Update / Delete

  @doc """
  Creates a dataset in a space.
  """
  def create_dataset(attrs) do
    %Dataset{}
    |> Dataset.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a dataset.
  """
  def update_dataset(%Dataset{} = dataset, attrs) do
    dataset
    |> Dataset.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a dataset.
  """
  def delete_dataset(%Dataset{} = dataset) do
    Repo.delete(dataset)
  end

  ## File Management

  @doc """
  Lists files attached to a dataset.
  """
  def list_dataset_files(dataset_id) do
    from(df in DatasetFile,
      where: df.dataset_id == ^dataset_id,
      order_by: [asc: df.path],
      preload: [:blob]
    )
    |> Repo.all()
  end

  @doc """
  Attaches a blob to a dataset at a given path.
  """
  def attach_file(%Dataset{} = dataset, blob_id, path, opts \\ []) do
    size = Keyword.get(opts, :size)

    %DatasetFile{}
    |> DatasetFile.changeset(%{
      dataset_id: dataset.id,
      blob_id: blob_id,
      path: path,
      size: size
    })
    |> Repo.insert()
    |> case do
      {:ok, df} -> {:ok, Repo.preload(df, [:blob])}
      error -> error
    end
  end

  @doc """
  Detaches a file from a dataset.
  """
  def detach_file(dataset_file_id) do
    df = Repo.get!(DatasetFile, dataset_file_id)
    Repo.delete(df)
  end
end
