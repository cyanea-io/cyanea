defmodule CyaneaWeb.ProtocolLive.Show do
  use CyaneaWeb, :live_view

  alias Cyanea.Protocols
  alias CyaneaWeb.ContentHelpers
  alias CyaneaWeb.Markdown

  @impl true
  def mount(%{"protocol_slug" => protocol_slug} = params, _session, socket) do
    case ContentHelpers.mount_space(socket, params) do
      {:ok, socket} ->
        space = socket.assigns.space
        protocol = Protocols.get_protocol_by_slug(space.id, protocol_slug)

        if protocol do
          {:ok,
           socket
           |> assign(
             page_title: protocol.title,
             protocol: protocol,
             editing_section: nil,
             materials_form: build_materials_form(protocol),
             equipment_form: build_equipment_form(protocol),
             steps_form: build_steps_form(protocol),
             tips_form: Protocols.get_tips(protocol)
           )}
        else
          {:ok,
           socket
           |> put_flash(:error, "Protocol not found.")
           |> redirect(to: ~p"/#{socket.assigns.owner_name}/#{space.slug}")}
        end

      {:error, socket} ->
        {:ok, socket}
    end
  end

  @impl true
  def handle_event("edit-section", %{"section" => section}, socket) do
    {:noreply, assign(socket, editing_section: section)}
  end

  def handle_event("cancel-edit", _params, socket) do
    {:noreply, assign(socket, editing_section: nil)}
  end

  def handle_event("save-materials", %{"materials" => materials_params}, socket) do
    materials = parse_materials(materials_params)

    case Protocols.update_materials(socket.assigns.protocol, materials) do
      {:ok, protocol} ->
        {:noreply,
         socket
         |> assign(protocol: protocol, editing_section: nil)
         |> assign(materials_form: build_materials_form(protocol))}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to save materials.")}
    end
  end

  def handle_event("save-equipment", %{"equipment" => equipment_params}, socket) do
    equipment = parse_equipment(equipment_params)

    case Protocols.update_equipment(socket.assigns.protocol, equipment) do
      {:ok, protocol} ->
        {:noreply,
         socket
         |> assign(protocol: protocol, editing_section: nil)
         |> assign(equipment_form: build_equipment_form(protocol))}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to save equipment.")}
    end
  end

  def handle_event("save-steps", %{"steps" => steps_params}, socket) do
    steps = parse_steps(steps_params)

    case Protocols.update_steps(socket.assigns.protocol, steps) do
      {:ok, protocol} ->
        {:noreply,
         socket
         |> assign(protocol: protocol, editing_section: nil)
         |> assign(steps_form: build_steps_form(protocol))}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to save steps.")}
    end
  end

  def handle_event("save-tips", %{"tips" => tips}, socket) do
    case Protocols.update_tips(socket.assigns.protocol, tips) do
      {:ok, protocol} ->
        {:noreply,
         socket
         |> assign(protocol: protocol, editing_section: nil, tips_form: tips)}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to save tips.")}
    end
  end

  def handle_event("save-metadata", %{"title" => title, "description" => description}, socket) do
    case Protocols.update_protocol(socket.assigns.protocol, %{
           title: title,
           description: description
         }) do
      {:ok, protocol} ->
        {:noreply,
         socket
         |> assign(protocol: protocol, editing_section: nil, page_title: protocol.title)}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to save.")}
    end
  end

  def handle_event("bump-version", %{"level" => level}, socket) do
    level = String.to_existing_atom(level)

    case Protocols.bump_version(socket.assigns.protocol, level) do
      {:ok, protocol} ->
        {:noreply,
         socket
         |> assign(protocol: protocol)
         |> put_flash(:info, "Version bumped to #{protocol.version}")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to bump version.")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <%!-- Breadcrumb + version --%>
      <div class="flex items-center justify-between">
        <div class="flex items-center gap-3">
          <.breadcrumb>
            <:crumb navigate={~p"/#{@owner_name}"}><%= @owner_name %></:crumb>
            <:crumb navigate={~p"/#{@owner_name}/#{@space.slug}"}><%= @space.name %></:crumb>
            <:crumb><%= @protocol.title %></:crumb>
          </.breadcrumb>
          <.badge color={:accent}>v<%= @protocol.version %></.badge>
        </div>
        <div :if={@is_owner} class="flex items-center gap-2">
          <button
            phx-click="bump-version"
            phx-value-level="patch"
            class="rounded-lg border border-slate-200 px-2 py-1 text-xs hover:bg-slate-50 dark:border-slate-700 dark:hover:bg-slate-800"
          >
            Bump patch
          </button>
          <button
            phx-click="bump-version"
            phx-value-level="minor"
            class="rounded-lg border border-slate-200 px-2 py-1 text-xs hover:bg-slate-50 dark:border-slate-700 dark:hover:bg-slate-800"
          >
            Bump minor
          </button>
        </div>
      </div>

      <%!-- Description --%>
      <p :if={@protocol.description} class="mt-4 text-sm text-slate-600 dark:text-slate-400">
        <%= @protocol.description %>
      </p>

      <%!-- Sections --%>
      <div class="mt-6 space-y-6">
        <%!-- Materials --%>
        <.protocol_section
          title="Materials"
          icon="hero-beaker"
          editing={@editing_section == "materials"}
          is_owner={@is_owner}
          section="materials"
        >
          <%= if @editing_section == "materials" do %>
            <.materials_editor materials_form={@materials_form} />
          <% else %>
            <.materials_viewer materials={Protocols.get_materials(@protocol)} />
          <% end %>
        </.protocol_section>

        <%!-- Equipment --%>
        <.protocol_section
          title="Equipment"
          icon="hero-wrench-screwdriver"
          editing={@editing_section == "equipment"}
          is_owner={@is_owner}
          section="equipment"
        >
          <%= if @editing_section == "equipment" do %>
            <.equipment_editor equipment_form={@equipment_form} />
          <% else %>
            <.equipment_viewer equipment={Protocols.get_equipment(@protocol)} />
          <% end %>
        </.protocol_section>

        <%!-- Steps --%>
        <.protocol_section
          title="Steps"
          icon="hero-list-bullet"
          editing={@editing_section == "steps"}
          is_owner={@is_owner}
          section="steps"
        >
          <%= if @editing_section == "steps" do %>
            <.steps_editor steps_form={@steps_form} />
          <% else %>
            <.steps_viewer steps={Protocols.get_steps(@protocol)} />
          <% end %>
        </.protocol_section>

        <%!-- Tips --%>
        <.protocol_section
          title="Tips & Notes"
          icon="hero-light-bulb"
          editing={@editing_section == "tips"}
          is_owner={@is_owner}
          section="tips"
        >
          <%= if @editing_section == "tips" do %>
            <form phx-submit="save-tips" class="space-y-3">
              <textarea
                name="tips"
                rows="5"
                class="w-full rounded-lg border border-slate-200 p-3 text-sm dark:border-slate-600 dark:bg-slate-900 dark:text-slate-200"
              ><%= @tips_form %></textarea>
              <div class="flex justify-end gap-2">
                <button type="button" phx-click="cancel-edit" class="text-sm text-slate-500 hover:text-slate-700">Cancel</button>
                <button type="submit" class="rounded-lg bg-primary px-3 py-1.5 text-sm font-medium text-white hover:bg-primary/90">Save</button>
              </div>
            </form>
          <% else %>
            <%= if Protocols.get_tips(@protocol) != "" do %>
              <div class="prose prose-sm max-w-none dark:prose-invert">
                <%= Markdown.render(Protocols.get_tips(@protocol)) %>
              </div>
            <% else %>
              <p class="text-sm text-slate-400 italic">No tips yet.</p>
            <% end %>
          <% end %>
        </.protocol_section>
      </div>
    </div>
    """
  end

  # -- Section wrapper component --

  defp protocol_section(assigns) do
    ~H"""
    <.card>
      <:header>
        <div class="flex items-center justify-between">
          <div class="flex items-center gap-2">
            <.icon name={@icon} class="h-5 w-5 text-slate-400" />
            <h3 class="text-sm font-semibold text-slate-900 dark:text-white"><%= @title %></h3>
          </div>
          <button
            :if={@is_owner and not @editing}
            phx-click="edit-section"
            phx-value-section={@section}
            class="text-xs font-medium text-primary hover:text-primary/80"
          >
            Edit
          </button>
        </div>
      </:header>
      <%= render_slot(@inner_block) %>
    </.card>
    """
  end

  # -- Materials --

  defp materials_viewer(assigns) do
    ~H"""
    <%= if @materials == [] do %>
      <p class="text-sm text-slate-400 italic">No materials listed.</p>
    <% else %>
      <table class="w-full text-sm">
        <thead>
          <tr class="border-b border-slate-200 dark:border-slate-700">
            <th class="pb-2 text-left font-medium text-slate-500">Name</th>
            <th class="pb-2 text-left font-medium text-slate-500">Quantity</th>
            <th class="pb-2 text-left font-medium text-slate-500">Vendor</th>
            <th class="pb-2 text-left font-medium text-slate-500">Catalog #</th>
          </tr>
        </thead>
        <tbody>
          <tr :for={mat <- @materials} class="border-b border-slate-100 last:border-0 dark:border-slate-700">
            <td class="py-2 text-slate-900 dark:text-white"><%= mat["name"] %></td>
            <td class="py-2 text-slate-600 dark:text-slate-400"><%= mat["quantity"] %></td>
            <td class="py-2 text-slate-600 dark:text-slate-400"><%= mat["vendor"] %></td>
            <td class="py-2 text-slate-600 dark:text-slate-400"><%= mat["catalog_number"] %></td>
          </tr>
        </tbody>
      </table>
    <% end %>
    """
  end

  defp materials_editor(assigns) do
    ~H"""
    <form phx-submit="save-materials" class="space-y-3">
      <div class="space-y-2">
        <div :for={{mat, idx} <- Enum.with_index(@materials_form)} class="grid grid-cols-4 gap-2">
          <input type="text" name={"materials[#{idx}][name]"} value={mat["name"]} placeholder="Name" class="rounded border border-slate-200 px-2 py-1 text-sm dark:border-slate-600 dark:bg-slate-900" />
          <input type="text" name={"materials[#{idx}][quantity]"} value={mat["quantity"]} placeholder="Quantity" class="rounded border border-slate-200 px-2 py-1 text-sm dark:border-slate-600 dark:bg-slate-900" />
          <input type="text" name={"materials[#{idx}][vendor]"} value={mat["vendor"]} placeholder="Vendor" class="rounded border border-slate-200 px-2 py-1 text-sm dark:border-slate-600 dark:bg-slate-900" />
          <input type="text" name={"materials[#{idx}][catalog_number]"} value={mat["catalog_number"]} placeholder="Catalog #" class="rounded border border-slate-200 px-2 py-1 text-sm dark:border-slate-600 dark:bg-slate-900" />
        </div>
        <%!-- Empty row for adding new --%>
        <div class="grid grid-cols-4 gap-2">
          <% idx = length(@materials_form) %>
          <input type="text" name={"materials[#{idx}][name]"} placeholder="Name" class="rounded border border-slate-200 px-2 py-1 text-sm dark:border-slate-600 dark:bg-slate-900" />
          <input type="text" name={"materials[#{idx}][quantity]"} placeholder="Quantity" class="rounded border border-slate-200 px-2 py-1 text-sm dark:border-slate-600 dark:bg-slate-900" />
          <input type="text" name={"materials[#{idx}][vendor]"} placeholder="Vendor" class="rounded border border-slate-200 px-2 py-1 text-sm dark:border-slate-600 dark:bg-slate-900" />
          <input type="text" name={"materials[#{idx}][catalog_number]"} placeholder="Catalog #" class="rounded border border-slate-200 px-2 py-1 text-sm dark:border-slate-600 dark:bg-slate-900" />
        </div>
      </div>
      <div class="flex justify-end gap-2">
        <button type="button" phx-click="cancel-edit" class="text-sm text-slate-500 hover:text-slate-700">Cancel</button>
        <button type="submit" class="rounded-lg bg-primary px-3 py-1.5 text-sm font-medium text-white hover:bg-primary/90">Save</button>
      </div>
    </form>
    """
  end

  # -- Equipment --

  defp equipment_viewer(assigns) do
    ~H"""
    <%= if @equipment == [] do %>
      <p class="text-sm text-slate-400 italic">No equipment listed.</p>
    <% else %>
      <table class="w-full text-sm">
        <thead>
          <tr class="border-b border-slate-200 dark:border-slate-700">
            <th class="pb-2 text-left font-medium text-slate-500">Name</th>
            <th class="pb-2 text-left font-medium text-slate-500">Settings</th>
            <th class="pb-2 text-left font-medium text-slate-500">Notes</th>
          </tr>
        </thead>
        <tbody>
          <tr :for={eq <- @equipment} class="border-b border-slate-100 last:border-0 dark:border-slate-700">
            <td class="py-2 text-slate-900 dark:text-white"><%= eq["name"] %></td>
            <td class="py-2 text-slate-600 dark:text-slate-400"><%= eq["settings"] %></td>
            <td class="py-2 text-slate-600 dark:text-slate-400"><%= eq["notes"] %></td>
          </tr>
        </tbody>
      </table>
    <% end %>
    """
  end

  defp equipment_editor(assigns) do
    ~H"""
    <form phx-submit="save-equipment" class="space-y-3">
      <div class="space-y-2">
        <div :for={{eq, idx} <- Enum.with_index(@equipment_form)} class="grid grid-cols-3 gap-2">
          <input type="text" name={"equipment[#{idx}][name]"} value={eq["name"]} placeholder="Name" class="rounded border border-slate-200 px-2 py-1 text-sm dark:border-slate-600 dark:bg-slate-900" />
          <input type="text" name={"equipment[#{idx}][settings]"} value={eq["settings"]} placeholder="Settings" class="rounded border border-slate-200 px-2 py-1 text-sm dark:border-slate-600 dark:bg-slate-900" />
          <input type="text" name={"equipment[#{idx}][notes]"} value={eq["notes"]} placeholder="Notes" class="rounded border border-slate-200 px-2 py-1 text-sm dark:border-slate-600 dark:bg-slate-900" />
        </div>
        <div class="grid grid-cols-3 gap-2">
          <% idx = length(@equipment_form) %>
          <input type="text" name={"equipment[#{idx}][name]"} placeholder="Name" class="rounded border border-slate-200 px-2 py-1 text-sm dark:border-slate-600 dark:bg-slate-900" />
          <input type="text" name={"equipment[#{idx}][settings]"} placeholder="Settings" class="rounded border border-slate-200 px-2 py-1 text-sm dark:border-slate-600 dark:bg-slate-900" />
          <input type="text" name={"equipment[#{idx}][notes]"} placeholder="Notes" class="rounded border border-slate-200 px-2 py-1 text-sm dark:border-slate-600 dark:bg-slate-900" />
        </div>
      </div>
      <div class="flex justify-end gap-2">
        <button type="button" phx-click="cancel-edit" class="text-sm text-slate-500 hover:text-slate-700">Cancel</button>
        <button type="submit" class="rounded-lg bg-primary px-3 py-1.5 text-sm font-medium text-white hover:bg-primary/90">Save</button>
      </div>
    </form>
    """
  end

  # -- Steps --

  defp steps_viewer(assigns) do
    ~H"""
    <%= if @steps == [] do %>
      <p class="text-sm text-slate-400 italic">No steps yet.</p>
    <% else %>
      <ol class="space-y-4">
        <li :for={step <- @steps} class="flex gap-4">
          <span class="flex h-7 w-7 shrink-0 items-center justify-center rounded-full bg-primary/10 text-xs font-bold text-primary">
            <%= step["number"] %>
          </span>
          <div class="flex-1">
            <p class="text-sm text-slate-900 dark:text-white"><%= step["description"] %></p>
            <div class="mt-1 flex flex-wrap gap-2">
              <.badge :if={step["duration"] && step["duration"] != ""} color={:gray} size={:xs}>
                <%= step["duration"] %>
              </.badge>
              <.badge :if={step["temperature"] && step["temperature"] != ""} color={:warning} size={:xs}>
                <%= step["temperature"] %>
              </.badge>
            </div>
            <p :if={step["notes"] && step["notes"] != ""} class="mt-1 text-xs text-slate-500 dark:text-slate-400">
              <%= step["notes"] %>
            </p>
          </div>
        </li>
      </ol>
    <% end %>
    """
  end

  defp steps_editor(assigns) do
    ~H"""
    <form phx-submit="save-steps" class="space-y-3">
      <div class="space-y-3">
        <div :for={{step, idx} <- Enum.with_index(@steps_form)} class="rounded-lg border border-slate-200 p-3 dark:border-slate-700">
          <div class="mb-2 text-xs font-medium text-slate-500">Step <%= idx + 1 %></div>
          <textarea name={"steps[#{idx}][description]"} rows="2" placeholder="Description" class="mb-2 w-full rounded border border-slate-200 px-2 py-1 text-sm dark:border-slate-600 dark:bg-slate-900"><%= step["description"] %></textarea>
          <div class="grid grid-cols-3 gap-2">
            <input type="text" name={"steps[#{idx}][duration]"} value={step["duration"]} placeholder="Duration (e.g. 5 min)" class="rounded border border-slate-200 px-2 py-1 text-sm dark:border-slate-600 dark:bg-slate-900" />
            <input type="text" name={"steps[#{idx}][temperature]"} value={step["temperature"]} placeholder="Temperature (e.g. 95C)" class="rounded border border-slate-200 px-2 py-1 text-sm dark:border-slate-600 dark:bg-slate-900" />
            <input type="text" name={"steps[#{idx}][notes]"} value={step["notes"]} placeholder="Notes" class="rounded border border-slate-200 px-2 py-1 text-sm dark:border-slate-600 dark:bg-slate-900" />
          </div>
        </div>
        <%!-- Empty row for adding new step --%>
        <div class="rounded-lg border border-dashed border-slate-300 p-3 dark:border-slate-600">
          <% idx = length(@steps_form) %>
          <div class="mb-2 text-xs font-medium text-slate-400">New step</div>
          <textarea name={"steps[#{idx}][description]"} rows="2" placeholder="Description" class="mb-2 w-full rounded border border-slate-200 px-2 py-1 text-sm dark:border-slate-600 dark:bg-slate-900"></textarea>
          <div class="grid grid-cols-3 gap-2">
            <input type="text" name={"steps[#{idx}][duration]"} placeholder="Duration" class="rounded border border-slate-200 px-2 py-1 text-sm dark:border-slate-600 dark:bg-slate-900" />
            <input type="text" name={"steps[#{idx}][temperature]"} placeholder="Temperature" class="rounded border border-slate-200 px-2 py-1 text-sm dark:border-slate-600 dark:bg-slate-900" />
            <input type="text" name={"steps[#{idx}][notes]"} placeholder="Notes" class="rounded border border-slate-200 px-2 py-1 text-sm dark:border-slate-600 dark:bg-slate-900" />
          </div>
        </div>
      </div>
      <div class="flex justify-end gap-2">
        <button type="button" phx-click="cancel-edit" class="text-sm text-slate-500 hover:text-slate-700">Cancel</button>
        <button type="submit" class="rounded-lg bg-primary px-3 py-1.5 text-sm font-medium text-white hover:bg-primary/90">Save</button>
      </div>
    </form>
    """
  end

  # -- Form data helpers --

  defp build_materials_form(protocol), do: Protocols.get_materials(protocol)
  defp build_equipment_form(protocol), do: Protocols.get_equipment(protocol)
  defp build_steps_form(protocol), do: Protocols.get_steps(protocol)

  defp parse_materials(params) when is_map(params) do
    params
    |> Enum.sort_by(fn {k, _v} -> String.to_integer(k) end)
    |> Enum.map(fn {_k, v} -> v end)
    |> Enum.reject(fn m -> blank?(m["name"]) end)
  end

  defp parse_equipment(params) when is_map(params) do
    params
    |> Enum.sort_by(fn {k, _v} -> String.to_integer(k) end)
    |> Enum.map(fn {_k, v} -> v end)
    |> Enum.reject(fn e -> blank?(e["name"]) end)
  end

  defp parse_steps(params) when is_map(params) do
    params
    |> Enum.sort_by(fn {k, _v} -> String.to_integer(k) end)
    |> Enum.map(fn {_k, v} -> v end)
    |> Enum.reject(fn s -> blank?(s["description"]) end)
  end

  defp blank?(nil), do: true
  defp blank?(""), do: true
  defp blank?(_), do: false
end
