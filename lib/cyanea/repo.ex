defmodule Cyanea.Repo do
  use Ecto.Repo,
    otp_app: :cyanea,
    adapter: Ecto.Adapters.Postgres
end
