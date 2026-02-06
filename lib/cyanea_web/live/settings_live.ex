defmodule CyaneaWeb.SettingsLive do
  use CyaneaWeb, :live_view

  alias Cyanea.Accounts

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    changeset = Accounts.change_user(user)

    {:ok,
     assign(socket,
       page_title: "Settings",
       form: to_form(changeset)
     )}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      socket.assigns.current_user
      |> Accounts.change_user(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    # Don't allow changing email/username/password through profile settings
    safe_params = Map.take(user_params, ["name", "bio", "affiliation", "avatar_url"])

    case Accounts.update_user(socket.assigns.current_user, safe_params) do
      {:ok, user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Profile updated successfully.")
         |> assign(current_user: user, form: to_form(Accounts.change_user(user)))}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-2xl">
      <.header>
        Profile settings
        <:subtitle>Update your profile information visible to other users.</:subtitle>
      </.header>

      <div class="mt-8 rounded-xl border border-slate-200 bg-white p-8 shadow-sm dark:border-slate-700 dark:bg-slate-800">
        <.simple_form for={@form} phx-change="validate" phx-submit="save">
          <div class="flex items-center gap-6">
            <img
              src={@current_user.avatar_url || "https://api.dicebear.com/7.x/initials/svg?seed=#{@current_user.username}"}
              alt={@current_user.username}
              class="h-20 w-20 rounded-full"
            />
            <div>
              <p class="font-semibold text-slate-900 dark:text-white">@<%= @current_user.username %></p>
              <p class="text-sm text-slate-500"><%= @current_user.email %></p>
            </div>
          </div>

          <.input field={@form[:name]} type="text" label="Name" autocomplete="name" />
          <.input field={@form[:bio]} type="textarea" label="Bio" rows="3" placeholder="Tell us about yourself..." />
          <.input field={@form[:affiliation]} type="text" label="Affiliation" placeholder="University, company, or lab" />
          <.input field={@form[:avatar_url]} type="url" label="Avatar URL" placeholder="https://..." />

          <:actions>
            <.button type="submit" phx-disable-with="Saving...">Save changes</.button>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
  end
end
