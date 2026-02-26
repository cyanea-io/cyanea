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

  @doc """
  Creates a space via direct Repo insert, bypassing billing checks.

  This allows tests to create private spaces regardless of the owner's plan.
  Tests that specifically need to verify billing enforcement should call
  `Spaces.create_space/1` directly instead.
  """
  def space_fixture(attrs \\ %{}) do
    attrs = valid_space_attributes(attrs)

    unless Map.has_key?(attrs, :owner_type) && Map.has_key?(attrs, :owner_id) do
      raise "space_fixture requires :owner_type and :owner_id"
    end

    %Cyanea.Spaces.Space{}
    |> Cyanea.Spaces.Space.changeset(attrs)
    |> Cyanea.Repo.insert!()
  end
end
