defmodule Cyanea.StarsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Cyanea.Stars` context.
  """

  def star_fixture(attrs \\ %{}) do
    user_id = Map.fetch!(attrs, :user_id)
    space_id = Map.fetch!(attrs, :space_id)

    {:ok, star} = Cyanea.Stars.star_space(user_id, space_id)
    star
  end
end
