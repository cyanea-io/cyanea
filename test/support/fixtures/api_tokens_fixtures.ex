defmodule Cyanea.ApiTokensFixtures do
  @moduledoc "Test fixtures for API tokens."

  alias Cyanea.ApiTokens

  def valid_token_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      name: "Test Token #{System.unique_integer([:positive])}",
      scopes: ["read", "write"]
    })
  end

  def api_token_fixture(user, attrs \\ %{}) do
    attrs = valid_token_attributes(attrs)
    {:ok, api_token, raw_token} = ApiTokens.create_token(user, attrs)
    {api_token, raw_token}
  end
end
