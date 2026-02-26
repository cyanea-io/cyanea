defmodule Cyanea.Webhooks.Webhook do
  @moduledoc """
  Schema for webhooks — HTTP callbacks for space events.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @valid_events ~w(space.created space.updated space.deleted space.forked space.starred)

  schema "webhooks" do
    field :url, :string
    field :secret, :string
    field :events, {:array, :string}
    field :active, :boolean, default: true
    field :description, :string

    belongs_to :user, Cyanea.Accounts.User
    belongs_to :space, Cyanea.Spaces.Space

    timestamps(type: :utc_datetime)
  end

  def changeset(webhook, attrs) do
    webhook
    |> cast(attrs, [:url, :secret, :events, :active, :description, :user_id, :space_id])
    |> validate_required([:url, :secret, :events, :user_id])
    |> validate_url()
    |> validate_events()
  end

  defp validate_url(changeset) do
    validate_change(changeset, :url, fn :url, url ->
      uri = URI.parse(url)

      if uri.scheme in ["http", "https"] && uri.host not in [nil, ""] do
        []
      else
        [url: "must be a valid HTTP or HTTPS URL"]
      end
    end)
  end

  defp validate_events(changeset) do
    validate_change(changeset, :events, fn :events, events ->
      if events != [] && Enum.all?(events, &(&1 in @valid_events)) do
        []
      else
        [events: "must contain at least one valid event: #{Enum.join(@valid_events, ", ")}"]
      end
    end)
  end

  def valid_events, do: @valid_events
end
