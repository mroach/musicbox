defmodule HID.Display do
  use GenServer
  require Pcd8544
  require Logger

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_opts) do
    {:ok, pcd} = Pcd8544.start_link(spi_dev: 1, dc_pin: 27)
    Pcd8544.clear
    Pcd8544.cursorpos(0, 0)
    Pcd8544.write("MusicBox v0.1")
    {:ok, %{pcd: pcd}}
  end

  def update_player_status(%{status: status} = player_status) do
    update_song_name(Map.get(player_status, :current_song))
    update_play_status(status)
  end
  def update_player_status(_player_status), do: nil

  defp update_song_name(%{"Title" => title}), do: write_song_name(title)
  defp update_song_name(%{"file" => file_name}), do: write_song_name(file_name)
  defp update_song_name(_), do: nil

  defp write_song_name(name) do
    Pcd8544.cursorpos(0, 1)
    name
    |> String.slice(0, 14)
    |> String.pad_trailing(14)
    |> Pcd8544.write
  end

  defp update_play_status(%{state: state, volume: volume}) do
    write_play_status(state)
    write_volume(volume)
  end
  defp update_play_status(_), do: nil

  defp write_play_status(state) do
    Pcd8544.cursorpos(0, 4)
    case state do
      :play  -> Pcd8544.write("Playing...")
      :stop  -> Pcd8544.write("Stopped   ")
      :pause -> Pcd8544.write("Paused    ")
      _ -> nil
    end
  end

  defp write_volume(volume) do
    Pcd8544.cursorpos(0, 5)
    s_vol = div(volume, 12)
    pref = String.duplicate("-", s_vol)
    suff = String.duplicate("-", 11-s_vol)
    Pcd8544.write("[#{pref}##{suff}]")
  end
end
