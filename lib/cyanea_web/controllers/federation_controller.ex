defmodule CyaneaWeb.FederationController do
  @moduledoc """
  API controller for federation node-to-node communication.

  Provides endpoints for:
  - Manifest exchange (list/get published manifests)
  - Sync operations (push content from remote nodes)
  - Revision queries (incremental sync support)
  - Health checks (node availability)
  """
  use CyaneaWeb, :controller

  alias Cyanea.Federation

  @doc """
  GET /api/federation/health

  Returns this node's health status and basic info.
  """
  def health(conn, _params) do
    host = System.get_env("FEDERATION_NODE_URL") ||
           Application.get_env(:cyanea, CyaneaWeb.Endpoint)[:url][:host] || "localhost"

    json(conn, %{
      status: "ok",
      node: host,
      version: "0.5.0",
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
    })
  end

  @doc """
  GET /api/federation/manifests

  Lists published manifests from this node.
  Optional params: limit (default 100), since (ISO 8601 datetime).
  """
  def list_manifests(conn, params) do
    limit = parse_int(params["limit"], 100)

    manifests = Federation.list_manifests(status: "published", limit: limit)

    json(conn, %{
      manifests: Enum.map(manifests, &serialize_manifest/1)
    })
  end

  @doc """
  GET /api/federation/manifests/:global_id

  Returns a specific manifest by global ID.
  """
  def show_manifest(conn, %{"global_id" => global_id}) do
    # Global ID comes URL-encoded, decode it
    decoded = URI.decode(global_id)

    case Federation.get_manifest_by_global_id(decoded) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Manifest not found"})

      manifest ->
        json(conn, %{manifest: serialize_manifest(manifest)})
    end
  end

  @doc """
  GET /api/federation/revisions/:space_id

  Returns revisions for a space since a given revision number.
  Used for incremental sync.

  Params:
  - since: revision number to start from (default 0 = all)
  """
  def list_revisions(conn, %{"space_id" => space_id} = params) do
    since = parse_int(params["since"], 0)

    revisions = Federation.revisions_since(space_id, since)

    json(conn, %{
      space_id: space_id,
      revisions: Enum.map(revisions, &serialize_revision/1)
    })
  end

  @doc """
  GET /api/federation/blobs/:space_id

  Returns blob hashes for a space, so the remote can determine
  which blobs it needs to fetch.
  """
  def list_blob_hashes(conn, %{"space_id" => space_id}) do
    hashes = Federation.space_blob_hashes(space_id)

    json(conn, %{
      space_id: space_id,
      blobs: Enum.map(hashes, fn {id, sha256} -> %{id: id, sha256: sha256} end)
    })
  end

  @doc """
  POST /api/federation/sync/push

  Receives a manifest push from a remote node.
  The remote node sends its manifest data, and this node stores it
  for cross-node discovery.
  """
  def receive_push(conn, %{"manifest" => manifest_params, "node_url" => node_url}) do
    # Look up or register the sending node
    node = Federation.get_node_by_url(node_url)

    node =
      case node do
        nil ->
          {:ok, n} = Federation.register_node(%{name: node_url, url: node_url})
          {:ok, n} = Federation.activate_node(n)
          n

        n ->
          n
      end

    manifest_attrs = %{
      global_id: manifest_params["global_id"],
      content_hash: manifest_params["content_hash"],
      payload: manifest_params["payload"],
      revision_number: manifest_params["revision_number"],
      node_id: node.id,
      space_id: manifest_params["space_id"]
    }

    case Federation.receive_remote_manifest(manifest_attrs) do
      {:ok, manifest} ->
        Federation.touch_node_sync(node)

        conn
        |> put_status(:created)
        |> json(%{status: "accepted", manifest_id: manifest.id})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Invalid manifest", details: format_errors(changeset)})
    end
  end

  def receive_push(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "Missing required fields: manifest, node_url"})
  end

  @doc """
  POST /api/federation/register

  Handles a remote node requesting to register with this node.
  """
  def register_remote(conn, %{"name" => name, "url" => url} = params) do
    public_key = params["public_key"]

    attrs = %{name: name, url: url, public_key: public_key}

    case Federation.get_node_by_url(url) do
      nil ->
        case Federation.register_node(attrs) do
          {:ok, node} ->
            conn
            |> put_status(:created)
            |> json(%{
              status: "registered",
              node_id: node.id,
              node_status: node.status
            })

          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{error: "Registration failed", details: format_errors(changeset)})
        end

      existing ->
        json(conn, %{
          status: "already_registered",
          node_id: existing.id,
          node_status: existing.status
        })
    end
  end

  def register_remote(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "Missing required fields: name, url"})
  end

  # ===========================================================================
  # Helpers
  # ===========================================================================

  defp serialize_manifest(manifest) do
    %{
      id: manifest.id,
      global_id: manifest.global_id,
      content_hash: manifest.content_hash,
      status: manifest.status,
      revision_number: manifest.revision_number,
      payload: manifest.payload,
      space_id: manifest.space_id,
      node_id: manifest.node_id,
      published_at: manifest.inserted_at && DateTime.to_iso8601(manifest.inserted_at)
    }
  end

  defp serialize_revision(revision) do
    %{
      id: revision.id,
      number: revision.number,
      summary: revision.summary,
      content_hash: revision.content_hash,
      author: revision.author && revision.author.username,
      created_at: revision.created_at && DateTime.to_iso8601(revision.created_at)
    }
  end

  defp parse_int(nil, default), do: default
  defp parse_int(val, default) when is_binary(val) do
    case Integer.parse(val) do
      {n, _} -> n
      :error -> default
    end
  end
  defp parse_int(val, _default) when is_integer(val), do: val

  defp format_errors(%Ecto.Changeset{} = changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end

  defp format_errors(other), do: inspect(other)
end
