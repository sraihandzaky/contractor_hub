defmodule ContractorHub.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do

    ContractorHub.TelemetryHandler.attach()

    children = [
      ContractorHubWeb.Telemetry,
      ContractorHub.Repo,
      {DNSCluster, query: Application.get_env(:contractor_hub, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ContractorHub.PubSub},
      # Start a worker by calling: ContractorHub.Worker.start_link(arg)
      # {ContractorHub.Worker, arg},
      # Start to serve requests, typically the last entry
      ContractorHubWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ContractorHub.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ContractorHubWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
