defmodule Cyanea.DatasetsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Cyanea.Datasets` context.
  """

  def unique_dataset_name, do: "Dataset #{System.unique_integer([:positive])}"
  def unique_dataset_slug, do: "dataset-#{System.unique_integer([:positive])}"

  def valid_dataset_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      name: unique_dataset_name(),
      slug: unique_dataset_slug(),
      description: "A test dataset",
      storage_type: "local",
      metadata: %{},
      tags: [],
      position: 0
    })
  end

  def dataset_fixture(attrs \\ %{}) do
    attrs = valid_dataset_attributes(attrs)

    unless Map.has_key?(attrs, :space_id) do
      raise "dataset_fixture requires :space_id"
    end

    {:ok, dataset} = Cyanea.Datasets.create_dataset(attrs)
    dataset
  end
end
