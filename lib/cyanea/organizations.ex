defmodule Cyanea.Organizations do
  @moduledoc """
  The Organizations context - managing organizations, memberships, and teams.
  """
  import Ecto.Query

  alias Cyanea.Repo
  alias Cyanea.Organizations.{Organization, Membership}

  ## Organizations

  @doc """
  Lists organizations a user belongs to.
  """
  def list_user_organizations(user_id) do
    from(o in Organization,
      join: m in Membership,
      on: m.organization_id == o.id,
      where: m.user_id == ^user_id,
      order_by: [asc: o.name]
    )
    |> Repo.all()
  end

  @doc """
  Gets a single organization by ID.

  Raises `Ecto.NoResultsError` if the Organization does not exist.
  """
  def get_organization!(id), do: Repo.get!(Organization, id)

  @doc """
  Gets an organization by slug.
  """
  def get_organization_by_slug(slug) when is_binary(slug) do
    Repo.get_by(Organization, slug: String.downcase(slug))
  end

  @doc """
  Creates an organization and adds the creator as owner.
  """
  def create_organization(attrs, creator_user_id) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:organization, Organization.changeset(%Organization{}, attrs))
    |> Ecto.Multi.insert(:membership, fn %{organization: org} ->
      Membership.changeset(%Membership{}, %{
        user_id: creator_user_id,
        organization_id: org.id,
        role: "owner"
      })
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{organization: org}} -> {:ok, org}
      {:error, :organization, changeset, _} -> {:error, changeset}
      {:error, :membership, changeset, _} -> {:error, changeset}
    end
  end

  @doc """
  Updates an organization.
  """
  def update_organization(%Organization{} = organization, attrs) do
    organization
    |> Organization.changeset(attrs)
    |> Repo.update()
  end

  ## Memberships

  @doc """
  Gets a user's membership in an organization.
  Returns nil if the user is not a member.
  """
  def get_membership(user_id, organization_id) do
    Repo.get_by(Membership, user_id: user_id, organization_id: organization_id)
  end

  @doc """
  Lists all members of an organization with their user data.
  """
  def list_members(organization_id) do
    from(m in Membership,
      where: m.organization_id == ^organization_id,
      join: u in assoc(m, :user),
      preload: [user: u],
      order_by: [asc: u.username]
    )
    |> Repo.all()
  end
end
