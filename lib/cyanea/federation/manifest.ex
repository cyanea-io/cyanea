defmodule Cyanea.Federation.Manifest do
  @moduledoc """
  Signed manifest — an attestation that a specific space version
  has been published to the federation network.

  Manifests are content-addressed: the `content_hash` covers the
  space's data, and the optional `signature` proves provenance
  via the signer's public key.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "manifests" do
    field :global_id, :string
    field :content_hash, :string
    field :signature, :string
    field :signer_key_id, :string
    field :payload, :map, default: %{}
    field :status, :string, default: "published"
    field :retracted_reason, :string
    field :revision_number, :integer

    belongs_to :space, Cyanea.Spaces.Space
    belongs_to :node, Cyanea.Federation.Node

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(manifest, attrs) do
    manifest
    |> cast(attrs, [
      :global_id,
      :content_hash,
      :signature,
      :signer_key_id,
      :payload,
      :status,
      :retracted_reason,
      :revision_number,
      :space_id,
      :node_id
    ])
    |> validate_required([:global_id, :content_hash])
    |> unique_constraint(:global_id)
  end
end
