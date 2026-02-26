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

  @doc """
  Returns a changeset for tracking protocol changes in forms.
  """
  def change_protocol(%Protocol{} = protocol, attrs \\ %{}) do
    Protocol.changeset(protocol, attrs)
  end

  ## Section Management

  @doc """
  Updates the materials section in the protocol content.
  """
  def update_materials(%Protocol{} = protocol, materials) when is_list(materials) do
    content = Map.merge(protocol.content || %{}, %{"materials" => materials})
    update_protocol(protocol, %{content: content})
  end

  @doc """
  Updates the equipment section in the protocol content.
  """
  def update_equipment(%Protocol{} = protocol, equipment) when is_list(equipment) do
    content = Map.merge(protocol.content || %{}, %{"equipment" => equipment})
    update_protocol(protocol, %{content: content})
  end

  @doc """
  Updates the steps section, auto-numbering each step.
  """
  def update_steps(%Protocol{} = protocol, steps) when is_list(steps) do
    numbered_steps =
      steps
      |> Enum.with_index(1)
      |> Enum.map(fn {step, idx} -> Map.put(step, "number", idx) end)

    content = Map.merge(protocol.content || %{}, %{"steps" => numbered_steps})
    update_protocol(protocol, %{content: content})
  end

  @doc """
  Updates the tips section in the protocol content.
  """
  def update_tips(%Protocol{} = protocol, tips) when is_binary(tips) do
    content = Map.merge(protocol.content || %{}, %{"tips" => tips})
    update_protocol(protocol, %{content: content})
  end

  @doc """
  Bumps the protocol version by the specified level.
  """
  def bump_version(%Protocol{} = protocol, level) when level in [:patch, :minor, :major] do
    version = protocol.version || "1.0.0"

    case String.split(version, ".") do
      [major, minor, patch] ->
        {major, _} = Integer.parse(major)
        {minor, _} = Integer.parse(minor)
        {patch, _} = Integer.parse(patch)

        new_version =
          case level do
            :patch -> "#{major}.#{minor}.#{patch + 1}"
            :minor -> "#{major}.#{minor + 1}.0"
            :major -> "#{major + 1}.0.0"
          end

        update_protocol(protocol, %{version: new_version})

      _ ->
        update_protocol(protocol, %{version: "1.0.1"})
    end
  end

  ## Content Accessors

  @doc "Returns the materials list from protocol content."
  def get_materials(%Protocol{content: content}) when is_map(content),
    do: Map.get(content, "materials", [])

  def get_materials(_), do: []

  @doc "Returns the equipment list from protocol content."
  def get_equipment(%Protocol{content: content}) when is_map(content),
    do: Map.get(content, "equipment", [])

  def get_equipment(_), do: []

  @doc "Returns the steps list from protocol content."
  def get_steps(%Protocol{content: content}) when is_map(content),
    do: Map.get(content, "steps", [])

  def get_steps(_), do: []

  @doc "Returns the tips string from protocol content."
  def get_tips(%Protocol{content: content}) when is_map(content),
    do: Map.get(content, "tips", "")

  def get_tips(_), do: ""
end
