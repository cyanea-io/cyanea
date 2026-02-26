defmodule Cyanea.Stars do
  @moduledoc """
  The Stars context — user bookmarks on spaces.

  Star/unstar operations use Ecto.Multi to atomically update
  the space's `star_count` counter cache.
  """
  import Ecto.Query

  alias Cyanea.Repo
  alias Cyanea.Spaces.Space
  alias Cyanea.Stars.Star

  @doc """
  Stars a space for a user. Atomically increments star_count.
  Returns `{:ok, star}` or `{:error, changeset}`.
  """
  def star_space(user_id, space_id) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:star, Star.changeset(%Star{}, %{user_id: user_id, space_id: space_id}))
    |> Ecto.Multi.update_all(:increment, fn _changes ->
      from(s in Space, where: s.id == ^space_id, update: [inc: [star_count: 1]])
    end, [])
    |> Repo.transaction()
    |> case do
      {:ok, %{star: star}} ->
        space = Cyanea.Repo.get(Space, space_id)
        if space, do: Cyanea.Webhooks.dispatch_event("space.starred", space, %{space_id: space_id, user_id: user_id})
        {:ok, star}

      {:error, :star, changeset, _} ->
        {:error, changeset}
    end
  end

  @doc """
  Unstars a space for a user. Atomically decrements star_count.
  Returns `:ok` or `{:error, :not_starred}`.
  """
  def unstar_space(user_id, space_id) do
    case Repo.get_by(Star, user_id: user_id, space_id: space_id) do
      nil ->
        {:error, :not_starred}

      star ->
        Ecto.Multi.new()
        |> Ecto.Multi.delete(:star, star)
        |> Ecto.Multi.update_all(:decrement, fn _changes ->
          from(s in Space,
            where: s.id == ^space_id and s.star_count > 0,
            update: [inc: [star_count: -1]]
          )
        end, [])
        |> Repo.transaction()
        |> case do
          {:ok, _} -> :ok
          {:error, _, _, _} -> {:error, :unstar_failed}
        end
    end
  end

  @doc """
  Returns true if the user has starred the space.
  """
  def starred?(user_id, space_id) do
    from(s in Star, where: s.user_id == ^user_id and s.space_id == ^space_id)
    |> Repo.exists?()
  end

  @doc """
  Lists spaces starred by a user, ordered by most recently starred.
  """
  def list_user_stars(user_id, opts \\ []) do
    limit = Keyword.get(opts, :limit, 50)

    from(s in Star,
      where: s.user_id == ^user_id,
      order_by: [desc: s.inserted_at],
      limit: ^limit,
      preload: [:space]
    )
    |> Repo.all()
  end
end
