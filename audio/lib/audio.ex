defmodule Audio do
  @moduledoc false

  use Application
  require Logger

  @target Mix.target()

  def start(_type, _args) do
    Logger.debug("Starting AudioProvider")

    opts = [strategy: :one_for_one, name: Audio.Supervisor]
    children = children(@target)
    Supervisor.start_link(children, opts)
  end

  defp children(:host) do
    [
    ]
  end

  defp children(_) do
    [
      Audio.Mpd,
      Audio.Alsa,
    ]
  end
end
