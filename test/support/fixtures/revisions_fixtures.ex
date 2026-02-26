defmodule Cyanea.RevisionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Cyanea.Revisions` context.
  """

  def valid_revision_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      summary: "Revision #{System.unique_integer([:positive])}",
      content_hash: :crypto.hash(:sha256, "rev-#{System.unique_integer()}") |> Base.encode16(case: :lower)
    })
  end

  def revision_fixture(attrs \\ %{}) do
    attrs = valid_revision_attributes(attrs)

    unless Map.has_key?(attrs, :space_id) && Map.has_key?(attrs, :author_id) do
      raise "revision_fixture requires :space_id and :author_id"
    end

    {:ok, revision} = Cyanea.Revisions.create_revision(attrs)
    revision
  end
end
