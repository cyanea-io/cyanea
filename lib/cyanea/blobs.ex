defmodule Cyanea.Blobs do
  @moduledoc """
  The Blobs context — content-addressed file storage.

  Manages deduplicated blob storage and space file attachments.
  Blobs are identified by SHA-256 hash, enabling automatic dedup.
  """
  import Ecto.Query

  alias Cyanea.Blobs.{Blob, SpaceFile}
  alias Cyanea.Hash
  alias Cyanea.Repo
  alias Cyanea.Storage

  ## Blob Management

  @doc """
  Creates a blob from binary data: computes SHA-256, uploads to S3,
  and inserts a DB record. Deduplicates by SHA-256.
  """
  def create_blob_from_binary(binary, opts \\ []) when is_binary(binary) do
    sha256 = Hash.sha256(binary)
    mime_type = Keyword.get(opts, :mime_type, "application/octet-stream")

    case find_or_create_blob(sha256, byte_size(binary), mime_type) do
      {:existing, blob} ->
        {:ok, blob}

      {:new, blob} ->
        case Storage.upload(binary, blob.s3_key, content_type: mime_type) do
          {:ok, _} -> {:ok, blob}
          {:error, reason} -> {:error, reason}
        end
    end
  end

  @doc """
  Creates a blob from an uploaded file temp path.
  """
  def create_blob_from_upload(tmp_path, opts \\ []) do
    binary = File.read!(tmp_path)
    create_blob_from_binary(binary, opts)
  end

  @doc """
  Finds an existing blob by SHA-256, or creates a new one.
  Returns `{:existing, blob}` or `{:new, blob}`.
  """
  def find_or_create_blob(sha256, size, mime_type) do
    case Repo.get_by(Blob, sha256: sha256) do
      %Blob{} = existing ->
        {:existing, existing}

      nil ->
        s3_key = generate_blob_s3_key(sha256)

        attrs = %{
          sha256: sha256,
          size: size,
          mime_type: mime_type,
          s3_key: s3_key
        }

        case Repo.insert(Blob.changeset(%Blob{}, attrs)) do
          {:ok, blob} -> {:new, blob}
          {:error, changeset} -> {:error, changeset}
        end
    end
  end

  ## Fetching

  @doc """
  Gets a blob by ID. Raises if not found.
  """
  def get_blob!(id), do: Repo.get!(Blob, id)

  @doc """
  Gets a blob by its SHA-256 hash.
  """
  def get_blob_by_sha256(sha256), do: Repo.get_by(Blob, sha256: sha256)

  ## Space Files

  @doc """
  Lists files attached to a space, ordered by path.
  """
  def list_space_files(space_id) do
    from(sf in SpaceFile,
      where: sf.space_id == ^space_id,
      order_by: [asc: sf.name],
      preload: [:blob]
    )
    |> Repo.all()
  end

  @doc """
  Attaches a blob to a space at a given file path.
  """
  def attach_file_to_space(space_id, blob_id, path, name) do
    %SpaceFile{}
    |> SpaceFile.changeset(%{
      space_id: space_id,
      blob_id: blob_id,
      path: path,
      name: name
    })
    |> Repo.insert()
    |> case do
      {:ok, sf} -> {:ok, Repo.preload(sf, [:blob])}
      error -> error
    end
  end

  @doc """
  Detaches a file from a space (deletes the SpaceFile record).
  """
  def detach_file_from_space(space_file_id) do
    sf = Repo.get!(SpaceFile, space_file_id)
    Repo.delete(sf)
  end

  @doc """
  Returns a presigned download URL for a blob.
  """
  def download_url(%Blob{s3_key: s3_key}) do
    Storage.presigned_download_url(s3_key)
  end

  @doc """
  Deletes a blob from S3 and the database.
  Only safe if no space_files or dataset_files reference it.
  """
  def delete_blob(%Blob{} = blob) do
    with {:ok, _} <- Storage.delete(blob.s3_key) do
      Repo.delete(blob)
    end
  end

  ## Internal

  @doc """
  Generates a content-addressed S3 key for a blob.
  Layout: `blobs/<first-2-chars>/<next-2-chars>/<full-sha256>`
  """
  def generate_blob_s3_key(sha256) do
    prefix1 = String.slice(sha256, 0, 2)
    prefix2 = String.slice(sha256, 2, 2)
    "blobs/#{prefix1}/#{prefix2}/#{sha256}"
  end
end
