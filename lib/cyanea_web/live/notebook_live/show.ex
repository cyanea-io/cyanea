defmodule CyaneaWeb.NotebookLive.Show do
  use CyaneaWeb, :live_view

  alias Cyanea.Notebooks
  alias Cyanea.Notebooks.Execution
  alias CyaneaWeb.ContentHelpers
  alias CyaneaWeb.Markdown
  alias CyaneaWeb.NotebookPresence

  @impl true
  def mount(%{"notebook_slug" => notebook_slug} = params, _session, socket) do
    case ContentHelpers.mount_space(socket, params) do
      {:ok, socket} ->
        space = socket.assigns.space
        notebook = Notebooks.get_notebook_by_slug(space.id, notebook_slug)

        if notebook do
          collab_topic = "notebook:#{notebook.id}"

          if connected?(socket) do
            Phoenix.PubSub.subscribe(Cyanea.PubSub, collab_topic)
            track_presence(socket, collab_topic, notebook.id)
          end

          # Load persisted execution results for server-side cells
          persisted_outputs = Notebooks.load_execution_results(notebook.id)

          {:ok,
           socket
           |> assign(
             page_title: notebook.title,
             notebook: notebook,
             cells: Notebooks.get_cells(notebook),
             editing_cell_id: nil,
             save_status: :saved,
             cell_outputs: persisted_outputs,
             running_cells: MapSet.new(),
             # Versioning
             versions: [],
             show_versions: false,
             version_diff: nil,
             # Collaboration
             collab_topic: collab_topic,
             presences: []
           )}
        else
          {:ok,
           socket
           |> put_flash(:error, "Notebook not found.")
           |> redirect(to: ~p"/#{socket.assigns.owner_name}/#{space.slug}")}
        end

      {:error, socket} ->
        {:ok, socket}
    end
  end

  defp track_presence(socket, topic, _notebook_id) do
    user = socket.assigns[:current_user]

    if user do
      NotebookPresence.track(self(), topic, user.id, %{
        username: user.username,
        avatar_url: user.avatar_url,
        editing_cell_id: nil,
        joined_at: System.system_time(:second)
      })
    end
  rescue
    # Presence may not be started in test env
    _ -> :ok
  end

  # ── Cell CRUD Events ──────────────────────────────────────────────────

  @impl true
  def handle_event("add-cell", %{"type" => type} = params, socket) do
    position = if params["position"], do: String.to_integer(params["position"]), else: nil

    case Notebooks.add_cell(socket.assigns.notebook, type, position) do
      {:ok, notebook} ->
        broadcast_change(socket, :cells_changed)

        {:noreply,
         socket
         |> assign(notebook: notebook, cells: Notebooks.get_cells(notebook))
         |> assign(save_status: :saved)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to add cell.")}
    end
  end

  def handle_event("delete-cell", %{"cell-id" => cell_id}, socket) do
    case Notebooks.remove_cell(socket.assigns.notebook, cell_id) do
      {:ok, notebook} ->
        broadcast_change(socket, :cells_changed)

        {:noreply,
         socket
         |> assign(notebook: notebook, cells: Notebooks.get_cells(notebook))
         |> assign(editing_cell_id: nil, save_status: :saved)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to delete cell.")}
    end
  end

  def handle_event("move-cell", %{"cell-id" => cell_id, "direction" => direction}, socket) do
    direction = String.to_existing_atom(direction)

    case Notebooks.move_cell(socket.assigns.notebook, cell_id, direction) do
      {:ok, notebook} ->
        broadcast_change(socket, :cells_changed)

        {:noreply,
         socket
         |> assign(notebook: notebook, cells: Notebooks.get_cells(notebook))
         |> assign(save_status: :saved)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to move cell.")}
    end
  end

  def handle_event("edit-cell", %{"cell-id" => cell_id}, socket) do
    update_presence_editing(socket, cell_id)
    {:noreply, assign(socket, editing_cell_id: cell_id)}
  end

  def handle_event("finish-edit", _params, socket) do
    update_presence_editing(socket, nil)
    {:noreply, assign(socket, editing_cell_id: nil)}
  end

  def handle_event("update-cell", %{"cell-id" => cell_id, "source" => source}, socket) do
    case Notebooks.update_cell(socket.assigns.notebook, cell_id, %{"source" => source}) do
      {:ok, notebook} ->
        broadcast_change(socket, {:cell_updated, %{cell_id: cell_id, source: source}})

        {:noreply,
         socket
         |> assign(notebook: notebook, cells: Notebooks.get_cells(notebook))
         |> assign(save_status: :saved)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to update cell.")}
    end
  end

  def handle_event(
        "update-cell-language",
        %{"cell-id" => cell_id, "language" => language},
        socket
      ) do
    case Notebooks.update_cell(socket.assigns.notebook, cell_id, %{"language" => language}) do
      {:ok, notebook} ->
        {:noreply,
         socket
         |> assign(notebook: notebook, cells: Notebooks.get_cells(notebook))
         |> assign(save_status: :saved)}

      {:error, _changeset} ->
        {:noreply, socket}
    end
  end

  # ── Execution Events ──────────────────────────────────────────────────

  def handle_event("run-cell", %{"cell-id" => cell_id}, socket) do
    cell = Enum.find(socket.assigns.cells, &(&1["id"] == cell_id))

    if cell && Notebooks.executable_cell?(cell) do
      language = cell["language"]

      case Execution.execution_target(language) do
        :wasm ->
          # Client-side execution via Web Worker
          {:noreply,
           socket
           |> update(:running_cells, &MapSet.put(&1, cell_id))
           |> push_event("execute-cell", %{cell_id: cell_id, source: cell["source"] || ""})}

        :server ->
          # Server-side execution via Oban
          user = socket.assigns[:current_user]

          %{
            notebook_id: socket.assigns.notebook.id,
            cell_id: cell_id,
            source: cell["source"] || "",
            language: language,
            user_id: user && user.id
          }
          |> Cyanea.Workers.CellExecutionWorker.new()
          |> Oban.insert()

          {:noreply, update(socket, :running_cells, &MapSet.put(&1, cell_id))}

        :server_coming_soon ->
          output = %{
            "type" => "error",
            "data" => "#{String.capitalize(language)} execution is coming soon.",
            "timing_ms" => 0
          }

          {:noreply,
           socket
           |> update(:cell_outputs, &Map.put(&1, cell_id, output))}
      end
    else
      {:noreply, socket}
    end
  end

  def handle_event("run-all", _params, socket) do
    # Create a version before run-all
    user = socket.assigns[:current_user]
    Notebooks.create_version(socket.assigns.notebook, "run_all", user && user.id, "Run all")

    executable_cells =
      socket.assigns.cells
      |> Enum.filter(&Notebooks.executable_cell?/1)

    # Split by execution target
    {wasm_cells, server_cells} =
      Enum.split_with(executable_cells, fn cell ->
        Execution.execution_target(cell["language"]) == :wasm
      end)

    # Queue WASM cells for client-side execution
    wasm_data = Enum.map(wasm_cells, &%{id: &1["id"], source: &1["source"] || ""})

    # Enqueue server cells via Oban
    user_id = user && user.id

    for cell <- server_cells do
      case Execution.execution_target(cell["language"]) do
        :server ->
          %{
            notebook_id: socket.assigns.notebook.id,
            cell_id: cell["id"],
            source: cell["source"] || "",
            language: cell["language"],
            user_id: user_id
          }
          |> Cyanea.Workers.CellExecutionWorker.new()
          |> Oban.insert()

        :server_coming_soon ->
          :skip
      end
    end

    running_ids =
      executable_cells
      |> Enum.filter(fn cell ->
        Execution.execution_target(cell["language"]) in [:wasm, :server]
      end)
      |> Enum.map(& &1["id"])
      |> MapSet.new()

    {:noreply,
     socket
     |> assign(running_cells: running_ids)
     |> push_event("execute-all", %{cells: wasm_data})}
  end

  def handle_event("clear-outputs", _params, socket) do
    {:noreply, assign(socket, cell_outputs: %{}, running_cells: MapSet.new())}
  end

  def handle_event("cell-result", %{"cell-id" => cell_id, "output" => output}, socket) do
    {:noreply,
     socket
     |> update(:cell_outputs, &Map.put(&1, cell_id, output))
     |> update(:running_cells, &MapSet.delete(&1, cell_id))}
  end

  def handle_event("auto-save", _params, socket) do
    {:noreply,
     socket
     |> push_event("auto-save-done", %{})
     |> assign(save_status: :saved)}
  end

  # ── Versioning Events ──────────────────────────────────────────────────

  def handle_event("create-checkpoint", _params, socket) do
    user = socket.assigns[:current_user]

    case Notebooks.create_version(
           socket.assigns.notebook,
           "checkpoint",
           user && user.id,
           "Checkpoint"
         ) do
      {:ok, _version} ->
        versions = Notebooks.list_versions(socket.assigns.notebook.id)
        {:noreply, assign(socket, versions: versions)}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to create checkpoint.")}
    end
  end

  def handle_event("toggle-versions", _params, socket) do
    show = !socket.assigns.show_versions

    versions =
      if show,
        do: Notebooks.list_versions(socket.assigns.notebook.id),
        else: socket.assigns.versions

    {:noreply, assign(socket, show_versions: show, versions: versions, version_diff: nil)}
  end

  def handle_event("view-version-diff", %{"version-id" => version_id}, socket) do
    version = Notebooks.get_version!(version_id)
    current_content = socket.assigns.notebook.content || %{}

    diff = Cyanea.Notebooks.VersionDiff.diff(version.content, current_content)
    {:noreply, assign(socket, version_diff: %{version: version, changes: diff})}
  end

  def handle_event("close-diff", _params, socket) do
    {:noreply, assign(socket, version_diff: nil)}
  end

  def handle_event("restore-version", %{"version-id" => version_id}, socket) do
    user = socket.assigns[:current_user]

    case Notebooks.restore_version(socket.assigns.notebook, version_id, user && user.id) do
      {:ok, notebook} ->
        broadcast_change(socket, :cells_changed)
        versions = Notebooks.list_versions(notebook.id)

        {:noreply,
         socket
         |> assign(
           notebook: notebook,
           cells: Notebooks.get_cells(notebook),
           versions: versions,
           version_diff: nil,
           save_status: :saved
         )
         |> put_flash(:info, "Notebook restored to previous version.")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to restore version.")}
    end
  end

  # ── PubSub / Presence Handlers ─────────────────────────────────────────

  @impl true
  def handle_info({:cell_result, %{cell_id: cell_id, output: output}}, socket) do
    {:noreply,
     socket
     |> update(:cell_outputs, &Map.put(&1, cell_id, output))
     |> update(:running_cells, &MapSet.delete(&1, cell_id))}
  end

  def handle_info({:cell_updated, %{cell_id: cell_id, source: source}}, socket) do
    # Reload notebook from DB to get the latest content
    notebook = Notebooks.get_notebook!(socket.assigns.notebook.id)

    {:noreply,
     socket
     |> assign(notebook: notebook, cells: Notebooks.get_cells(notebook))
     |> push_event("remote-cell-update", %{cell_id: cell_id, source: source})}
  end

  def handle_info(:cells_changed, socket) do
    notebook = Notebooks.get_notebook!(socket.assigns.notebook.id)

    {:noreply,
     socket
     |> assign(notebook: notebook, cells: Notebooks.get_cells(notebook))}
  end

  def handle_info(%Phoenix.Socket.Broadcast{event: "presence_diff"}, socket) do
    presences =
      NotebookPresence.list(socket.assigns.collab_topic)
      |> Enum.map(fn {_id, %{metas: [meta | _]}} -> meta end)

    {:noreply, assign(socket, presences: presences)}
  end

  def handle_info(_msg, socket), do: {:noreply, socket}

  # ── Broadcast Helpers ──────────────────────────────────────────────────

  defp broadcast_change(socket, message) do
    topic = socket.assigns[:collab_topic]

    if topic do
      Phoenix.PubSub.broadcast_from(Cyanea.PubSub, self(), topic, message)
    end
  end

  defp update_presence_editing(socket, cell_id) do
    user = socket.assigns[:current_user]
    topic = socket.assigns[:collab_topic]

    if user && topic do
      try do
        NotebookPresence.update(self(), topic, user.id, fn meta ->
          Map.put(meta, :editing_cell_id, cell_id)
        end)
      rescue
        _ -> :ok
      end
    end
  end

  # ── Render ─────────────────────────────────────────────────────────────

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <%!-- Breadcrumb --%>
      <div class="flex items-center justify-between">
        <.breadcrumb>
          <:crumb navigate={~p"/#{@owner_name}"}><%= @owner_name %></:crumb>
          <:crumb navigate={~p"/#{@owner_name}/#{@space.slug}"}><%= @space.name %></:crumb>
          <:crumb><%= @notebook.title %></:crumb>
        </.breadcrumb>
        <div class="flex items-center gap-3">
          <%!-- Presence indicators --%>
          <div :if={length(@presences) > 1} class="flex items-center gap-1">
            <div
              :for={p <- Enum.take(@presences, 5)}
              class="h-7 w-7 rounded-full bg-primary/20 text-primary text-xs font-medium flex items-center justify-center"
              title={p.username}
            >
              <%= String.first(p.username || "?") |> String.upcase() %>
            </div>
            <span :if={length(@presences) > 5} class="text-xs text-slate-500">
              +<%= length(@presences) - 5 %>
            </span>
            <span class="text-xs text-slate-500 ml-1">
              <%= length(@presences) %> viewing
            </span>
          </div>
          <.status_indicator
            :if={@is_owner}
            status={save_status_to_indicator(@save_status)}
            label={save_status_label(@save_status)}
          />
        </div>
      </div>

      <%!-- Notebook toolbar --%>
      <div :if={@is_owner && has_executable_cells?(@cells)} class="mt-4 flex items-center gap-2">
        <button
          phx-click="run-all"
          class="inline-flex items-center gap-1.5 rounded-lg bg-primary px-3 py-1.5 text-sm font-medium text-white hover:bg-primary/90 transition"
        >
          <.icon name="hero-play" class="h-4 w-4" /> Run All
        </button>
        <button
          :if={@cell_outputs != %{}}
          phx-click="clear-outputs"
          class="inline-flex items-center gap-1.5 rounded-lg border border-slate-200 px-3 py-1.5 text-sm hover:bg-slate-50 dark:border-slate-700 dark:hover:bg-slate-800"
        >
          <.icon name="hero-x-mark" class="h-4 w-4" /> Clear Outputs
        </button>
        <button
          phx-click="create-checkpoint"
          class="inline-flex items-center gap-1.5 rounded-lg border border-slate-200 px-3 py-1.5 text-sm hover:bg-slate-50 dark:border-slate-700 dark:hover:bg-slate-800"
        >
          <.icon name="hero-bookmark" class="h-4 w-4" /> Checkpoint
        </button>
        <button
          phx-click="toggle-versions"
          class={"inline-flex items-center gap-1.5 rounded-lg border px-3 py-1.5 text-sm transition #{if @show_versions, do: "border-primary bg-primary/5 text-primary", else: "border-slate-200 hover:bg-slate-50 dark:border-slate-700 dark:hover:bg-slate-800"}"}
        >
          <.icon name="hero-clock" class="h-4 w-4" /> Versions
        </button>
      </div>

      <%!-- Version history panel --%>
      <div
        :if={@show_versions}
        class="mt-4 rounded-lg border border-slate-200 bg-white p-4 dark:border-slate-700 dark:bg-slate-900"
      >
        <div class="flex items-center justify-between mb-3">
          <h3 class="text-sm font-semibold text-slate-800 dark:text-slate-200">Version History</h3>
          <button
            phx-click="toggle-versions"
            class="text-slate-400 hover:text-slate-600 dark:hover:text-slate-300"
          >
            <.icon name="hero-x-mark" class="h-4 w-4" />
          </button>
        </div>

        <%= if @versions == [] do %>
          <p class="text-sm text-slate-500">No versions yet. Use Checkpoint to create one.</p>
        <% else %>
          <div class="space-y-2 max-h-64 overflow-y-auto">
            <div
              :for={version <- @versions}
              class="flex items-center justify-between rounded-lg border border-slate-100 px-3 py-2 dark:border-slate-800"
            >
              <div>
                <span class="text-sm font-medium text-slate-700 dark:text-slate-300">
                  v<%= version.number %>
                </span>
                <span :if={version.label} class="ml-2 text-xs text-slate-500">
                  <%= version.label %>
                </span>
                <span class="ml-2 text-xs text-slate-400">
                  <%= version.trigger %>
                </span>
                <span :if={version.author} class="ml-2 text-xs text-slate-400">
                  by <%= version.author.username %>
                </span>
                <span class="ml-2 text-[10px] text-slate-400">
                  <%= Calendar.strftime(version.created_at, "%b %d, %H:%M") %>
                </span>
              </div>
              <div class="flex items-center gap-1">
                <button
                  phx-click="view-version-diff"
                  phx-value-version-id={version.id}
                  class="rounded px-2 py-1 text-xs text-slate-500 hover:bg-slate-100 dark:hover:bg-slate-800"
                >
                  Diff
                </button>
                <button
                  phx-click="restore-version"
                  phx-value-version-id={version.id}
                  data-confirm="Restore to version #{version.number}? Current content will be saved as a new version first."
                  class="rounded px-2 py-1 text-xs text-primary hover:bg-primary/5"
                >
                  Restore
                </button>
              </div>
            </div>
          </div>
        <% end %>
      </div>

      <%!-- Version diff panel --%>
      <div
        :if={@version_diff}
        class="mt-4 rounded-lg border border-slate-200 bg-white p-4 dark:border-slate-700 dark:bg-slate-900"
      >
        <div class="flex items-center justify-between mb-3">
          <h3 class="text-sm font-semibold text-slate-800 dark:text-slate-200">
            Changes since v<%= @version_diff.version.number %>
          </h3>
          <button
            phx-click="close-diff"
            class="text-slate-400 hover:text-slate-600 dark:hover:text-slate-300"
          >
            <.icon name="hero-x-mark" class="h-4 w-4" />
          </button>
        </div>

        <div class="space-y-2 max-h-96 overflow-y-auto">
          <div
            :for={change <- @version_diff.changes}
            class={"rounded-lg border p-3 text-sm #{diff_border_class(change.type)}"}
          >
            <div class="flex items-center gap-2 mb-1">
              <span class={"rounded px-1.5 py-0.5 text-[10px] font-medium #{diff_badge_class(change.type)}"}>
                <%= change.type %>
              </span>
              <span class="text-xs text-slate-500">
                <%= change.cell_type %><%= if change.language, do: " (#{change.language})" %>
              </span>
            </div>
            <div :if={change.type == :modified}>
              <pre class="text-xs text-red-600 dark:text-red-400 line-through mb-1"><%= change.old_source %></pre>
              <pre class="text-xs text-emerald-600 dark:text-emerald-400"><%= change.new_source %></pre>
            </div>
            <div :if={change.type == :added}>
              <pre class="text-xs text-emerald-600 dark:text-emerald-400"><%= change.new_source %></pre>
            </div>
            <div :if={change.type == :removed}>
              <pre class="text-xs text-red-600 dark:text-red-400"><%= change.old_source %></pre>
            </div>
          </div>
        </div>
      </div>

      <%!-- Notebook content --%>
      <div class="mt-6 space-y-4" id="notebook-cells" phx-hook="NotebookExecutor">
        <%= if @cells == [] and @is_owner do %>
          <div class="flex justify-center gap-2">
            <button
              phx-click="add-cell"
              phx-value-type="markdown"
              class="inline-flex items-center gap-1 rounded-lg border border-slate-200 px-3 py-2 text-sm hover:bg-slate-50 dark:border-slate-700 dark:hover:bg-slate-800"
            >
              <.icon name="hero-plus" class="h-4 w-4" /> Markdown
            </button>
            <button
              phx-click="add-cell"
              phx-value-type="code"
              class="inline-flex items-center gap-1 rounded-lg border border-slate-200 px-3 py-2 text-sm hover:bg-slate-50 dark:border-slate-700 dark:hover:bg-slate-800"
            >
              <.icon name="hero-plus" class="h-4 w-4" /> Code
            </button>
          </div>
        <% end %>

        <div :for={cell <- @cells}>
          <%= if @is_owner do %>
            <.cell_editor
              cell={cell}
              editing={@editing_cell_id == cell["id"]}
              owner_name={@owner_name}
              cell_output={@cell_outputs[cell["id"]]}
              running={MapSet.member?(@running_cells, cell["id"])}
              presences={@presences}
            />
          <% else %>
            <.cell_viewer cell={cell} />
          <% end %>

          <%!-- Add cell button between cells (owner only) --%>
          <div :if={@is_owner} class="flex justify-center gap-2 py-1 opacity-0 hover:opacity-100 transition-opacity">
            <button
              phx-click="add-cell"
              phx-value-type="markdown"
              phx-value-position={cell["position"] + 1}
              class="inline-flex items-center gap-1 rounded border border-slate-200 px-2 py-1 text-xs hover:bg-slate-50 dark:border-slate-700 dark:hover:bg-slate-800"
            >
              + Markdown
            </button>
            <button
              phx-click="add-cell"
              phx-value-type="code"
              phx-value-position={cell["position"] + 1}
              class="inline-flex items-center gap-1 rounded border border-slate-200 px-2 py-1 text-xs hover:bg-slate-50 dark:border-slate-700 dark:hover:bg-slate-800"
            >
              + Code
            </button>
          </div>
        </div>
      </div>
    </div>
    """
  end

  # -- Cell Editor (owner view) --

  defp cell_editor(%{cell: %{"type" => "markdown"}} = assigns) do
    ~H"""
    <.card class="group relative">
      <div class="absolute right-2 top-2 flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
        <.cell_toolbar cell_id={@cell["id"]} />
      </div>

      <%= if @editing do %>
        <div class="space-y-2">
          <textarea
            phx-blur="update-cell"
            phx-value-cell-id={@cell["id"]}
            name="source"
            rows={max(3, length(String.split(@cell["source"] || "", "\n")))}
            class="w-full rounded-lg border border-slate-200 bg-slate-50 p-4 font-mono text-sm dark:border-slate-600 dark:bg-slate-900 dark:text-slate-200"
          ><%= @cell["source"] %></textarea>
          <button
            phx-click="finish-edit"
            class="text-xs text-primary hover:text-primary/80"
          >
            Done editing
          </button>
        </div>
      <% else %>
        <div
          phx-click="edit-cell"
          phx-value-cell-id={@cell["id"]}
          class="prose prose-sm max-w-none cursor-pointer dark:prose-invert"
        >
          <%= if @cell["source"] && @cell["source"] != "" do %>
            <%= Markdown.render(@cell["source"]) %>
          <% else %>
            <p class="text-slate-400 italic">Click to edit markdown...</p>
          <% end %>
        </div>
      <% end %>
    </.card>
    """
  end

  defp cell_editor(%{cell: %{"type" => "code"}} = assigns) do
    language = assigns.cell["language"] || "code"
    is_executable = Notebooks.executable_cell?(assigns.cell)
    is_wasm = language == "cyanea"
    is_coming_soon = Execution.execution_target(language) == :server_coming_soon

    assigns =
      assigns
      |> assign(:is_executable, is_executable)
      |> assign(:is_wasm, is_wasm)
      |> assign(:is_coming_soon, is_coming_soon)
      |> assign(:editing_users, cell_editing_users(assigns.presences, assigns.cell["id"]))

    ~H"""
    <.card class="group relative" padding="p-0">
      <%!-- Code cell header --%>
      <div class="flex items-center justify-between border-b border-slate-200 bg-slate-50 px-4 py-1.5 dark:border-slate-700 dark:bg-slate-900/50">
        <div class="flex items-center gap-2">
          <span class="text-xs font-medium text-slate-500">
            <%= String.upcase(@cell["language"] || "code") %>
          </span>
          <span
            :if={@is_coming_soon}
            class="rounded-full bg-amber-100 px-2 py-0.5 text-[10px] font-medium text-amber-600 dark:bg-amber-900/30 dark:text-amber-400"
          >
            Coming soon
          </span>
          <%!-- Show editing users --%>
          <span
            :for={username <- @editing_users}
            class="rounded-full bg-blue-100 px-2 py-0.5 text-[10px] font-medium text-blue-600 dark:bg-blue-900/30 dark:text-blue-400"
          >
            <%= username %> editing
          </span>
        </div>
        <div class="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
          <select
            phx-change="update-cell-language"
            phx-value-cell-id={@cell["id"]}
            name="language"
            class="rounded border border-slate-200 bg-white px-2 py-0.5 text-xs dark:border-slate-600 dark:bg-slate-800"
          >
            <option value="cyanea" selected={@cell["language"] == "cyanea"}>Cyanea</option>
            <option value="elixir" selected={@cell["language"] == "elixir"}>Elixir</option>
            <option value="python" selected={@cell["language"] == "python"}>Python</option>
            <option value="r" selected={@cell["language"] == "r"}>R</option>
            <option value="bash" selected={@cell["language"] == "bash"}>Bash</option>
            <option value="sql" selected={@cell["language"] == "sql"}>SQL</option>
          </select>
          <%= if @is_executable do %>
            <button
              phx-click="run-cell"
              phx-value-cell-id={@cell["id"]}
              class="rounded p-1 text-emerald-600 hover:bg-emerald-50 hover:text-emerald-700 dark:text-emerald-400 dark:hover:bg-emerald-900/20"
              title="Run cell (Shift+Enter)"
            >
              <.icon name="hero-play" class="h-3.5 w-3.5" />
            </button>
          <% end %>
          <.cell_toolbar cell_id={@cell["id"]} />
        </div>
      </div>

      <%!-- Editor area --%>
      <%= if @is_wasm do %>
        <div
          id={"code-editor-#{@cell["id"]}"}
          phx-hook="CodeEditor"
          phx-update="ignore"
          data-cell-id={@cell["id"]}
          data-language={@cell["language"]}
          data-source={@cell["source"] || ""}
          class="min-h-[60px]"
        />
      <% else %>
        <textarea
          phx-blur="update-cell"
          phx-value-cell-id={@cell["id"]}
          name="source"
          rows={max(3, length(String.split(@cell["source"] || "", "\n")))}
          class="w-full border-0 bg-slate-50 p-4 font-mono text-sm focus:ring-0 dark:bg-slate-900 dark:text-slate-200"
          spellcheck="false"
        ><%= @cell["source"] %></textarea>
      <% end %>

      <%!-- Running spinner --%>
      <div
        :if={@running}
        class="flex items-center gap-2 border-t border-slate-200 dark:border-slate-700 bg-slate-50 dark:bg-slate-800/50 px-4 py-2"
      >
        <svg class="h-4 w-4 animate-spin text-primary" viewBox="0 0 24 24" fill="none">
          <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" />
          <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
        </svg>
        <span class="text-xs text-slate-500">Running...</span>
      </div>

      <%!-- Output area --%>
      <div
        :if={@cell_output}
        class="border-t border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-900"
      >
        <div class="flex items-center gap-2 border-b border-slate-100 dark:border-slate-800 px-4 py-1">
          <span class="text-[10px] font-medium text-slate-400">OUTPUT</span>
          <span
            :if={@cell_output["timing_ms"]}
            class="text-[10px] text-slate-400"
          >
            <%= @cell_output["timing_ms"] %>ms
          </span>
        </div>
        <div
          id={"output-#{@cell["id"]}"}
          phx-hook="OutputRenderer"
          data-output={Jason.encode!(@cell_output)}
          class="p-4"
        />
      </div>
    </.card>
    """
  end

  defp cell_editor(assigns) do
    ~H"""
    <.card>
      <pre class="text-sm text-slate-600 dark:text-slate-400"><%= @cell["source"] || @cell["content"] || "" %></pre>
    </.card>
    """
  end

  # -- Cell Viewer (read-only view) --

  defp cell_viewer(%{cell: %{"type" => "markdown"}} = assigns) do
    ~H"""
    <.card>
      <div class="prose prose-sm max-w-none dark:prose-invert">
        <%= Markdown.render(@cell["source"]) %>
      </div>
    </.card>
    """
  end

  defp cell_viewer(%{cell: %{"type" => "code"}} = assigns) do
    ~H"""
    <.card padding="p-0">
      <div class="border-b border-slate-200 bg-slate-50 px-4 py-1.5 dark:border-slate-700 dark:bg-slate-900/50">
        <span class="text-xs font-medium text-slate-500">
          <%= String.upcase(@cell["language"] || "code") %>
        </span>
      </div>
      <pre class="overflow-x-auto p-4 font-mono text-sm text-slate-800 dark:text-slate-200"><code><%= @cell["source"] %></code></pre>
    </.card>
    """
  end

  defp cell_viewer(assigns) do
    ~H"""
    <.card>
      <pre class="text-sm text-slate-600 dark:text-slate-400"><%= @cell["source"] || @cell["content"] || "" %></pre>
    </.card>
    """
  end

  # -- Cell toolbar --

  defp cell_toolbar(assigns) do
    ~H"""
    <button
      phx-click="move-cell"
      phx-value-cell-id={@cell_id}
      phx-value-direction="up"
      class="rounded p-1 text-slate-400 hover:bg-slate-100 hover:text-slate-600 dark:hover:bg-slate-700"
      title="Move up"
    >
      <.icon name="hero-chevron-up" class="h-3.5 w-3.5" />
    </button>
    <button
      phx-click="move-cell"
      phx-value-cell-id={@cell_id}
      phx-value-direction="down"
      class="rounded p-1 text-slate-400 hover:bg-slate-100 hover:text-slate-600 dark:hover:bg-slate-700"
      title="Move down"
    >
      <.icon name="hero-chevron-down" class="h-3.5 w-3.5" />
    </button>
    <button
      phx-click="delete-cell"
      phx-value-cell-id={@cell_id}
      data-confirm="Delete this cell?"
      class="rounded p-1 text-slate-400 hover:bg-red-50 hover:text-red-500 dark:hover:bg-red-900/20"
      title="Delete cell"
    >
      <.icon name="hero-trash" class="h-3.5 w-3.5" />
    </button>
    """
  end

  # -- Helpers --

  defp has_executable_cells?(cells) do
    Enum.any?(cells, &Notebooks.executable_cell?/1)
  end

  defp cell_editing_users(presences, cell_id) do
    presences
    |> Enum.filter(fn p -> p.editing_cell_id == cell_id end)
    |> Enum.map(& &1.username)
  end

  defp save_status_to_indicator(:saved), do: :online
  defp save_status_to_indicator(:saving), do: :syncing
  defp save_status_to_indicator(:unsaved), do: :pending

  defp save_status_label(:saved), do: "Saved"
  defp save_status_label(:saving), do: "Saving..."
  defp save_status_label(:unsaved), do: "Unsaved changes"

  defp diff_border_class(:unchanged), do: "border-slate-100 dark:border-slate-800"
  defp diff_border_class(:modified), do: "border-amber-200 dark:border-amber-800"
  defp diff_border_class(:added), do: "border-emerald-200 dark:border-emerald-800"
  defp diff_border_class(:removed), do: "border-red-200 dark:border-red-800"
  defp diff_border_class(:moved), do: "border-blue-200 dark:border-blue-800"

  defp diff_badge_class(:unchanged), do: "bg-slate-100 text-slate-600 dark:bg-slate-800 dark:text-slate-400"
  defp diff_badge_class(:modified), do: "bg-amber-100 text-amber-700 dark:bg-amber-900/30 dark:text-amber-400"
  defp diff_badge_class(:added), do: "bg-emerald-100 text-emerald-700 dark:bg-emerald-900/30 dark:text-emerald-400"
  defp diff_badge_class(:removed), do: "bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-400"
  defp diff_badge_class(:moved), do: "bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-400"
end
