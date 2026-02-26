defmodule CyaneaWeb.Api.V1.OrganizationController do
  use CyaneaWeb, :controller

  alias Cyanea.{Organizations, Spaces}
  alias CyaneaWeb.Api.V1.ApiHelpers

  @doc "GET /api/v1/orgs/:slug"
  def show(conn, %{"slug" => slug}) do
    case Organizations.get_organization_by_slug(slug) do
      nil ->
        conn |> put_status(:not_found) |> json(%{error: %{status: 404, message: "Organization not found"}})

      org ->
        json(conn, %{data: ApiHelpers.serialize_organization(org)})
    end
  end

  @doc "GET /api/v1/orgs/:slug/spaces"
  def spaces(conn, %{"slug" => slug} = params) do
    case Organizations.get_organization_by_slug(slug) do
      nil ->
        conn |> put_status(:not_found) |> json(%{error: %{status: 404, message: "Organization not found"}})

      org ->
        current_user = conn.assigns[:current_user]

        # Show all spaces if user is a member, otherwise only public
        all_spaces = Spaces.list_org_spaces(org.id)

        visible_spaces =
          if current_user do
            case Organizations.get_membership(current_user.id, org.id) do
              nil -> Enum.filter(all_spaces, &(&1.visibility == "public"))
              _membership -> all_spaces
            end
          else
            Enum.filter(all_spaces, &(&1.visibility == "public"))
          end

        result = ApiHelpers.paginate(Enum.map(visible_spaces, &ApiHelpers.serialize_space/1), params)

        json(conn, %{
          data: result.items,
          meta: %{page: result.page, per_page: result.per_page, total: result.total}
        })
    end
  end

  @doc "GET /api/v1/orgs/:slug/members"
  def members(conn, %{"slug" => slug}) do
    case Organizations.get_organization_by_slug(slug) do
      nil ->
        conn |> put_status(:not_found) |> json(%{error: %{status: 404, message: "Organization not found"}})

      org ->
        members = Organizations.list_members(org.id)

        data =
          Enum.map(members, fn membership ->
            %{
              user: ApiHelpers.serialize_user(membership.user),
              role: membership.role,
              joined_at: membership.inserted_at && DateTime.to_iso8601(membership.inserted_at)
            }
          end)

        json(conn, %{data: data})
    end
  end
end
