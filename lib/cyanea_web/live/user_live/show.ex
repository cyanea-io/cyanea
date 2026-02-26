defmodule CyaneaWeb.UserLive.Show do
  use CyaneaWeb, :live_view

  alias Cyanea.Accounts
  alias Cyanea.Organizations
  alias Cyanea.Spaces

  @impl true
  def mount(%{"username" => username}, _session, socket) do
    case Accounts.get_user_by_username(username) do
      nil ->
        # Could be an organization slug — try that
        case Organizations.get_organization_by_slug(username) do
          nil ->
            {:ok,
             socket
             |> put_flash(:error, "User not found.")
             |> redirect(to: ~p"/explore")}

          org ->
            current_user = socket.assigns[:current_user]
            spaces = Spaces.list_org_spaces(org.id, visibility: "public")
            members = Organizations.list_members(org.id)

            org_admin =
              current_user &&
                Organizations.authorize(current_user.id, org.id, "admin") != {:error, :unauthorized}

            {:ok,
             assign(socket,
               page_title: org.name,
               profile_type: :organization,
               org: org,
               org_admin: org_admin,
               user: nil,
               spaces: spaces,
               members: members,
               organizations: []
             )}
        end

      user ->
        current_user = socket.assigns[:current_user]
        is_self = current_user && current_user.id == user.id

        spaces =
          if is_self do
            Spaces.list_user_spaces(user.id)
          else
            Spaces.list_user_spaces(user.id, visibility: "public")
          end

        orgs = Organizations.list_user_organizations(user.id)

        {:ok,
         assign(socket,
           page_title: user.name || user.username,
           profile_type: :user,
           user: user,
           org: nil,
           org_admin: false,
           spaces: spaces,
           organizations: orgs,
           members: [],
           is_self: is_self
         )}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="grid gap-8 lg:grid-cols-[300px_1fr]">
      <%!-- Sidebar --%>
      <aside>
        <%= if @profile_type == :user do %>
          <.user_sidebar user={@user} organizations={@organizations} />
        <% else %>
          <.org_sidebar org={@org} org_admin={@org_admin} members={@members} />
        <% end %>
      </aside>

      <%!-- Main Content --%>
      <div>
        <h2 class="text-lg font-semibold text-slate-900 dark:text-white">Spaces</h2>
        <div class="mt-4 space-y-3">
          <div
            :for={space <- @spaces}
            class="rounded-lg border border-slate-200 bg-white p-4 dark:border-slate-700 dark:bg-slate-800"
          >
            <div class="flex items-start justify-between">
              <div class="flex items-center gap-2">
                <.link
                  navigate={space_path(space)}
                  class="font-semibold text-primary hover:underline"
                >
                  <%= space.name %>
                </.link>
                <.visibility_badge visibility={space.visibility} />
              </div>
              <.metadata_row icon="hero-star">
                <%= space.star_count %>
              </.metadata_row>
            </div>
            <p :if={space.description} class="mt-1 text-sm text-slate-600 dark:text-slate-400">
              <%= space.description %>
            </p>
            <div :if={space.tags != []} class="mt-2 flex flex-wrap gap-1">
              <.badge :for={tag <- space.tags} color={:gray} size={:xs}><%= tag %></.badge>
            </div>
          </div>

          <.empty_state :if={@spaces == []} heading="No spaces yet." />
        </div>
      </div>
    </div>
    """
  end

  defp user_sidebar(assigns) do
    ~H"""
    <div class="text-center lg:text-left">
      <.avatar
        name={@user.username}
        src={@user.avatar_url}
        size={:xl}
        class="mx-auto lg:mx-0"
      />
      <h1 class="mt-4 text-xl font-bold text-slate-900 dark:text-white">
        <%= @user.name || @user.username %>
      </h1>
      <p class="text-sm text-slate-500">@<%= @user.username %></p>
      <p :if={@user.bio} class="mt-3 text-sm text-slate-600 dark:text-slate-400">
        <%= @user.bio %>
      </p>
      <div class="mt-4 space-y-2 text-sm text-slate-500">
        <.metadata_row :if={@user.affiliation} icon="hero-building-library">
          <%= @user.affiliation %>
        </.metadata_row>
      </div>

      <div :if={@organizations != []} class="mt-6">
        <h3 class="text-xs font-semibold uppercase tracking-wider text-slate-400">Organizations</h3>
        <div class="mt-2 flex flex-wrap gap-2">
          <.link
            :for={org <- @organizations}
            navigate={~p"/#{org.slug}"}
            class="rounded-lg border border-slate-200 px-3 py-1.5 text-sm hover:bg-slate-50 dark:border-slate-700 dark:hover:bg-slate-800"
          >
            <%= org.name %>
          </.link>
        </div>
      </div>
    </div>
    """
  end

  defp org_sidebar(assigns) do
    ~H"""
    <div class="text-center lg:text-left">
      <.avatar
        name={@org.name}
        src={@org.avatar_url}
        size={:xl}
        shape={:rounded}
        class="mx-auto lg:mx-0"
      />
      <h1 class="mt-4 text-xl font-bold text-slate-900 dark:text-white">
        <%= @org.name %>
      </h1>
      <p class="text-sm text-slate-500">@<%= @org.slug %></p>
      <div :if={@org_admin} class="mt-2 flex gap-2">
        <.link navigate={~p"/organizations/#{@org.slug}/settings"} class="text-xs text-slate-500 hover:text-primary">
          <.icon name="hero-cog-6-tooth" class="h-4 w-4" /> Settings
        </.link>
        <.link navigate={~p"/organizations/#{@org.slug}/members"} class="text-xs text-slate-500 hover:text-primary">
          <.icon name="hero-user-group" class="h-4 w-4" /> Members
        </.link>
      </div>
      <p :if={@org.description} class="mt-3 text-sm text-slate-600 dark:text-slate-400">
        <%= @org.description %>
      </p>
      <div class="mt-4 space-y-2">
        <.metadata_row :if={@org.website} icon="hero-globe-alt">
          <%= @org.website %>
        </.metadata_row>
        <.metadata_row :if={@org.location} icon="hero-map-pin">
          <%= @org.location %>
        </.metadata_row>
      </div>

      <div :if={@members != []} class="mt-6">
        <h3 class="text-xs font-semibold uppercase tracking-wider text-slate-400">Members</h3>
        <div class="mt-2 flex flex-wrap gap-2">
          <.link
            :for={membership <- @members}
            navigate={~p"/#{membership.user.username}"}
            class="flex items-center gap-2 rounded-lg border border-slate-200 px-3 py-1.5 text-sm hover:bg-slate-50 dark:border-slate-700 dark:hover:bg-slate-800"
          >
            <.avatar name={membership.user.username} src={membership.user.avatar_url} size={:xs} />
            <%= membership.user.username %>
          </.link>
        </div>
      </div>
    </div>
    """
  end

  defp space_path(space) do
    owner = Cyanea.Spaces.owner_display(space)
    ~p"/#{owner}/#{space.slug}"
  end
end
