defmodule Cyanea.Spaces do
  @moduledoc """
  The Spaces context — managing research spaces.

  Spaces are the top-level container in Cyanea, replacing the old
  Repository/Artifact model. Ownership is polymorphic (user or organization).
  """
  import Ecto.Query

  alias Cyanea.Organizations.Membership
  alias Cyanea.Repo
  alias Cyanea.Spaces.Space

  ## Listing

  @doc """
  Lists public spaces, ordered by most recently updated.
  """
  def list_public_spaces(opts \\ []) do
    limit = Keyword.get(opts, :limit, 50)

    from(s in Space,
      where: s.visibility == "public",
      order_by: [desc: s.updated_at],
      limit: ^limit
    )
    |> Repo.all()
  end

  @doc """
  Lists spaces owned by a user.
  """
  def list_user_spaces(user_id, opts \\ []) do
    visibility_filter = Keyword.get(opts, :visibility, nil)

    query =
      from(s in Space,
        where: s.owner_type == "user" and s.owner_id == ^user_id,
        order_by: [desc: s.updated_at]
      )

    query =
      if visibility_filter do
        from(s in query, where: s.visibility == ^visibility_filter)
      else
        query
      end

    Repo.all(query)
  end

  @doc """
  Lists spaces owned by an organization.
  """
  def list_org_spaces(organization_id, opts \\ []) do
    visibility_filter = Keyword.get(opts, :visibility, nil)

    query =
      from(s in Space,
        where: s.owner_type == "organization" and s.owner_id == ^organization_id,
        order_by: [desc: s.updated_at]
      )

    query =
      if visibility_filter do
        from(s in query, where: s.visibility == ^visibility_filter)
      else
        query
      end

    Repo.all(query)
  end

  ## Fetching

  @doc """
  Gets a single space by ID.

  Raises `Ecto.NoResultsError` if the Space does not exist.
  """
  def get_space!(id) do
    Repo.get!(Space, id)
  end

  @doc """
  Gets a space by owner name and slug.

  Tries user-owned first (joins users table), then org-owned (joins organizations table).
  """
  def get_space_by_owner_and_slug(owner_name, slug) do
    owner_name = String.downcase(owner_name)
    slug = String.downcase(slug)

    # Try user-owned
    user_space =
      from(s in Space,
        join: u in Cyanea.Accounts.User,
        on: u.id == s.owner_id and s.owner_type == "user",
        where: u.username == ^owner_name and s.slug == ^slug
      )
      |> Repo.one()

    case user_space do
      nil ->
        # Try org-owned
        from(s in Space,
          join: o in Cyanea.Organizations.Organization,
          on: o.id == s.owner_id and s.owner_type == "organization",
          where: o.slug == ^owner_name and s.slug == ^slug
        )
        |> Repo.one()

      space ->
        space
    end
  end

  ## Create / Update / Delete

  @doc """
  Creates a space.
  """
  def create_space(attrs) do
    %Space{}
    |> Space.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, space} ->
        if space.visibility == "public", do: Cyanea.Search.index_space(space)
        {:ok, space}

      error ->
        error
    end
  end

  @doc """
  Updates a space.
  """
  def update_space(%Space{} = space, attrs) do
    space
    |> Space.changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok, space} ->
        if space.visibility == "public" do
          Cyanea.Search.index_space(space)
        else
          Cyanea.Search.delete_space(space.id)
        end

        {:ok, space}

      error ->
        error
    end
  end

  @doc """
  Deletes a space.
  """
  def delete_space(%Space{} = space) do
    Cyanea.Search.delete_space(space.id)
    Repo.delete(space)
  end

  ## Access Control

  @doc """
  Checks if a user can access a space.

  Public spaces are accessible to everyone. Private spaces require
  the user to be the owner or a member of the owning organization.
  """
  def can_access?(space, nil) do
    space.visibility == "public"
  end

  def can_access?(space, user) do
    cond do
      space.visibility == "public" ->
        true

      space.owner_type == "user" && space.owner_id == user.id ->
        true

      space.owner_type == "organization" ->
        membership =
          Repo.get_by(Membership,
            user_id: user.id,
            organization_id: space.owner_id
          )

        membership != nil

      true ->
        false
    end
  end

  @doc """
  Checks if a user is the owner of a space.
  """
  def owner?(%Space{owner_type: "user", owner_id: owner_id}, %{id: user_id}) do
    owner_id == user_id
  end

  def owner?(_space, _user), do: false

  @doc """
  Returns the display name for a space's owner.
  """
  def owner_display(%Space{owner_type: "user", owner_id: owner_id}) do
    case Repo.get(Cyanea.Accounts.User, owner_id) do
      nil -> "unknown"
      user -> user.username
    end
  end

  def owner_display(%Space{owner_type: "organization", owner_id: owner_id}) do
    case Repo.get(Cyanea.Organizations.Organization, owner_id) do
      nil -> "unknown"
      org -> org.slug
    end
  end
end
