defmodule MusicboxWeb.SystemController do
  use MusicboxWeb, :controller

  def alive(conn, _params) do
    text(conn, "OK")
  end

  def stats(conn, _params) do
    data = %{
      elixir: SystemInfo.elixir_info(),
      vm_stats: SystemInfo.vm_stats(),
      platform: SystemInfo.platform(),
      hardware: SystemInfo.hardware(),
      network: SystemInfo.network()
    }

    json(conn, data)
  end
end
