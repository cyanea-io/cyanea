defmodule Cyanea.SpacesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Cyanea.Spaces` context.
  """

  def unique_space_name, do: "Space #{System.unique_integer([:positive])}"
  def unique_space_slug, do: "space-#{System.unique_integer([:positive])}"

  def valid_space_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      name: unique_space_name(),
      slug: unique_space_slug(),
      description: "A test space",
      visibility: "public"
    })
  end

  def space_fixture(attrs \\ %{}) do
    attrs = valid_space_attributes(attrs)

    unless Map.has_key?(attrs, :owner_type) && Map.has_key?(attrs, :owner_id) do
      raise "space_fixture requires :owner_type and :owner_id"
    end

    {:ok, space} = Cyanea.Spaces.create_space(attrs)
    space
  end
end
