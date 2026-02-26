defmodule CyaneaWeb.FederationLive.NodeShow do
  use CyaneaWeb, :live_view

  alias Cyanea.Federation

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    node = Federation.get_node!(id)
    sync_entries = Federation.list_sync_entries(id, limit: 50)
    stats = Federation.node_sync_stats(id)

    {:ok,
     assign(socket,
       page_title: "Node — #{node.name}",
       node: node,
       sync_entries: sync_entries,
       stats: stats
     )}
  end

  @impl true
  def handle_event("check-health", _params, socket) do
    node = socket.assigns.node

    case Federation.check_node_health(node) do
      :ok ->
        {:noreply, put_flash(socket, :info, "Node is healthy and reachable.")}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Health check failed: #{reason}")}
    end
  end

  def handle_event("trigger-sync", _params, socket) do
    node = socket.assigns.node

    %{node_id: node.id}
    |> Cyanea.Workers.SyncPullWorker.new()
    |> Oban.insert()

    {:noreply, put_flash(socket, :info, "Sync pull enqueued for #{node.name}.")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-3xl">
      <.header>
        <%= @node.name %>
        <:subtitle><%= @node.url %></:subtitle>
      </.header>

      <%!-- Node info --%>
      <div class="mt-8 grid gap-4 sm:grid-cols-4">
        <div class="rounded-xl border border-slate-200 bg-white p-4 shadow-sm dark:border-slate-700 dark:bg-slate-800">
          <p class="text-xs text-slate-500">Status</p>
          <p class="mt-1 font-semibold">
            <.status_badge status={@node.status} />
          </p>
        </div>
        <div class="rounded-xl border border-slate-200 bg-white p-4 shadow-sm dark:border-slate-700 dark:bg-slate-800">
          <p class="text-xs text-slate-500">Total Syncs</p>
          <p class="mt-1 text-lg font-bold text-slate-900 dark:text-white"><%= @stats.total %></p>
        </div>
        <div class="rounded-xl border border-slate-200 bg-white p-4 shadow-sm dark:border-slate-700 dark:bg-slate-800">
          <p class="text-xs text-slate-500">Completed</p>
          <p class="mt-1 text-lg font-bold text-green-600"><%= @stats.completed %></p>
        </div>
        <div class="rounded-xl border border-slate-200 bg-white p-4 shadow-sm dark:border-slate-700 dark:bg-slate-800">
          <p class="text-xs text-slate-500">Failed</p>
          <p class="mt-1 text-lg font-bold text-red-600"><%= @stats.failed %></p>
        </div>
      </div>

      <%!-- Actions --%>
      <div class="mt-6 flex gap-3">
        <button
          phx-click="check-health"
          class="rounded-lg border border-slate-200 px-4 py-2 text-sm font-medium text-slate-700 hover:bg-slate-50 dark:border-slate-600 dark:text-slate-300 dark:hover:bg-slate-700"
        >
          Check Health
        </button>
        <button
          :if={@node.status == "active"}
          phx-click="trigger-sync"
          class="rounded-lg bg-primary px-4 py-2 text-sm font-medium text-white hover:bg-primary/90"
        >
          Trigger Sync Pull
        </button>
      </div>

      <%!-- Node Details --%>
      <div class="mt-8 rounded-xl border border-slate-200 bg-white p-8 shadow-sm dark:border-slate-700 dark:bg-slate-800">
        <h3 class="text-lg font-semibold text-slate-900 dark:text-white">Details</h3>
        <dl class="mt-4 space-y-3 text-sm">
          <div class="flex justify-between">
            <dt class="text-slate-500">Registered</dt>
            <dd class="text-slate-900 dark:text-white"><%= Calendar.strftime(@node.inserted_at, "%B %d, %Y %H:%M UTC") %></dd>
          </div>
          <div class="flex justify-between">
            <dt class="text-slate-500">Last Sync</dt>
            <dd class="text-slate-900 dark:text-white">
              <%= if @node.last_sync_at, do: Calendar.strftime(@node.last_sync_at, "%B %d, %Y %H:%M UTC"), else: "Never" %>
            </dd>
          </div>
          <div :if={@node.public_key} class="flex justify-between">
            <dt class="text-slate-500">Public Key</dt>
            <dd class="font-mono text-xs text-slate-900 dark:text-white truncate max-w-xs"><%= @node.public_key %></dd>
          </div>
          <div class="flex justify-between">
            <dt class="text-slate-500">Data Transferred</dt>
            <dd class="text-slate-900 dark:text-white"><%= format_bytes(@stats.bytes_transferred) %></dd>
          </div>
        </dl>
      </div>

      <%!-- Sync Log --%>
      <div class="mt-8 rounded-xl border border-slate-200 bg-white p-8 shadow-sm dark:border-slate-700 dark:bg-slate-800">
        <h3 class="text-lg font-semibold text-slate-900 dark:text-white">Sync Log</h3>
        <div :if={@sync_entries != []} class="mt-4">
          <table class="w-full text-sm">
            <thead>
              <tr class="border-b border-slate-100 text-left text-xs text-slate-500 dark:border-slate-700">
                <th class="pb-2">Direction</th>
                <th class="pb-2">Type</th>
                <th class="pb-2">Status</th>
                <th class="pb-2">Time</th>
                <th class="pb-2">Error</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-50 dark:divide-slate-700">
              <tr :for={entry <- @sync_entries} class="text-slate-700 dark:text-slate-300">
                <td class="py-2">
                  <span class={"inline-flex items-center rounded px-1.5 py-0.5 text-xs font-medium " <>
                    if(entry.direction == "push", do: "bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-400", else: "bg-purple-100 text-purple-700 dark:bg-purple-900/30 dark:text-purple-400")}>
                    <%= entry.direction %>
                  </span>
                </td>
                <td class="py-2"><%= entry.resource_type %></td>
                <td class="py-2">
                  <.sync_status_badge status={entry.status} />
                </td>
                <td class="py-2 text-xs text-slate-400">
                  <%= if entry.inserted_at, do: Calendar.strftime(entry.inserted_at, "%m/%d %H:%M"), else: "-" %>
                </td>
                <td class="py-2 text-xs text-red-500 truncate max-w-[200px]">
                  <%= entry.error_message %>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        <p :if={@sync_entries == []} class="mt-4 text-sm text-slate-500">
          No sync operations recorded yet.
        </p>
      </div>

      <div class="mt-6">
        <.link navigate={~p"/federation"} class="text-sm text-primary hover:underline">
          Back to Federation Dashboard
        </.link>
      </div>
    </div>
    """
  end

  defp status_badge(assigns) do
    {color, label} =
      case assigns.status do
        "active" -> {"bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400", "Active"}
        "pending" -> {"bg-amber-100 text-amber-700 dark:bg-amber-900/30 dark:text-amber-400", "Pending"}
        "inactive" -> {"bg-slate-100 text-slate-700 dark:bg-slate-700 dark:text-slate-300", "Inactive"}
        "revoked" -> {"bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-400", "Revoked"}
        _ -> {"bg-slate-100 text-slate-500", assigns.status}
      end

    assigns = assign(assigns, color: color, label: label)

    ~H"""
    <span class={"inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium " <> @color}>
      <%= @label %>
    </span>
    """
  end

  defp sync_status_badge(assigns) do
    {color, label} =
      case assigns.status do
        "completed" -> {"bg-green-100 text-green-700", "completed"}
        "pending" -> {"bg-amber-100 text-amber-700", "pending"}
        "in_progress" -> {"bg-blue-100 text-blue-700", "in progress"}
        "failed" -> {"bg-red-100 text-red-700", "failed"}
        _ -> {"bg-slate-100 text-slate-500", assigns.status}
      end

    assigns = assign(assigns, color: color, label: label)

    ~H"""
    <span class={"inline-flex items-center rounded px-1.5 py-0.5 text-xs font-medium " <> @color}>
      <%= @label %>
    </span>
    """
  end

  defp format_bytes(bytes) when is_integer(bytes) and bytes < 1_048_576 do
    kb = Float.round(bytes / 1_024, 1)
    "#{kb} KB"
  end

  defp format_bytes(bytes) when is_integer(bytes) and bytes < 1_073_741_824 do
    mb = Float.round(bytes / 1_048_576, 1)
    "#{mb} MB"
  end

  defp format_bytes(bytes) when is_integer(bytes) do
    gb = Float.round(bytes / 1_073_741_824, 1)
    "#{gb} GB"
  end

  defp format_bytes(_), do: "0 KB"
end
