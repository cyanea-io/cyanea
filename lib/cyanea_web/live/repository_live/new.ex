defmodule CyaneaWeb.RepositoryLive.New do
  use CyaneaWeb, :live_view

  alias Cyanea.Repositories
  alias Cyanea.Repositories.Repository

  @impl true
  def mount(_params, _session, socket) do
    changeset =
      Repository.changeset(%Repository{}, %{visibility: "public"})

    {:ok,
     assign(socket,
       page_title: "New Repository",
       form: to_form(changeset)
     )}
  end

  @impl true
  def handle_event("validate", %{"repository" => repo_params}, socket) do
    changeset =
      %Repository{}
      |> Repository.changeset(repo_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  def handle_event("save", %{"repository" => repo_params}, socket) do
    user = socket.assigns.current_user

    repo_params =
      repo_params
      |> Map.put("owner_id", user.id)
      |> maybe_generate_slug()

    case Repositories.create_repository(repo_params) do
      {:ok, repo} ->
        {:noreply,
         socket
         |> put_flash(:info, "Repository created successfully!")
         |> push_navigate(to: ~p"/#{user.username}/#{repo.slug}")}

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
        Create a new repository
        <:subtitle>A repository contains datasets, protocols, and research artifacts.</:subtitle>
      </.header>

      <div class="mt-8 rounded-xl border border-slate-200 bg-white p-8 shadow-sm dark:border-slate-700 dark:bg-slate-800">
        <.simple_form for={@form} phx-change="validate" phx-submit="save">
          <.input field={@form[:name]} type="text" label="Repository name" required placeholder="my-dataset" />
          <.input field={@form[:slug]} type="text" label="Slug" required placeholder="my-dataset"  />
          <.input field={@form[:description]} type="textarea" label="Description" placeholder="A short description of your repository" rows="3" />

          <.input
            field={@form[:visibility]}
            type="select"
            label="Visibility"
            options={[{"Public", "public"}, {"Private", "private"}]}
          />

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
            <.button type="submit" phx-disable-with="Creating...">Create repository</.button>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
  end
end
