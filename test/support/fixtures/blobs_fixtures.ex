defmodule Cyanea.BlobsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Cyanea.Blobs` context.
  """

  alias Cyanea.Blobs.{Blob, SpaceFile}
  alias Cyanea.Repo

  def unique_blob_content do
    "blob-content-#{System.unique_integer([:positive])}-#{:crypto.strong_rand_bytes(16) |> Base.encode16(case: :lower)}"
  end

  def blob_fixture(attrs \\ %{}) do
    content = Map.get(attrs, :content, unique_blob_content())
    sha256 = :crypto.hash(:sha256, content) |> Base.encode16(case: :lower)
    size = byte_size(content)
    s3_key = "blobs/#{String.slice(sha256, 0, 2)}/#{String.slice(sha256, 2, 2)}/#{sha256}"

    blob_attrs =
      attrs
      |> Map.drop([:content])
      |> Enum.into(%{
        sha256: sha256,
        s3_key: s3_key,
        size: size,
        mime_type: "application/octet-stream"
      })

    %Blob{}
    |> Blob.changeset(blob_attrs)
    |> Repo.insert!()
  end

  def space_file_fixture(attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        path: "data/file-#{System.unique_integer([:positive])}.txt",
        name: "file-#{System.unique_integer([:positive])}.txt"
      })

    unless Map.has_key?(attrs, :space_id) && Map.has_key?(attrs, :blob_id) do
      raise "space_file_fixture requires :space_id and :blob_id"
    end

    %SpaceFile{}
    |> SpaceFile.changeset(attrs)
    |> Repo.insert!()
  end
end
