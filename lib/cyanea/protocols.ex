defmodule Cyanea.Protocols do
  @moduledoc """
  The Protocols context — versioned experimental procedures within spaces.
  """
  import Ecto.Query

  alias Cyanea.Protocols.Protocol
  alias Cyanea.Repo

  ## Listing

  @doc """
  Lists protocols in a space, ordered by position then title.
  """
  def list_space_protocols(space_id) do
    from(p in Protocol,
      where: p.space_id == ^space_id,
      order_by: [asc: p.position, asc: p.title]
    )
    |> Repo.all()
  end

  ## Fetching

  @doc """
  Gets a single protocol by ID. Raises if not found.
  """
  def get_protocol!(id), do: Repo.get!(Protocol, id)

  @doc """
  Gets a protocol by space ID and slug.
  """
  def get_protocol_by_slug(space_id, slug) do
    Repo.get_by(Protocol, space_id: space_id, slug: String.downcase(slug))
  end

  ## Create / Update / Delete

  @doc """
  Creates a protocol in a space.
  """
  def create_protocol(attrs) do
    %Protocol{}
    |> Protocol.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a protocol.
  """
  def update_protocol(%Protocol{} = protocol, attrs) do
    protocol
    |> Protocol.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a protocol.
  """
  def delete_protocol(%Protocol{} = protocol) do
    Repo.delete(protocol)
  end
end
