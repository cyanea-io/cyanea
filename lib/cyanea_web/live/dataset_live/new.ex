defmodule CyaneaWeb.DatasetLive.New do
  use CyaneaWeb, :live_view

  alias Cyanea.Datasets
  alias Cyanea.Datasets.Dataset
  alias CyaneaWeb.ContentHelpers

  @impl true
  def mount(params, _session, socket) do
    case ContentHelpers.mount_space(socket, params) do
      {:ok, socket} ->
        if socket.assigns.is_owner do
          changeset = Datasets.change_dataset(%Dataset{}, %{storage_type: "local"})

          {:ok,
           assign(socket,
             page_title: "New Dataset",
             form: to_form(changeset)
           )}
        else
          {:ok,
           socket
           |> put_flash(:error, "You don't have permission to create datasets here.")
           |> redirect(to: ~p"/#{socket.assigns.owner_name}/#{socket.assigns.space.slug}")}
        end

      {:error, socket} ->
        {:ok, socket}
    end
  end

  @impl true
  def handle_event("validate", %{"dataset" => dataset_params}, socket) do
    changeset =
      %Dataset{}
      |> Dataset.changeset(dataset_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  def handle_event("save", %{"dataset" => dataset_params}, socket) do
    space = socket.assigns.space

    dataset_params =
      dataset_params
      |> Map.put("space_id", space.id)
      |> Map.put("metadata", %{})
      |> parse_tags()
      |> maybe_generate_slug()

    case Datasets.create_dataset(dataset_params) do
      {:ok, dataset} ->
        {:noreply,
         socket
         |> put_flash(:info, "Dataset created.")
         |> push_navigate(
           to: ~p"/#{socket.assigns.owner_name}/#{space.slug}/datasets/#{dataset.slug}"
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp parse_tags(%{"tags" => tags_str} = params) when is_binary(tags_str) do
    tags =
      tags_str
      |> String.split(",")
      |> Enum.map(&String.trim/1)
      |> Enum.reject(&(&1 == ""))

    Map.put(params, "tags", tags)
  end

  defp parse_tags(params), do: params

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
      <.breadcrumb>
        <:crumb navigate={~p"/#{@owner_name}"}><%= @owner_name %></:crumb>
        <:crumb navigate={~p"/#{@owner_name}/#{@space.slug}"}><%= @space.name %></:crumb>
        <:crumb>New Dataset</:crumb>
      </.breadcrumb>

      <.header class="mt-6">
        Create a new dataset
        <:subtitle>Datasets hold structured data files with metadata and previews.</:subtitle>
      </.header>

      <div class="mt-8 rounded-xl border border-slate-200 bg-white p-8 shadow-sm dark:border-slate-700 dark:bg-slate-800">
        <.simple_form for={@form} phx-change="validate" phx-submit="save">
          <.input field={@form[:name]} type="text" label="Name" required placeholder="RNA-seq counts" />
          <.input field={@form[:slug]} type="text" label="Slug" placeholder="rna-seq-counts" />
          <.input field={@form[:description]} type="textarea" label="Description" placeholder="Description of the dataset" rows="3" />
          <.input
            field={@form[:storage_type]}
            type="select"
            label="Storage type"
            options={[{"Local", "local"}, {"External URL", "external"}]}
          />
          <.input field={@form[:external_url]} type="text" label="External URL" placeholder="https://..." />
          <.input field={@form[:tags]} type="text" label="Tags" placeholder="genomics, rna-seq, human (comma-separated)" />

          <:actions>
            <.link
              navigate={~p"/#{@owner_name}/#{@space.slug}"}
              class="text-sm font-medium text-slate-600 hover:text-slate-900 dark:text-slate-400"
            >
              Cancel
            </.link>
            <.button type="submit" phx-disable-with="Creating...">Create dataset</.button>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
  end
end
