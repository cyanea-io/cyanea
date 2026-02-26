defmodule CyaneaWeb.Plugs.RateLimitTest do
  use CyaneaWeb.ConnCase

  alias CyaneaWeb.Plugs.RateLimit

  test "passes through when rate limiting is disabled", %{conn: conn} do
    # Rate limiting is disabled in test config
    conn =
      conn
      |> assign(:current_user, nil)
      |> RateLimit.call([])

    refute conn.halted
  end

  test "init returns opts" do
    assert RateLimit.init([]) == []
  end
end
