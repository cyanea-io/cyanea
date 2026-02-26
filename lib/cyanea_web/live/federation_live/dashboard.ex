defmodule CyaneaWeb.FederationLive.Dashboard do
  use CyaneaWeb, :live_view

  alias Cyanea.Federation

  @impl true
  def mount(_params, _session, socket) do
    nodes = Federation.list_nodes()
    published = Federation.list_published_spaces(limit: 20)
    total_bytes = Federation.total_bytes_synced()

    {:ok,
     assign(socket,
       page_title: "Federation",
       nodes: nodes,
       published_spaces: published,
       total_bytes_synced: total_bytes,
       node_form: to_form(%{"name" => "", "url" => ""})
     )}
  end

  @impl true
  def handle_event("register-node", %{"name" => name, "url" => url}, socket) do
    case Federation.register_node(%{name: name, url: url}) do
      {:ok, _node} ->
        nodes = Federation.list_nodes()

        {:noreply,
         socket
         |> put_flash(:info, "Node registered successfully.")
         |> assign(nodes: nodes, node_form: to_form(%{"name" => "", "url" => ""}))}

      {:error, changeset} ->
        errors = format_changeset_errors(changeset)
        {:noreply, put_flash(socket, :error, "Failed to register node: #{errors}")}
    end
  end

  def handle_event("activate-node", %{"id" => id}, socket) do
    node = Federation.get_node!(id)

    case Federation.activate_node(node) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Node activated.")
         |> assign(nodes: Federation.list_nodes())}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to activate node.")}
    end
  end

  def handle_event("deactivate-node", %{"id" => id}, socket) do
    node = Federation.get_node!(id)

    case Federation.deactivate_node(node) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Node deactivated.")
         |> assign(nodes: Federation.list_nodes())}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to deactivate node.")}
    end
  end

  def handle_event("revoke-node", %{"id" => id}, socket) do
    node = Federation.get_node!(id)

    case Federation.revoke_node(node) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Node revoked.")
         |> assign(nodes: Federation.list_nodes())}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to revoke node.")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-4xl">
      <.header>
        Federation
        <:subtitle>Manage federated nodes and view sync status.</:subtitle>
      </.header>

      <%!-- Stats --%>
      <div class="mt-8 grid gap-4 sm:grid-cols-3">
        <div class="rounded-xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-700 dark:bg-slate-800">
          <p class="text-sm text-slate-500">Connected Nodes</p>
          <p class="mt-1 text-2xl font-bold text-slate-900 dark:text-white">
            <%= Enum.count(@nodes, &(&1.status == "active")) %>
          </p>
        </div>
        <div class="rounded-xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-700 dark:bg-slate-800">
          <p class="text-sm text-slate-500">Published Spaces</p>
          <p class="mt-1 text-2xl font-bold text-slate-900 dark:text-white">
            <%= length(@published_spaces) %>
          </p>
        </div>
        <div class="rounded-xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-700 dark:bg-slate-800">
          <p class="text-sm text-slate-500">Data Synced</p>
          <p class="mt-1 text-2xl font-bold text-slate-900 dark:text-white">
            <%= format_bytes(@total_bytes_synced) %>
          </p>
        </div>
      </div>

      <%!-- Nodes --%>
      <div class="mt-8 rounded-xl border border-slate-200 bg-white p-8 shadow-sm dark:border-slate-700 dark:bg-slate-800">
        <h3 class="text-lg font-semibold text-slate-900 dark:text-white">Federation Nodes</h3>

        <div :if={@nodes != []} class="mt-4 divide-y divide-slate-100 dark:divide-slate-700">
          <div :for={node <- @nodes} class="flex items-center justify-between py-3">
            <div>
              <div class="flex items-center gap-2">
                <.node_status_dot status={node.status} />
                <span class="font-medium text-slate-900 dark:text-white"><%= node.name %></span>
              </div>
              <p class="mt-0.5 text-xs text-slate-500"><%= node.url %></p>
              <p :if={node.last_sync_at} class="text-xs text-slate-400">
                Last sync: <%= format_relative(node.last_sync_at) %>
              </p>
            </div>
            <div class="flex items-center gap-2">
              <.link
                navigate={~p"/federation/nodes/#{node.id}"}
                class="text-sm text-primary hover:underline"
              >
                Details
              </.link>
              <button
                :if={node.status == "pending"}
                phx-click="activate-node"
                phx-value-id={node.id}
                class="rounded-md bg-green-100 px-2 py-1 text-xs font-medium text-green-700 hover:bg-green-200"
              >
                Activate
              </button>
              <button
                :if={node.status == "active"}
                phx-click="deactivate-node"
                phx-value-id={node.id}
                class="rounded-md bg-amber-100 px-2 py-1 text-xs font-medium text-amber-700 hover:bg-amber-200"
              >
                Deactivate
              </button>
              <button
                :if={node.status in ~w(pending active inactive)}
                phx-click="revoke-node"
                phx-value-id={node.id}
                data-confirm="Revoke this node? This will permanently remove its federation access."
                class="rounded-md bg-red-100 px-2 py-1 text-xs font-medium text-red-700 hover:bg-red-200"
              >
                Revoke
              </button>
            </div>
          </div>
        </div>

        <p :if={@nodes == []} class="mt-4 text-sm text-slate-500">
          No federation nodes registered yet.
        </p>

        <%!-- Register new node --%>
        <div class="mt-6 border-t border-slate-100 pt-6 dark:border-slate-700">
          <h4 class="text-sm font-medium text-slate-900 dark:text-white">Register a new node</h4>
          <form phx-submit="register-node" class="mt-3 flex items-end gap-3">
            <div class="flex-1">
              <label class="block text-xs text-slate-500">Name</label>
              <input
                type="text"
                name="name"
                value={@node_form.params["name"]}
                required
                class="mt-1 w-full rounded-md border border-slate-300 px-3 py-1.5 text-sm dark:border-slate-600 dark:bg-slate-700 dark:text-white"
                placeholder="Lab Node"
              />
            </div>
            <div class="flex-1">
              <label class="block text-xs text-slate-500">URL</label>
              <input
                type="url"
                name="url"
                value={@node_form.params["url"]}
                required
                class="mt-1 w-full rounded-md border border-slate-300 px-3 py-1.5 text-sm dark:border-slate-600 dark:bg-slate-700 dark:text-white"
                placeholder="https://node.example.com"
              />
            </div>
            <button
              type="submit"
              class="rounded-md bg-primary px-4 py-1.5 text-sm font-medium text-white hover:bg-primary/90"
            >
              Register
            </button>
          </form>
        </div>
      </div>

      <%!-- Published Spaces --%>
      <div class="mt-8 rounded-xl border border-slate-200 bg-white p-8 shadow-sm dark:border-slate-700 dark:bg-slate-800">
        <h3 class="text-lg font-semibold text-slate-900 dark:text-white">Published Spaces</h3>
        <div :if={@published_spaces != []} class="mt-4 divide-y divide-slate-100 dark:divide-slate-700">
          <div :for={{space, manifest} <- @published_spaces} class="flex items-center justify-between py-3">
            <div>
              <span class="font-medium text-slate-900 dark:text-white"><%= space.name %></span>
              <p class="text-xs text-slate-500"><%= manifest.global_id %></p>
            </div>
            <div class="flex items-center gap-2">
              <span class="inline-flex items-center rounded-full bg-green-100 px-2 py-0.5 text-xs font-medium text-green-700 dark:bg-green-900/30 dark:text-green-400">
                Published
              </span>
              <span :if={manifest.revision_number} class="text-xs text-slate-400">
                v<%= manifest.revision_number %>
              </span>
            </div>
          </div>
        </div>
        <p :if={@published_spaces == []} class="mt-4 text-sm text-slate-500">
          No spaces published yet. Publish a space from its page to share it with the network.
        </p>
      </div>
    </div>
    """
  end

  defp node_status_dot(assigns) do
    color =
      case assigns.status do
        "active" -> "bg-green-500"
        "pending" -> "bg-amber-500"
        "inactive" -> "bg-slate-400"
        "revoked" -> "bg-red-500"
        _ -> "bg-slate-300"
      end

    assigns = assign(assigns, :color, color)

    ~H"""
    <span class={"inline-block h-2 w-2 rounded-full " <> @color} />
    """
  end

  defp format_bytes(bytes) when bytes < 1_048_576 do
    kb = Float.round(bytes / 1_024, 1)
    "#{kb} KB"
  end

  defp format_bytes(bytes) when bytes < 1_073_741_824 do
    mb = Float.round(bytes / 1_048_576, 1)
    "#{mb} MB"
  end

  defp format_bytes(bytes) do
    gb = Float.round(bytes / 1_073_741_824, 1)
    "#{gb} GB"
  end

  defp format_relative(datetime) do
    diff = DateTime.diff(DateTime.utc_now(), datetime, :minute)

    cond do
      diff < 1 -> "just now"
      diff < 60 -> "#{diff}m ago"
      diff < 1440 -> "#{div(diff, 60)}h ago"
      true -> "#{div(diff, 1440)}d ago"
    end
  end

  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
    |> Enum.map_join(", ", fn {field, msgs} -> "#{field}: #{Enum.join(msgs, ", ")}" end)
  end
end
