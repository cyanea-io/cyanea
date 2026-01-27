defmodule Cyanea.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CyaneaWeb.Telemetry,
      Cyanea.Repo,
      {DNSCluster, query: Application.get_env(:cyanea, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Cyanea.PubSub},
      {Finch, name: Cyanea.Finch},
      {Oban, Application.fetch_env!(:cyanea, Oban)},
      CyaneaWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Cyanea.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    CyaneaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
