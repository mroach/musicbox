defmodule Audio.Alsa do
  require Logger

  def child_spec(_opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start, []},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def start do
    :timer.sleep(5000)
    Task.start(fn -> initialize_alsa() end)
  end

  def initialize_alsa do
    Logger.debug("Start initial alsa device")
    System.cmd("amixer", ["cset", "numid=3", "1"])
    System.cmd("amixer", ["set", "PCM", "50%"])
  end
end
