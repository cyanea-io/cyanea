defmodule CyaneaWeb.AuthLive.Register do
  use CyaneaWeb, :live_view

  alias Cyanea.Accounts
  alias Cyanea.Accounts.User

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user(%User{})
    {:ok, assign(socket, form: to_form(changeset), page_title: "Sign up")}
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      %User{}
      |> Accounts.change_user(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Account created successfully!")
         |> redirect(to: ~p"/auth/login?#{%{email: user.email}}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-md py-12">
      <div class="text-center">
        <h1 class="text-2xl font-bold text-slate-900 dark:text-white">Create your account</h1>
        <p class="mt-2 text-sm text-slate-600 dark:text-slate-400">
          Already have an account?
          <.link navigate={~p"/auth/login"} class="font-medium text-cyan-600 hover:text-cyan-500">
            Sign in
          </.link>
        </p>
      </div>

      <div class="mt-8 rounded-xl border border-slate-200 bg-white p-8 shadow-sm dark:border-slate-700 dark:bg-slate-800">
        <.simple_form for={@form} phx-change="validate" phx-submit="save">
          <.input field={@form[:email]} type="email" label="Email" required autocomplete="email" />
          <.input field={@form[:username]} type="text" label="Username" required autocomplete="username" />
          <.input field={@form[:name]} type="text" label="Full name" autocomplete="name" />
          <.input field={@form[:password]} type="password" label="Password" required autocomplete="new-password" />

          <:actions>
            <.button type="submit" phx-disable-with="Creating account..." class="w-full">
              Create account
            </.button>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
  end
end
