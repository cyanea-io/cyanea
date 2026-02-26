defmodule CyaneaWeb.NotebookLive.New do
  use CyaneaWeb, :live_view

  alias Cyanea.Notebooks
  alias Cyanea.Notebooks.Notebook
  alias CyaneaWeb.ContentHelpers

  @impl true
  def mount(params, _session, socket) do
    case ContentHelpers.mount_space(socket, params) do
      {:ok, socket} ->
        if socket.assigns.is_owner do
          changeset = Notebooks.change_notebook(%Notebook{}, %{})

          {:ok,
           assign(socket,
             page_title: "New Notebook",
             form: to_form(changeset)
           )}
        else
          {:ok,
           socket
           |> put_flash(:error, "You don't have permission to create notebooks here.")
           |> redirect(to: ~p"/#{socket.assigns.owner_name}/#{socket.assigns.space.slug}")}
        end

      {:error, socket} ->
        {:ok, socket}
    end
  end

  @impl true
  def handle_event("validate", %{"notebook" => notebook_params}, socket) do
    changeset =
      %Notebook{}
      |> Notebook.changeset(notebook_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  def handle_event("save", %{"notebook" => notebook_params}, socket) do
    space = socket.assigns.space

    notebook_params =
      notebook_params
      |> Map.put("space_id", space.id)
      |> Map.put("content", %{"cells" => [default_cell()]})
      |> maybe_generate_slug()

    case Notebooks.create_notebook(notebook_params) do
      {:ok, notebook} ->
        {:noreply,
         socket
         |> put_flash(:info, "Notebook created.")
         |> push_navigate(
           to: ~p"/#{socket.assigns.owner_name}/#{space.slug}/notebooks/#{notebook.slug}"
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp default_cell do
    %{
      "id" => Ecto.UUID.generate(),
      "type" => "markdown",
      "source" => "# New Notebook\n\nStart writing here...",
      "position" => 0
    }
  end

  defp maybe_generate_slug(%{"slug" => slug} = params) when slug != "" and slug != nil, do: params

  defp maybe_generate_slug(%{"title" => title} = params) when is_binary(title) do
    slug =
      title
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
      <.breadcrumb>
        <:crumb navigate={~p"/#{@owner_name}"}><%= @owner_name %></:crumb>
        <:crumb navigate={~p"/#{@owner_name}/#{@space.slug}"}><%= @space.name %></:crumb>
        <:crumb>New Notebook</:crumb>
      </.breadcrumb>

      <.header class="mt-6">
        Create a new notebook
        <:subtitle>Notebooks combine code, markdown, and outputs in a single document.</:subtitle>
      </.header>

      <div class="mt-8 rounded-xl border border-slate-200 bg-white p-8 shadow-sm dark:border-slate-700 dark:bg-slate-800">
        <.simple_form for={@form} phx-change="validate" phx-submit="save">
          <.input field={@form[:title]} type="text" label="Title" required placeholder="PCR Analysis" />
          <.input field={@form[:slug]} type="text" label="Slug" placeholder="pcr-analysis" />

          <:actions>
            <.link
              navigate={~p"/#{@owner_name}/#{@space.slug}"}
              class="text-sm font-medium text-slate-600 hover:text-slate-900 dark:text-slate-400"
            >
              Cancel
            </.link>
            <.button type="submit" phx-disable-with="Creating...">Create notebook</.button>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
  end
end
