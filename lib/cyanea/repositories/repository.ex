defmodule Cyanea.Repositories.Repository do
  @moduledoc """
  Repository schema - the core container for research data.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @visibility ~w(public private)
  @licenses ~w(cc-by-4.0 cc-by-sa-4.0 cc0-1.0 mit apache-2.0 proprietary)

  schema "repositories" do
    field :name, :string
    field :slug, :string
    field :description, :string
    field :visibility, :string, default: "private"
    field :license, :string
    field :default_branch, :string, default: "main"
    field :stars_count, :integer, default: 0
    field :forks_count, :integer, default: 0
    field :archived, :boolean, default: false

    # Ontology tags (stored as JSONB)
    field :tags, {:array, :string}, default: []
    field :ontology_terms, {:array, :map}, default: []

    belongs_to :owner, Cyanea.Accounts.User
    belongs_to :organization, Cyanea.Organizations.Organization
    has_many :commits, Cyanea.Repositories.Commit
    has_many :files, Cyanea.Files.File

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(repository, attrs) do
    repository
    |> cast(attrs, [:name, :slug, :description, :visibility, :license, :default_branch, :tags, :ontology_terms, :owner_id, :organization_id, :archived])
    |> validate_required([:name, :slug])
    |> validate_format(:slug, ~r/^[a-z0-9][a-z0-9._-]*$/, message: "must start with a letter/number and contain only lowercase letters, numbers, dots, hyphens, and underscores")
    |> validate_length(:slug, min: 1, max: 100)
    |> validate_length(:name, min: 1, max: 100)
    |> validate_inclusion(:visibility, @visibility)
    |> validate_inclusion(:license, @licenses ++ [nil])
    |> validate_owner_or_org()
    |> unique_constraint([:slug, :owner_id])
    |> unique_constraint([:slug, :organization_id])
  end

  defp validate_owner_or_org(changeset) do
    owner_id = get_field(changeset, :owner_id)
    org_id = get_field(changeset, :organization_id)

    cond do
      owner_id && org_id ->
        add_error(changeset, :owner_id, "repository cannot have both owner and organization")

      !owner_id && !org_id ->
        add_error(changeset, :owner_id, "repository must have either an owner or organization")

      true ->
        changeset
    end
  end

  def visibilities, do: @visibility
  def licenses, do: @licenses
end
