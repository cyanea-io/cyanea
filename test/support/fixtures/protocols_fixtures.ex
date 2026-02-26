defmodule Cyanea.ProtocolsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Cyanea.Protocols` context.
  """

  def unique_protocol_title, do: "Protocol #{System.unique_integer([:positive])}"
  def unique_protocol_slug, do: "protocol-#{System.unique_integer([:positive])}"

  def valid_protocol_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      title: unique_protocol_title(),
      slug: unique_protocol_slug(),
      description: "A test protocol",
      content: %{
        "materials" => [
          %{"name" => "Taq Polymerase", "quantity" => "1 uL", "vendor" => "NEB", "catalog_number" => "M0273"}
        ],
        "equipment" => [
          %{"name" => "Thermocycler", "settings" => "Standard PCR", "notes" => ""}
        ],
        "steps" => [
          %{"number" => 1, "description" => "Prepare master mix", "duration" => "5 min", "temperature" => "4C", "notes" => "Keep on ice"}
        ],
        "tips" => "If bands are faint, increase template concentration."
      },
      version: "1.0.0",
      position: 0
    })
  end

  def protocol_fixture(attrs \\ %{}) do
    attrs = valid_protocol_attributes(attrs)

    unless Map.has_key?(attrs, :space_id) do
      raise "protocol_fixture requires :space_id"
    end

    {:ok, protocol} = Cyanea.Protocols.create_protocol(attrs)
    protocol
  end
end
