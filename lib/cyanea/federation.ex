defmodule Cyanea.Federation do
  @moduledoc """
  The Federation context — global IDs, manifests, node sync.

  Manages Cyanea's federation layer: connecting nodes, publishing
  signed manifests, and tracking sync state. Federation is selective
  per-space and opt-in per-node.

  ## Global ID Scheme

  Resources are identified by URIs of the form:

      cyanea://<host>/<owner>/<space-slug>

  For example:

      cyanea://hub.cyanea.io/lab-x/rna-seq-2024

  Global IDs are stable, human-readable, and encode enough context
  for cross-node resolution.
  """
  import Ecto.Query

  alias Cyanea.Repo
  alias Cyanea.Federation.{Node, Manifest, SyncEntry}
  alias Cyanea.Spaces.Space

  # ===========================================================================
  # Global IDs
  # ===========================================================================

  @doc """
  Generates a global federation ID for a space.

  Format: `cyanea://<host>/<owner>/<space-slug>`

  The host is read from the `FEDERATION_NODE_URL` environment variable,
  falling back to the configured `PHX_HOST`.
  """
  def generate_global_id(%Space{} = space) do
    host = node_host()
    owner_slug = Cyanea.Spaces.owner_display(space)
    "cyanea://#{host}/#{owner_slug}/#{space.slug}"
  end

  @doc """
  Parses a global ID into its components.

  Returns `{:ok, %{host: host, owner: owner, slug: slug}}`
  or `{:error, :invalid_global_id}`.
  """
  def parse_global_id("cyanea://" <> rest) do
    case String.split(rest, "/", parts: 3) do
      [host, owner, slug] ->
        {:ok, %{host: host, owner: owner, slug: slug}}

      _ ->
        {:error, :invalid_global_id}
    end
  end

  def parse_global_id(_), do: {:error, :invalid_global_id}

  @doc """
  Assigns a global ID to a space and persists it.
  """
  def assign_global_id(%Space{} = space) do
    global_id = generate_global_id(space)

    space
    |> Ecto.Changeset.change(global_id: global_id)
    |> Repo.update()
  end

  # ===========================================================================
  # Node Management
  # ===========================================================================

  @doc """
  Lists all federation nodes.
  """
  def list_nodes(opts \\ []) do
    status_filter = Keyword.get(opts, :status, nil)

    query = from(n in Node, order_by: [asc: n.name])

    query =
      if status_filter do
        from(n in query, where: n.status == ^status_filter)
      else
        query
      end

    Repo.all(query)
  end

  @doc """
  Gets a node by ID. Raises if not found.
  """
  def get_node!(id), do: Repo.get!(Node, id)

  @doc """
  Gets a node by its URL.
  """
  def get_node_by_url(url), do: Repo.get_by(Node, url: url)

  @doc """
  Registers a new federation node (initially in `pending` status).
  """
  def register_node(attrs) do
    %Node{}
    |> Node.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Activates a pending node after key exchange / verification.
  """
  def activate_node(%Node{} = node) do
    node
    |> Node.changeset(%{status: "active"})
    |> Repo.update()
  end

  @doc """
  Deactivates a node (e.g. if it becomes unreachable).
  """
  def deactivate_node(%Node{} = node) do
    node
    |> Node.changeset(%{status: "inactive"})
    |> Repo.update()
  end

  @doc """
  Revokes a node's federation access.
  """
  def revoke_node(%Node{} = node) do
    node
    |> Node.changeset(%{status: "revoked"})
    |> Repo.update()
  end

  @doc """
  Records a successful sync timestamp on a node.
  """
  def touch_node_sync(%Node{} = node) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    node
    |> Node.changeset(%{last_sync_at: now})
    |> Repo.update()
  end

  # ===========================================================================
  # Manifests
  # ===========================================================================

  @doc """
  Publishes a signed manifest for a space.

  This creates a manifest record that attests the space's content hash
  and optionally signs it with the node's key.
  """
  def publish_manifest(%Space{} = space, opts \\ []) do
    node_id = Keyword.get(opts, :node_id)
    signature = Keyword.get(opts, :signature)
    signer_key_id = Keyword.get(opts, :signer_key_id)

    # Ensure the space has a global ID.
    space =
      if space.global_id do
        space
      else
        {:ok, space} = assign_global_id(space)
        space
      end

    content_hash =
      :crypto.hash(:sha256, :erlang.term_to_binary(space.id))
      |> Base.encode16(case: :lower)

    %Manifest{}
    |> Manifest.changeset(%{
      global_id: space.global_id,
      content_hash: content_hash,
      signature: signature,
      signer_key_id: signer_key_id,
      space_id: space.id,
      node_id: node_id,
      payload: %{
        "name" => space.name,
        "visibility" => space.visibility
      }
    })
    |> Repo.insert()
  end

  @doc """
  Gets the manifest for a space's global ID.
  """
  def get_manifest_by_global_id(global_id) do
    Repo.get_by(Manifest, global_id: global_id)
    |> case do
      nil -> nil
      manifest -> Repo.preload(manifest, [:space, :node])
    end
  end

  @doc """
  Lists manifests, optionally filtered by node.
  """
  def list_manifests(opts \\ []) do
    node_id = Keyword.get(opts, :node_id, nil)
    limit = Keyword.get(opts, :limit, 100)

    query =
      from(m in Manifest,
        order_by: [desc: m.inserted_at],
        limit: ^limit,
        preload: [:space]
      )

    query =
      if node_id do
        from(m in query, where: m.node_id == ^node_id)
      else
        query
      end

    Repo.all(query)
  end

  # ===========================================================================
  # Sync
  # ===========================================================================

  @doc """
  Records a sync entry for tracking push/pull operations.
  """
  def record_sync(attrs) do
    %SyncEntry{}
    |> SyncEntry.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Marks a sync entry as completed.
  """
  def complete_sync(%SyncEntry{} = entry) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    entry
    |> SyncEntry.changeset(%{status: "completed", completed_at: now})
    |> Repo.update()
  end

  @doc """
  Marks a sync entry as failed with an error message.
  """
  def fail_sync(%SyncEntry{} = entry, error_message) do
    entry
    |> SyncEntry.changeset(%{status: "failed", error_message: error_message})
    |> Repo.update()
  end

  @doc """
  Lists recent sync entries for a node.
  """
  def list_sync_entries(node_id, opts \\ []) do
    limit = Keyword.get(opts, :limit, 50)

    from(s in SyncEntry,
      where: s.node_id == ^node_id,
      order_by: [desc: s.inserted_at],
      limit: ^limit
    )
    |> Repo.all()
  end

  @doc """
  Returns pending sync entries for a node (resources that need to be synced).
  """
  def pending_syncs(node_id) do
    from(s in SyncEntry,
      where: s.node_id == ^node_id and s.status == "pending",
      order_by: [asc: s.inserted_at]
    )
    |> Repo.all()
  end

  # ===========================================================================
  # Internal
  # ===========================================================================

  defp node_host do
    System.get_env("FEDERATION_NODE_URL", "")
    |> URI.parse()
    |> Map.get(:host)
    |> case do
      nil -> Application.get_env(:cyanea, CyaneaWeb.Endpoint)[:url][:host] || "localhost"
      host -> host
    end
  end
end
