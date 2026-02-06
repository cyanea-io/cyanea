defmodule CyaneaWeb.RepositoryLive.Show do
  use CyaneaWeb, :live_view

  alias Cyanea.Repositories

  @impl true
  def mount(%{"username" => owner_name, "slug" => slug}, _session, socket) do
    # Try user-owned first, then org-owned
    repo =
      Repositories.get_repository_by_owner_and_slug(owner_name, slug) ||
        Repositories.get_repository_by_org_and_slug(owner_name, slug)

    current_user = socket.assigns[:current_user]

    cond do
      is_nil(repo) ->
        {:ok,
         socket
         |> put_flash(:error, "Repository not found.")
         |> redirect(to: ~p"/explore")}

      not Repositories.can_access?(repo, current_user) ->
        {:ok,
         socket
         |> put_flash(:error, "You don't have access to this repository.")
         |> redirect(to: ~p"/explore")}

      true ->
        owner_display = repo_owner_display(repo)
        is_owner = current_user && is_repo_owner?(repo, current_user)

        {:ok,
         assign(socket,
           page_title: "#{owner_display}/#{repo.name}",
           repo: repo,
           owner_display: owner_display,
           is_owner: is_owner
         )}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <%!-- Breadcrumb --%>
      <div class="flex items-center gap-2 text-sm text-slate-500">
        <.link navigate={owner_path(@repo)} class="hover:text-cyan-600">
          <%= @owner_display %>
        </.link>
        <span>/</span>
        <span class="font-semibold text-slate-900 dark:text-white"><%= @repo.name %></span>
        <span class={[
          "ml-2 inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium",
          if(@repo.visibility == "public",
            do: "bg-emerald-100 text-emerald-700 dark:bg-emerald-900/30 dark:text-emerald-400",
            else: "bg-amber-100 text-amber-700 dark:bg-amber-900/30 dark:text-amber-400"
          )
        ]}>
          <%= @repo.visibility %>
        </span>
      </div>

      <%!-- Repository Info Card --%>
      <div class="mt-6 rounded-xl border border-slate-200 bg-white p-6 dark:border-slate-700 dark:bg-slate-800">
        <div class="flex items-start justify-between">
          <div>
            <h1 class="text-2xl font-bold text-slate-900 dark:text-white"><%= @repo.name %></h1>
            <p :if={@repo.description} class="mt-2 text-slate-600 dark:text-slate-400">
              <%= @repo.description %>
            </p>
          </div>
          <div class="flex items-center gap-3">
            <span class="flex items-center gap-1 rounded-lg border border-slate-200 px-3 py-1.5 text-sm dark:border-slate-700">
              <.icon name="hero-star" class="h-4 w-4" />
              <%= @repo.stars_count %>
            </span>
          </div>
        </div>

        <%!-- Metadata --%>
        <div class="mt-4 flex flex-wrap items-center gap-4 text-sm text-slate-500">
          <span :if={@repo.license} class="flex items-center gap-1">
            <.icon name="hero-scale" class="h-4 w-4" />
            <%= license_display(@repo.license) %>
          </span>
          <span class="flex items-center gap-1">
            <.icon name="hero-clock" class="h-4 w-4" />
            Updated <%= format_date(@repo.updated_at) %>
          </span>
          <span :if={@repo.default_branch} class="flex items-center gap-1">
            <.icon name="hero-code-bracket" class="h-4 w-4" />
            <%= @repo.default_branch %>
          </span>
        </div>

        <%!-- Tags --%>
        <div :if={@repo.tags != []} class="mt-4 flex flex-wrap gap-2">
          <span
            :for={tag <- @repo.tags}
            class="rounded-full bg-cyan-100 px-2.5 py-0.5 text-xs font-medium text-cyan-700 dark:bg-cyan-900/30 dark:text-cyan-400"
          >
            <%= tag %>
          </span>
        </div>
      </div>

      <%!-- File listing placeholder --%>
      <div class="mt-6 rounded-xl border border-slate-200 bg-white dark:border-slate-700 dark:bg-slate-800">
        <div class="border-b border-slate-200 px-6 py-4 dark:border-slate-700">
          <div class="flex items-center justify-between">
            <h2 class="text-sm font-semibold text-slate-900 dark:text-white">Files</h2>
          </div>
        </div>
        <div class="px-6 py-12 text-center text-sm text-slate-500 dark:text-slate-400">
          <.icon name="hero-folder-open" class="mx-auto mb-3 h-12 w-12 text-slate-300 dark:text-slate-600" />
          <p>No files uploaded yet.</p>
          <p class="mt-1">Upload datasets, protocols, and research artifacts to get started.</p>
        </div>
      </div>
    </div>
    """
  end

  defp repo_owner_display(repo) do
    cond do
      repo.owner -> repo.owner.username
      repo.organization -> repo.organization.slug
      true -> "unknown"
    end
  end

  defp owner_path(repo) do
    cond do
      repo.owner -> ~p"/#{repo.owner.username}"
      repo.organization -> ~p"/#{repo.organization.slug}"
      true -> ~p"/"
    end
  end

  defp is_repo_owner?(repo, user) do
    repo.owner_id == user.id
  end

  defp license_display("cc-by-4.0"), do: "CC BY 4.0"
  defp license_display("cc-by-sa-4.0"), do: "CC BY-SA 4.0"
  defp license_display("cc0-1.0"), do: "CC0 1.0"
  defp license_display("mit"), do: "MIT"
  defp license_display("apache-2.0"), do: "Apache 2.0"
  defp license_display("proprietary"), do: "Proprietary"
  defp license_display(other), do: other

  defp format_date(datetime) do
    Calendar.strftime(datetime, "%b %d, %Y")
  end
end
