defmodule Musicbox.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      paracusia_genserver(),
      Musicbox.Player,
      # Start the endpoint when the application starts
      MusicboxWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Musicbox.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp paracusia_genserver do
    %{
      id: Paracusia,
      start: {Paracusia, :start, [:normal, []]}
    }
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    MusicboxWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
