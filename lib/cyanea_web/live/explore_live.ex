defmodule CyaneaWeb.ExploreLive do
  use CyaneaWeb, :live_view

  alias Cyanea.Repositories

  @impl true
  def mount(_params, _session, socket) do
    repositories = Repositories.list_public_repositories()

    {:ok,
     assign(socket,
       page_title: "Explore",
       repositories: repositories,
       search_query: ""
     )}
  end

  @impl true
  def handle_event("search", %{"query" => query}, socket) do
    repositories = Repositories.list_public_repositories()

    filtered =
      if query == "" do
        repositories
      else
        q = String.downcase(query)

        Enum.filter(repositories, fn repo ->
          String.contains?(String.downcase(repo.name), q) ||
            (repo.description && String.contains?(String.downcase(repo.description), q)) ||
            Enum.any?(repo.tags || [], &String.contains?(String.downcase(&1), q))
        end)
      end

    {:noreply, assign(socket, repositories: filtered, search_query: query)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Explore
        <:subtitle>Discover public datasets, protocols, and research artifacts</:subtitle>
      </.header>

      <div class="mt-6">
        <form phx-change="search" phx-submit="search">
          <div class="relative">
            <.icon name="hero-magnifying-glass" class="absolute left-3 top-1/2 h-5 w-5 -translate-y-1/2 text-slate-400" />
            <input
              type="text"
              name="query"
              value={@search_query}
              placeholder="Search repositories..."
              phx-debounce="300"
              class="block w-full rounded-lg border-slate-300 pl-10 shadow-sm focus:border-cyan-500 focus:ring-cyan-500 sm:text-sm dark:border-slate-600 dark:bg-slate-800"
            />
          </div>
        </form>
      </div>

      <div class="mt-8 space-y-4">
        <div
          :for={repo <- @repositories}
          class="rounded-xl border border-slate-200 bg-white p-6 transition hover:border-slate-300 dark:border-slate-700 dark:bg-slate-800 dark:hover:border-slate-600"
        >
          <div class="flex items-start justify-between">
            <div class="min-w-0 flex-1">
              <div class="flex items-center gap-2">
                <.link
                  navigate={repo_path(repo)}
                  class="text-lg font-semibold text-cyan-600 hover:underline"
                >
                  <span class="text-slate-500"><%= repo_owner_name(repo) %>/</span><%= repo.name %>
                </.link>
                <span class={[
                  "inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium",
                  if(repo.visibility == "public",
                    do: "bg-emerald-100 text-emerald-700 dark:bg-emerald-900/30 dark:text-emerald-400",
                    else: "bg-amber-100 text-amber-700 dark:bg-amber-900/30 dark:text-amber-400"
                  )
                ]}>
                  <%= repo.visibility %>
                </span>
              </div>
              <p :if={repo.description} class="mt-2 text-sm text-slate-600 dark:text-slate-400">
                <%= repo.description %>
              </p>
              <div class="mt-3 flex flex-wrap items-center gap-3 text-xs text-slate-500">
                <span :if={repo.license} class="flex items-center gap-1">
                  <.icon name="hero-scale" class="h-3.5 w-3.5" />
                  <%= repo.license %>
                </span>
                <span :for={tag <- repo.tags || []} class="rounded-full bg-slate-100 px-2 py-0.5 dark:bg-slate-700">
                  <%= tag %>
                </span>
                <span class="flex items-center gap-1">
                  <.icon name="hero-star" class="h-3.5 w-3.5" />
                  <%= repo.stars_count %>
                </span>
              </div>
            </div>
          </div>
        </div>

        <p
          :if={@repositories == []}
          class="py-12 text-center text-slate-500 dark:text-slate-400"
        >
          No repositories found.
        </p>
      </div>
    </div>
    """
  end

  defp repo_path(repo) do
    cond do
      repo.owner -> ~p"/#{repo.owner.username}/#{repo.slug}"
      repo.organization -> ~p"/#{repo.organization.slug}/#{repo.slug}"
      true -> "#"
    end
  end

  defp repo_owner_name(repo) do
    cond do
      repo.owner -> repo.owner.username
      repo.organization -> repo.organization.slug
      true -> "unknown"
    end
  end
end
