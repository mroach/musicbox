defmodule Audio.Mpd do
  use GenServer
  require Logger

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_args) do
    maybe_create_mpd_directories()
    initial_state = %{port: start_mpd(), exit_status: nil}
    {:ok, initial_state}
  end

  def handle_info({_port, {:exit_status, status}}, state) do
    new_state = %{state | exit_status: status}
    {:noreply, new_state}
  end

  def handle_info(_msg, state), do: {:noreply, state}

  @command "mpd --no-daemon --stdout /etc/mpd.conf"
  defp start_mpd do
    Port.open({:spawn, @command}, [:binary, :exit_status])
  end

  @mpd_data_path "/root/mpd/data"
  @mpd_music_path "/root/mpd/music"
  @mpd_playlists_path "/root/mpd/playlists"
  defp maybe_create_mpd_directories do
    with :ok <- File.mkdir_p(@mpd_data_path),
         :ok <- File.mkdir_p(@mpd_music_path),
         :ok <- File.mkdir_p(@mpd_playlists_path) do
      maybe_create_mpd_files()
    else
      {:error, reason} ->
        Logger.error("Could not create or find mpd directories. Reason: #{reason}")

      err ->
        Logger.error("Could not create or find mpd directories.")
        err
    end
  end

  defp maybe_create_mpd_files do
    if File.exists?(@mpd_data_path <> "/tag_cache"),
      do: :noop,
      else: File.touch(@mpd_data_path <> "/tag_cache")

    if File.exists?(@mpd_data_path <> "/state"),
      do: :noop,
      else: File.touch(@mpd_data_path <> "/state")
  end
end
