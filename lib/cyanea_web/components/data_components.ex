defmodule CyaneaWeb.DataComponents do
  @moduledoc """
  Data-centric, interactive, and structural components for the Cyanea platform.

  These components handle tables, search, file browsing, uploads, navigation,
  and other interactive patterns used across data-heavy views.
  """
  use Phoenix.Component

  alias Phoenix.LiveView.JS
  import CyaneaWeb.UIComponents

  # ---------------------------------------------------------------------------
  # data_table
  # ---------------------------------------------------------------------------

  @doc """
  Renders a data table inside a card.

  ## Examples

      <.data_table id="files" rows={@files}>
        <:col :let={file} label="Name"><%= file.name %></:col>
        <:col :let={file} label="Size"><%= file.size %></:col>
        <:action :let={file}>
          <.link navigate={~p"/files/\#{file.id}"}>View</.link>
        </:action>
        <:empty>
          <.empty_state icon="hero-table-cells" heading="No data" />
        </:empty>
      </.data_table>
  """
  attr :id, :string, required: true
  attr :rows, :list, required: true
  attr :row_click, :any, default: nil
  attr :class, :string, default: nil

  slot :col, required: true do
    attr :label, :string, required: true
    attr :class, :string
  end

  slot :action
  slot :empty

  def data_table(assigns) do
    ~H"""
    <.card padding="p-0" class={@class}>
      <div :if={@rows == [] && @empty != []} class="p-6">
        <%= render_slot(@empty) %>
      </div>
      <div :if={@rows != []} class="overflow-x-auto">
        <table class="w-full">
          <thead>
            <tr class="bg-slate-50 dark:bg-slate-800/50">
              <th
                :for={col <- @col}
                class={[
                  "px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-slate-500 dark:text-slate-400",
                  col[:class]
                ]}
              >
                <%= col.label %>
              </th>
              <th :if={@action != []} class="relative px-6 py-3">
                <span class="sr-only">Actions</span>
              </th>
            </tr>
          </thead>
          <tbody id={@id}>
            <tr
              :for={row <- @rows}
              class={[
                "border-t border-slate-100 dark:border-slate-700",
                @row_click && "cursor-pointer hover:bg-slate-50 dark:hover:bg-slate-800/50"
              ]}
            >
              <td
                :for={col <- @col}
                phx-click={@row_click && @row_click.(row)}
                class={["px-6 py-4 text-sm text-slate-900 dark:text-slate-100", col[:class]]}
              >
                <%= render_slot(col, row) %>
              </td>
              <td :if={@action != []} class="px-6 py-4 text-right text-sm">
                <span class="flex items-center justify-end gap-2">
                  <%= render_slot(@action, row) %>
                </span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </.card>
    """
  end

  # ---------------------------------------------------------------------------
  # pagination
  # ---------------------------------------------------------------------------

  @doc """
  Renders previous/next pagination controls.

  ## Examples

      <.pagination page={@page} total_pages={@total_pages} patch={~p"/explore"} />
  """
  attr :page, :integer, required: true
  attr :total_pages, :integer, required: true
  attr :patch, :string, default: nil
  attr :event, :string, default: nil

  def pagination(assigns) do
    ~H"""
    <nav :if={@total_pages > 1} class="flex items-center justify-between px-2 py-3">
      <.pagination_button
        label="Previous"
        icon="hero-chevron-left-mini"
        icon_position={:left}
        disabled={@page <= 1}
        page={@page - 1}
        patch={@patch}
        event={@event}
      />
      <span class="text-sm text-slate-500 dark:text-slate-400">
        Page <%= @page %> of <%= @total_pages %>
      </span>
      <.pagination_button
        label="Next"
        icon="hero-chevron-right-mini"
        icon_position={:right}
        disabled={@page >= @total_pages}
        page={@page + 1}
        patch={@patch}
        event={@event}
      />
    </nav>
    """
  end

  attr :label, :string, required: true
  attr :icon, :string, required: true
  attr :icon_position, :atom, required: true
  attr :disabled, :boolean, required: true
  attr :page, :integer, required: true
  attr :patch, :string, default: nil
  attr :event, :string, default: nil

  defp pagination_button(%{patch: patch} = assigns) when is_binary(patch) do
    assigns =
      assign(assigns, :target, pagination_patch_url(assigns.patch, assigns.page))

    ~H"""
    <.link
      patch={@target}
      class={pagination_btn_classes(@disabled)}
    >
      <.icon :if={@icon_position == :left} name={@icon} class="h-4 w-4" />
      <%= @label %>
      <.icon :if={@icon_position == :right} name={@icon} class="h-4 w-4" />
    </.link>
    """
  end

  defp pagination_button(assigns) do
    ~H"""
    <button
      type="button"
      phx-click={@event}
      phx-value-page={@page}
      disabled={@disabled}
      class={pagination_btn_classes(@disabled)}
    >
      <.icon :if={@icon_position == :left} name={@icon} class="h-4 w-4" />
      <%= @label %>
      <.icon :if={@icon_position == :right} name={@icon} class="h-4 w-4" />
    </button>
    """
  end

  defp pagination_patch_url(base, page) do
    separator = if String.contains?(base, "?"), do: "&", else: "?"
    "#{base}#{separator}page=#{page}"
  end

  defp pagination_btn_classes(true),
    do:
      "inline-flex items-center gap-1 rounded-lg px-3 py-2 text-sm font-medium text-slate-300 dark:text-slate-600 cursor-not-allowed"

  defp pagination_btn_classes(false),
    do:
      "inline-flex items-center gap-1 rounded-lg px-3 py-2 text-sm font-medium text-slate-600 hover:bg-slate-100 dark:text-slate-400 dark:hover:bg-slate-800"

  # ---------------------------------------------------------------------------
  # search_input
  # ---------------------------------------------------------------------------

  @doc """
  Renders a search input with magnifying glass icon.

  ## Examples

      <.search_input value={@query} placeholder="Search repositories..." />
  """
  attr :id, :string, default: nil
  attr :name, :string, default: "query"
  attr :value, :string, default: ""
  attr :placeholder, :string, default: "Search..."
  attr :debounce, :string, default: "300"
  attr :class, :string, default: nil
  attr :rest, :global

  def search_input(assigns) do
    ~H"""
    <form phx-change="search" phx-submit="search">
      <div class={["relative", @class]}>
        <.icon
          name="hero-magnifying-glass"
          class="pointer-events-none absolute left-3 top-1/2 h-5 w-5 -translate-y-1/2 text-slate-400"
        />
        <input
          type="text"
          id={@id}
          name={@name}
          value={@value}
          placeholder={@placeholder}
          phx-debounce={@debounce}
          class="block w-full rounded-lg border-slate-300 pl-10 shadow-sm focus:border-primary-500 focus:ring-primary-500 sm:text-sm dark:border-slate-600 dark:bg-slate-800 dark:text-white"
          {@rest}
        />
      </div>
    </form>
    """
  end

  # ---------------------------------------------------------------------------
  # dropdown_menu
  # ---------------------------------------------------------------------------

  @doc """
  Renders a dropdown menu with trigger.

  ## Examples

      <.dropdown_menu id="user-menu">
        <:trigger>
          <.avatar name={@user.name} size={:sm} />
        </:trigger>
        <:item navigate={~p"/settings"} icon="hero-cog-6-tooth">Settings</:item>
        <:item separator={true} />
        <:item href={~p"/auth/logout"} method="delete" icon="hero-arrow-right-on-rectangle">
          Sign out
        </:item>
      </.dropdown_menu>
  """
  attr :id, :string, required: true

  slot :trigger, required: true

  slot :item do
    attr :navigate, :string
    attr :href, :string
    attr :method, :string
    attr :icon, :string
    attr :separator, :boolean
  end

  def dropdown_menu(assigns) do
    ~H"""
    <div class="relative" phx-click-away={JS.hide(to: "##{@id}-menu")}>
      <button
        type="button"
        phx-click={JS.toggle(to: "##{@id}-menu")}
        class="flex items-center"
      >
        <%= render_slot(@trigger) %>
      </button>

      <div
        id={"#{@id}-menu"}
        class="absolute right-0 z-50 mt-2 hidden w-56 rounded-xl border border-slate-200 bg-white py-2 shadow-lg dark:border-slate-700 dark:bg-slate-800"
      >
        <%= for item <- @item do %>
          <%= if item[:separator] do %>
            <div class="my-1 border-t border-slate-200 dark:border-slate-700" />
          <% else %>
            <.dropdown_item item={item} menu_id={@id} />
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end

  defp dropdown_item(%{item: %{navigate: nav}} = assigns) when is_binary(nav) do
    ~H"""
    <.link
      navigate={@item.navigate}
      class="flex items-center gap-2 px-4 py-2 text-sm text-slate-700 hover:bg-slate-50 dark:text-slate-300 dark:hover:bg-slate-700"
    >
      <.icon :if={@item[:icon]} name={@item[:icon]} class="h-4 w-4 text-slate-400" />
      <%= render_slot(@item) %>
    </.link>
    """
  end

  defp dropdown_item(%{item: %{href: href}} = assigns) when is_binary(href) do
    ~H"""
    <.link
      href={@item.href}
      method={@item[:method]}
      class="flex items-center gap-2 px-4 py-2 text-sm text-slate-700 hover:bg-slate-50 dark:text-slate-300 dark:hover:bg-slate-700"
    >
      <.icon :if={@item[:icon]} name={@item[:icon]} class="h-4 w-4 text-slate-400" />
      <%= render_slot(@item) %>
    </.link>
    """
  end

  defp dropdown_item(assigns) do
    ~H"""
    <button
      type="button"
      class="flex w-full items-center gap-2 px-4 py-2 text-sm text-slate-700 hover:bg-slate-50 dark:text-slate-300 dark:hover:bg-slate-700"
    >
      <.icon :if={@item[:icon]} name={@item[:icon]} class="h-4 w-4 text-slate-400" />
      <%= render_slot(@item) %>
    </button>
    """
  end

  # ---------------------------------------------------------------------------
  # sidebar_nav
  # ---------------------------------------------------------------------------

  @doc """
  Renders a sidebar navigation with optional sections.

  ## Examples

      <.sidebar_nav>
        <:section title="Repositories">
          <.link navigate={~p"/repos"}>All repos</.link>
        </:section>
        <:section title="Organizations">
          <.link navigate={~p"/orgs"}>All orgs</.link>
        </:section>
      </.sidebar_nav>
  """
  attr :class, :string, default: nil

  slot :section do
    attr :title, :string
  end

  def sidebar_nav(assigns) do
    ~H"""
    <nav class={["space-y-6", @class]}>
      <div :for={section <- @section}>
        <h3
          :if={section[:title]}
          class="mb-2 text-xs font-semibold uppercase tracking-wider text-slate-400 dark:text-slate-500"
        >
          <%= section.title %>
        </h3>
        <div class="space-y-1">
          <%= render_slot(section) %>
        </div>
      </div>
    </nav>
    """
  end

  # ---------------------------------------------------------------------------
  # file_browser
  # ---------------------------------------------------------------------------

  @doc """
  Renders a file listing table with icons, sizes, and optional actions.

  ## Examples

      <.file_browser files={@files}>
        <:action :let={file}>
          <button phx-click="delete-file" phx-value-id={file.id}>Delete</button>
        </:action>
      </.file_browser>

  Each file map should have: `:name`, `:size` (bytes), `:mime_type` (optional).
  """
  attr :files, :list, required: true
  attr :class, :string, default: nil

  slot :action, doc: "Per-file action column"

  def file_browser(assigns) do
    ~H"""
    <.data_table :if={@files != []} id="file-browser" rows={@files} class={@class}>
      <:col :let={file} label="Name">
        <div class="flex items-center gap-2">
          <.icon name={file_icon(file)} class="h-5 w-5 shrink-0 text-slate-400" />
          <span class="font-medium"><%= file.name %></span>
        </div>
      </:col>
      <:col :let={file} label="Size" class="whitespace-nowrap">
        <%= CyaneaWeb.Formatters.format_size(file[:size] || 0) %>
      </:col>
      <:col :let={file} label="Type" class="text-slate-500">
        <%= file[:mime_type] || "—" %>
      </:col>
      <:action :let={file}>
        <%= render_slot(@action, file) %>
      </:action>
    </.data_table>
    <div :if={@files == []}>
      <.empty_state
        icon="hero-folder-open"
        heading="No files yet"
        description="Upload files to get started."
        bordered
      />
    </div>
    """
  end

  defp file_icon(%{mime_type: "directory"}), do: "hero-folder"
  defp file_icon(%{name: name}) when is_binary(name) do
    cond do
      String.ends_with?(name, [".fa", ".fasta", ".fq", ".fastq"]) -> "hero-document-text"
      String.ends_with?(name, [".csv", ".tsv", ".parquet"]) -> "hero-table-cells"
      String.ends_with?(name, [".png", ".jpg", ".jpeg", ".svg"]) -> "hero-photo"
      String.ends_with?(name, [".gz", ".zip", ".tar", ".zst"]) -> "hero-archive-box"
      true -> "hero-document"
    end
  end

  defp file_icon(_), do: "hero-document"

  # ---------------------------------------------------------------------------
  # upload_zone
  # ---------------------------------------------------------------------------

  @doc """
  Renders a drag-and-drop upload zone with progress.

  ## Examples

      <.upload_zone upload={@uploads.files} />
  """
  attr :upload, :any, required: true
  attr :cancel_event, :string, default: "cancel-upload"
  attr :class, :string, default: nil

  def upload_zone(assigns) do
    ~H"""
    <div class={[
      "rounded-xl border-2 border-dashed border-slate-300 bg-white p-6 dark:border-slate-600 dark:bg-slate-800",
      @class
    ]}>
      <form id="upload-form" phx-change="validate-upload" phx-submit="upload" phx-drop-target={@upload.ref}>
        <div class="text-center">
          <.icon name="hero-cloud-arrow-up" class="mx-auto h-10 w-10 text-slate-400" />
          <p class="mt-2 text-sm text-slate-600 dark:text-slate-400">
            Drag and drop files here, or
            <label class="cursor-pointer font-medium text-primary hover:text-primary-500">
              browse
              <.live_file_input upload={@upload} class="sr-only" />
            </label>
          </p>
          <p class="mt-1 text-xs text-slate-400">
            Up to <%= @upload.max_entries %> files, <%= CyaneaWeb.Formatters.format_size(@upload.max_file_size) %> each
          </p>
        </div>

        <div :if={@upload.entries != []} class="mt-4 space-y-2">
          <div
            :for={entry <- @upload.entries}
            class="flex items-center justify-between rounded-lg border border-slate-200 p-3 dark:border-slate-700"
          >
            <div class="flex items-center gap-3 overflow-hidden">
              <.icon name="hero-document" class="h-5 w-5 shrink-0 text-slate-400" />
              <div class="min-w-0">
                <p class="truncate text-sm font-medium text-slate-900 dark:text-white">
                  <%= entry.client_name %>
                </p>
                <p class="text-xs text-slate-500">
                  <%= CyaneaWeb.Formatters.format_size(entry.client_size) %>
                </p>
              </div>
            </div>
            <div class="flex items-center gap-3">
              <.progress_bar value={entry.progress} class="w-20" />
              <button
                type="button"
                phx-click={@cancel_event}
                phx-value-ref={entry.ref}
                class="text-slate-400 hover:text-slate-600 dark:hover:text-slate-300"
              >
                <.icon name="hero-x-mark" class="h-4 w-4" />
              </button>
            </div>
          </div>
        </div>

        <div :if={@upload.entries != []} class="mt-4 text-center">
          <button
            type="submit"
            class="inline-flex items-center rounded-lg bg-primary px-4 py-2 text-sm font-medium text-white shadow-sm transition hover:bg-primary-700"
          >
            Upload <%= length(@upload.entries) %> file<%= if length(@upload.entries) != 1, do: "s" %>
          </button>
        </div>
      </form>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # activity_item
  # ---------------------------------------------------------------------------

  @doc """
  Renders an activity feed item.

  ## Examples

      <.activity_item timestamp={~U[2026-02-07 12:00:00Z]}>
        <:avatar><.avatar name="zara" size={:sm} /></:avatar>
        <:content>
          <strong>zara</strong> pushed 3 commits to <code>main</code>
        </:content>
      </.activity_item>
  """
  attr :timestamp, :any, default: nil
  attr :class, :string, default: nil

  slot :avatar, required: true
  slot :content, required: true

  def activity_item(assigns) do
    ~H"""
    <div class={["flex gap-3", @class]}>
      <div class="shrink-0">
        <%= render_slot(@avatar) %>
      </div>
      <div class="min-w-0 flex-1">
        <div class="text-sm text-slate-900 dark:text-slate-100">
          <%= render_slot(@content) %>
        </div>
        <p :if={@timestamp} class="mt-0.5 text-xs text-slate-500 dark:text-slate-400">
          <%= CyaneaWeb.Formatters.format_relative(@timestamp) %>
        </p>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # copy_button
  # ---------------------------------------------------------------------------

  @doc """
  Renders a button that copies text to the clipboard.

  Requires the `CopyToClipboard` JS hook in app.js.

  ## Examples

      <.copy_button id="copy-url" text={@repo_url} />
  """
  attr :id, :string, required: true
  attr :text, :string, required: true
  attr :class, :string, default: nil

  def copy_button(assigns) do
    ~H"""
    <button
      id={@id}
      type="button"
      phx-hook="CopyToClipboard"
      data-copy-text={@text}
      data-copied="false"
      class={[
        "inline-flex items-center rounded-md p-1 text-slate-400 transition hover:text-slate-600 dark:hover:text-slate-300",
        @class
      ]}
      title="Copy to clipboard"
    >
      <.icon name="hero-clipboard-document" class="h-4 w-4 data-[copied=true]:hidden" />
      <.icon name="hero-clipboard-document-check" class="hidden h-4 w-4 text-emerald-500 data-[copied=true]:block" />
    </button>
    """
  end

  # ---------------------------------------------------------------------------
  # code_block
  # ---------------------------------------------------------------------------

  @doc """
  Renders a code block with optional language label and copy button.

  ## Examples

      <.code_block code={@fasta_content} language="fasta" />
  """
  attr :language, :string, default: nil
  attr :code, :string, required: true
  attr :class, :string, default: nil

  def code_block(assigns) do
    assigns = assign(assigns, :code_id, "code-#{System.unique_integer([:positive])}")

    ~H"""
    <div class={["overflow-hidden rounded-lg bg-slate-900 dark:bg-slate-950", @class]}>
      <div
        :if={@language}
        class="flex items-center justify-between border-b border-slate-700 px-4 py-2"
      >
        <span class="text-xs font-medium text-slate-400"><%= @language %></span>
        <.copy_button id={@code_id} text={@code} />
      </div>
      <pre class="overflow-x-auto p-4"><code class="font-mono text-sm text-slate-100 whitespace-pre"><%= @code %></code></pre>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # markdown
  # ---------------------------------------------------------------------------

  @doc """
  Renders a prose-styled wrapper for markdown/rich text content.

  Requires the `@tailwindcss/typography` plugin.

  ## Examples

      <.markdown>
        <h2>About this dataset</h2>
        <p>This dataset contains...</p>
      </.markdown>
  """
  attr :class, :string, default: nil

  slot :inner_block, required: true

  def markdown(assigns) do
    ~H"""
    <div class={[
      "prose prose-slate max-w-none dark:prose-invert prose-headings:font-display prose-a:text-primary",
      @class
    ]}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private icon helper
  # ---------------------------------------------------------------------------

  defp icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} />
    """
  end
end
