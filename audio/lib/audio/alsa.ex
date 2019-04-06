defmodule Audio.Alsa do
  use Task # we should play with this when testing on the pi instead of relying on on sleep, restart: :transient

  require Logger

  def start_link(_arg) do
    :timer.sleep(5000)
    Task.start(fn -> initialize_alsa() end)
  end

  def initialize_alsa do
    Logger.debug("Start initial alsa device")

    System.cmd("amixer", ["cset", "numid=3", "1"])
    System.cmd("amixer", ["set", "PCM", "50%"])
  end
end
