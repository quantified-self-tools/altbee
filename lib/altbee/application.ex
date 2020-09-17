defmodule Altbee.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  import Cachex.Spec, only: [expiration: 1]

  def start(_type, _args) do
    children = [
      Altbee.Repo,
      AltbeeWeb.Telemetry,
      {Phoenix.PubSub, name: Altbee.PubSub},
      AltbeeWeb.Endpoint,
      {Cachex,
       name: :goals_cache, expiration: expiration(default: :timer.hours(25)), limit: 2_000}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Altbee.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    AltbeeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
