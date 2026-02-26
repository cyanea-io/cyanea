defmodule Cyanea.Notebooks.Execution do
  @moduledoc "Execution engine interface for notebook cells."

  @doc "Returns true if the given language supports execution."
  def executable?("cyanea"), do: true
  def executable?("elixir"), do: true
  def executable?(_), do: false

  @doc "Returns the execution target for a language."
  def execution_target("cyanea"), do: :wasm
  def execution_target("elixir"), do: :server
  def execution_target(_), do: :server_coming_soon

  @doc "Returns languages that execute on the server."
  def server_languages, do: ~w(elixir)

  @doc "Returns all supported code cell languages."
  def supported_languages, do: ~w(cyanea elixir python r bash sql)

  @doc "Returns languages that execute via WASM."
  def wasm_languages, do: ~w(cyanea)
end
