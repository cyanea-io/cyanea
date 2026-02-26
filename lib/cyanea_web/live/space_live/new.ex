defmodule CyaneaWeb.SpaceLive.New do
  use CyaneaWeb, :live_view

  alias Cyanea.Billing
  alias Cyanea.Spaces
  alias Cyanea.Spaces.Space

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    can_create_private = Billing.can_have_private_spaces?(user)

    changeset =
      Space.changeset(%Space{}, %{visibility: "public"})

    {:ok,
     assign(socket,
       page_title: "New Space",
       form: to_form(changeset),
       can_create_private: can_create_private
     )}
  end

  @impl true
  def handle_event("validate", %{"space" => space_params}, socket) do
    changeset =
      %Space{}
      |> Space.changeset(space_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  def handle_event("save", %{"space" => space_params}, socket) do
    user = socket.assigns.current_user

    space_params =
      space_params
      |> Map.put("owner_type", "user")
      |> Map.put("owner_id", user.id)
      |> maybe_generate_slug()

    case Spaces.create_space(space_params) do
      {:ok, space} ->
        {:noreply,
         socket
         |> put_flash(:info, "Space created successfully!")
         |> push_navigate(to: ~p"/#{user.username}/#{space.slug}")}

      {:error, :pro_required} ->
        {:noreply,
         socket
         |> put_flash(:error, "Private spaces require a Pro plan. Upgrade to unlock private spaces.")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp maybe_generate_slug(%{"slug" => slug} = params) when slug != "" and slug != nil, do: params

  defp maybe_generate_slug(%{"name" => name} = params) when is_binary(name) do
    slug =
      name
      |> String.downcase()
      |> String.replace(~r/[^a-z0-9._-]+/, "-")
      |> String.trim("-")

    Map.put(params, "slug", slug)
  end

  defp maybe_generate_slug(params), do: params

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-2xl">
      <.header>
        Create a new space
        <:subtitle>A space contains datasets, protocols, notebooks, and research files.</:subtitle>
      </.header>

      <div class="mt-8 rounded-xl border border-slate-200 bg-white p-8 shadow-sm dark:border-slate-700 dark:bg-slate-800">
        <.simple_form for={@form} phx-change="validate" phx-submit="save">
          <.input field={@form[:name]} type="text" label="Space name" required placeholder="my-dataset" />
          <.input field={@form[:slug]} type="text" label="Slug" required placeholder="my-dataset" />
          <.input field={@form[:description]} type="textarea" label="Description" placeholder="A short description of your space" rows="3" />

          <.input
            field={@form[:visibility]}
            type="select"
            label="Visibility"
            options={[{"Public", "public"}, {"Private", "private"}]}
          />

          <p :if={!@can_create_private} class="-mt-2 text-sm text-slate-500">
            Private spaces require a Pro plan.
            <.link navigate={~p"/settings/billing"} class="font-medium text-primary hover:underline">
              Upgrade to Pro
            </.link>
          </p>

          <.input
            field={@form[:license]}
            type="select"
            label="License"
            prompt="Choose a license (optional)"
            options={[
              {"CC BY 4.0", "cc-by-4.0"},
              {"CC BY-SA 4.0", "cc-by-sa-4.0"},
              {"CC0 1.0 (Public Domain)", "cc0-1.0"},
              {"MIT", "mit"},
              {"Apache 2.0", "apache-2.0"},
              {"Proprietary", "proprietary"}
            ]}
          />

          <:actions>
            <.link navigate={~p"/dashboard"} class="text-sm font-medium text-slate-600 hover:text-slate-900 dark:text-slate-400">
              Cancel
            </.link>
            <.button type="submit" phx-disable-with="Creating...">Create space</.button>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
  end
end
