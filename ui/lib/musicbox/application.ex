defmodule Musicbox.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      paracusia_genserver(),
      Musicbox.Player,
      MusicboxWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Musicbox.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp paracusia_genserver do
    %{
      id: Paracusia,
      start: {Paracusia, :start, [:normal, []]}
    }
  end

  def config_change(changed, _new, removed) do
    MusicboxWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
