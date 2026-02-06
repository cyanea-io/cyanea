defmodule CyaneaWeb.AuthLive.Login do
  use CyaneaWeb, :live_view

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")

    {:ok, assign(socket, form: form, page_title: "Sign in")}
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-md py-12">
      <div class="text-center">
        <h1 class="text-2xl font-bold text-slate-900 dark:text-white">Sign in to Cyanea</h1>
        <p class="mt-2 text-sm text-slate-600 dark:text-slate-400">
          Don't have an account?
          <.link navigate={~p"/auth/register"} class="font-medium text-cyan-600 hover:text-cyan-500">
            Sign up
          </.link>
        </p>
      </div>

      <div class="mt-8 rounded-xl border border-slate-200 bg-white p-8 shadow-sm dark:border-slate-700 dark:bg-slate-800">
        <.simple_form
          for={@form}
          as={:user}
          action={~p"/auth/login"}
          phx-update="ignore"
        >
          <.input field={@form[:email]} type="email" label="Email" required autocomplete="email" />
          <.input field={@form[:password]} type="password" label="Password" required autocomplete="current-password" />

          <:actions>
            <.button type="submit" class="w-full">
              Sign in
            </.button>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
  end
end
