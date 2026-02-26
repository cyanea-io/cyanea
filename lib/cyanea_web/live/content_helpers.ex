defmodule CyaneaWeb.ContentHelpers do
  @moduledoc """
  Shared mount and access-control helpers for content-type LiveViews.

  Extracts the common pattern of loading a space via owner/slug params,
  checking access, and determining ownership.
  """
  import Phoenix.LiveView
  import Phoenix.Component, only: [assign: 3]

  alias Cyanea.Spaces

  @doc """
  Loads a space from `params`, checks access for `current_user`, and assigns
  `:space`, `:owner_name`, and `:is_owner` to the socket.

  Returns `{:ok, socket}` on success or `{:error, socket}` with a redirect
  on failure.
  """
  def mount_space(socket, %{"username" => owner_name, "slug" => slug}) do
    space = Spaces.get_space_by_owner_and_slug(owner_name, slug)
    current_user = socket.assigns[:current_user]

    cond do
      is_nil(space) ->
        {:error,
         socket
         |> Phoenix.LiveView.put_flash(:error, "Space not found.")
         |> redirect(to: "/explore")}

      not Spaces.can_access?(space, current_user) ->
        {:error,
         socket
         |> Phoenix.LiveView.put_flash(:error, "You don't have access to this space.")
         |> redirect(to: "/explore")}

      true ->
        is_owner = current_user != nil and Spaces.owner?(space, current_user)

        {:ok,
         socket
         |> assign(:space, space)
         |> assign(:owner_name, owner_name)
         |> assign(:is_owner, is_owner)}
    end
  end
end
