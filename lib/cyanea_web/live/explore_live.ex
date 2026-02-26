defmodule CyaneaWeb.ExploreLive do
  use CyaneaWeb, :live_view

  alias Cyanea.Search
  alias Cyanea.Spaces

  @impl true
  def mount(_params, _session, socket) do
    spaces = Spaces.list_public_spaces()

    {:ok,
     assign(socket,
       page_title: "Explore",
       spaces: spaces,
       search_query: "",
       active_tab: :spaces,
       user_results: []
     )}
  end

  @impl true
  def handle_event("search", %{"query" => query}, socket) do
    if query == "" do
      spaces = Spaces.list_public_spaces()
      {:noreply, assign(socket, spaces: spaces, search_query: "", user_results: [])}
    else
      {spaces, user_results} = perform_search(query)
      {:noreply, assign(socket, spaces: spaces, search_query: query, user_results: user_results)}
    end
  end

  def handle_event("switch-tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, active_tab: String.to_existing_atom(tab))}
  end

  defp perform_search(query) do
    space_results =
      case Search.search_spaces(query, filter: "visibility = public") do
        {:ok, %{"hits" => hits}} when hits != [] ->
          ids = Enum.map(hits, & &1["id"])
          load_spaces_by_ids(ids)

        _ ->
          db_fallback_search(query)
      end

    user_results =
      case Search.search_users(query) do
        {:ok, %{"hits" => hits}} -> hits
        _ -> []
      end

    {space_results, user_results}
  end

  defp load_spaces_by_ids(ids) do
    import Ecto.Query

    from(s in Cyanea.Spaces.Space,
      where: s.id in ^ids,
      where: s.visibility == "public"
    )
    |> Cyanea.Repo.all()
  end

  defp db_fallback_search(query) do
    spaces = Spaces.list_public_spaces()
    q = String.downcase(query)

    Enum.filter(spaces, fn space ->
      String.contains?(String.downcase(space.name), q) ||
        (space.description && String.contains?(String.downcase(space.description), q)) ||
        Enum.any?(space.tags || [], &String.contains?(String.downcase(&1), q))
    end)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Explore
        <:subtitle>Discover public datasets, protocols, and research spaces</:subtitle>
      </.header>

      <div class="mt-6">
        <.search_input value={@search_query} placeholder="Search spaces and users..." />
      </div>

      <%!-- Tabs --%>
      <div :if={@search_query != ""} class="mt-6">
        <.tabs>
          <:tab active={@active_tab == :spaces} click="switch-tab" value="spaces" count={length(@spaces)}>
            Spaces
          </:tab>
          <:tab active={@active_tab == :users} click="switch-tab" value="users" count={length(@user_results)}>
            Users
          </:tab>
        </.tabs>
      </div>

      <%!-- Space results --%>
      <div :if={@active_tab == :spaces} class="mt-8 space-y-4">
        <div
          :for={space <- @spaces}
          class="rounded-xl border border-slate-200 bg-white p-6 transition hover:border-slate-300 dark:border-slate-700 dark:bg-slate-800 dark:hover:border-slate-600"
        >
          <div class="flex items-start justify-between">
            <div class="min-w-0 flex-1">
              <div class="flex items-center gap-2">
                <.link
                  navigate={space_path(space)}
                  class="text-lg font-semibold text-primary hover:underline"
                >
                  <span class="text-slate-500"><%= space_owner_name(space) %>/</span><%= space.name %>
                </.link>
                <.visibility_badge visibility={space.visibility} />
              </div>
              <p :if={space.description} class="mt-2 text-sm text-slate-600 dark:text-slate-400">
                <%= space.description %>
              </p>
              <div class="mt-3 flex flex-wrap items-center gap-3 text-xs text-slate-500">
                <.metadata_row :if={space.license} icon="hero-scale">
                  <%= space.license %>
                </.metadata_row>
                <.badge :for={tag <- space.tags || []} color={:gray} size={:xs}><%= tag %></.badge>
                <.metadata_row icon="hero-star">
                  <%= space.star_count %>
                </.metadata_row>
              </div>
            </div>
          </div>
        </div>

        <.empty_state
          :if={@spaces == []}
          heading="No spaces found."
        />
      </div>

      <%!-- User results --%>
      <div :if={@active_tab == :users && @search_query != ""} class="mt-8 space-y-4">
        <div
          :for={user <- @user_results}
          class="flex items-center gap-4 rounded-xl border border-slate-200 bg-white p-4 dark:border-slate-700 dark:bg-slate-800"
        >
          <.avatar name={user["username"] || ""} size={:md} />
          <div>
            <.link navigate={~p"/#{user["username"]}"} class="font-semibold text-primary hover:underline">
              <%= user["name"] || user["username"] %>
            </.link>
            <p class="text-xs text-slate-500">@<%= user["username"] %></p>
            <p :if={user["affiliation"] && user["affiliation"] != ""} class="text-xs text-slate-400"><%= user["affiliation"] %></p>
          </div>
        </div>

        <.empty_state :if={@user_results == []} heading="No users found." />
      </div>
    </div>
    """
  end

  defp space_path(space) do
    owner = space_owner_name(space)
    ~p"/#{owner}/#{space.slug}"
  end

  defp space_owner_name(space) do
    Cyanea.Spaces.owner_display(space)
  end
end
