defmodule CyaneaWeb.Plugs.RateLimit do
  @moduledoc """
  Plug that rate-limits API requests using Hammer.

  Rates:
  - API key: 1000 req / 15 min (keyed by token_prefix)
  - JWT: 5000 req / 15 min (keyed by user_id)
  - Unauthenticated: 100 req / 15 min (keyed by IP)
  """
  import Plug.Conn

  @fifteen_minutes 60_000 * 15

  def init(opts), do: opts

  def call(conn, _opts) do
    if rate_limit_enabled?() do
      check_rate_limit(conn)
    else
      conn
    end
  end

  defp check_rate_limit(%{assigns: %{api_token: token}} = conn) do
    do_check(conn, "api_token:#{token.token_prefix}", 1000)
  end

  defp check_rate_limit(%{assigns: %{jwt_claims: _, current_user: user}} = conn) do
    do_check(conn, "jwt:#{user.id}", 5000)
  end

  defp check_rate_limit(conn) do
    ip = conn.remote_ip |> :inet.ntoa() |> to_string()
    do_check(conn, "ip:#{ip}", 100)
  end

  defp do_check(conn, key, limit) do
    case Hammer.check_rate("api:#{key}", @fifteen_minutes, limit) do
      {:allow, _count} ->
        conn

      {:deny, _limit} ->
        retry_after = div(@fifteen_minutes, 1000)

        conn
        |> put_resp_header("retry-after", to_string(retry_after))
        |> put_status(:too_many_requests)
        |> Phoenix.Controller.json(%{
          error: %{status: 429, message: "Rate limit exceeded. Try again later."}
        })
        |> halt()
    end
  end

  defp rate_limit_enabled? do
    Application.get_env(:cyanea, :rate_limit_enabled, true)
  end
end
