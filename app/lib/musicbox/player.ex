defmodule Musicbox.Player do
  use GenServer
  require Logger
  alias Paracusia.MpdClient

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def play, do: GenServer.cast(__MODULE__, {:play})
  def pause, do: GenServer.cast(__MODULE__, {:pause})
  def toggle, do: GenServer.cast(__MODULE__, {:toggle})
  def status, do: GenServer.call(__MODULE__, {:status})
  def subscribe(pid), do: GenServer.cast(__MODULE__, {:subscribe, pid})
  def next, do: GenServer.cast(__MODULE__, {:next})
  def previous, do: GenServer.cast(__MODULE__, {:previous})
  def play_playlist(m3u), do: GenServer.cast(__MODULE__, {:play_playlist, m3u})
  def play_queue_index(ix), do: GenServer.cast(__MODULE__, {:play_queue_index, ix})
  def list_playlists, do: GenServer.call(__MODULE__, {:list_playlists})

  @impl true
  def init(_state) do
    Paracusia.PlayerState.subscribe(self())

    # Fetch the current status from MPD as the initial player status
    state = put_player_status(%{}, fetch_player_status())

    {:ok, state}
  end

  @impl true
  def handle_cast({:play}, state) do
    MpdClient.Playback.play

    {:noreply, state}
  end

  @impl true
  def handle_cast({:pause}, state) do
    MpdClient.Playback.pause(true)
    {:noreply, state}
  end

  def handle_cast({:previous}, state) do
    MpdClient.Playback.previous
    {:noreply, state}
  end

  def handle_cast({:next}, state) do
    MpdClient.Playback.next
    {:noreply, state}
  end

  def handle_cast({:toggle}, state) do
    {:ok, %{state: pstate}} = MpdClient.Status.status
    case pstate do
      :play -> pause()
      :pause  -> play()
      :stop -> play()
      _ -> play()
    end

    {:noreply, state}
  end

  def handle_cast({:subscribe, pid}, state) do
    Paracusia.PlayerState.subscribe(pid)

    {:noreply, state}
  end

  def handle_cast({:play_playlist, playlist}, state) do
    MpdClient.Queue.clear
    MpdClient.Playlists.load(playlist)
    play()

    {:noreply, state}
  end

  @impl true
  def handle_call({:status}, _from, %{player_status: status} = state) do
    {:reply, status, state}
  end

  def handle_call({:list_playlists}, _from, state) do
    {:reply, get_playlists(), state}
  end

  @doc """
  In the initialiser we use `Paracusia.PlayerState.subscribe/1` to
  register this server as an event receiver. This handles player state
  change events
  """
  @impl true
  def handle_info({:paracusia, {_event, _player_status}}, state) do
    {:noreply, put_player_status(state, fetch_player_status())}
  end

  def handle_info({:paracusia, event}, state) do
    Logger.info "Unhandled mpd event: #{event}"
    {:noreply, state}
  end

  defp put_player_status(state, player_status) do
    Map.put(state, :player_status, player_status)
  end

  defp fetch_player_status do
    {:ok, status} = MpdClient.Status.status
    {:ok, current_song} = MpdClient.Status.current_song
    {:ok, queue} = MpdClient.Queue.songs_info

    %{
      status: status,
      queue: queue,
      current_song: current_song,
      playlists: get_playlists()
    }
  end

  defp get_playlist_songs(id) do
    {:ok, songs} = MpdClient.Playlists.list_info(id)
    songs
  end

  defp get_playlists do
    {:ok, playlists} = MpdClient.Playlists.list_all

    playlists
    |> Enum.map(fn item ->
      id = item["playlist"]
      songs = get_playlist_songs(id)
      duration =
        songs
        |> Enum.map(fn song -> song["Time"] |> Integer.parse |> elem(0) end)
        |> Enum.sum
      
      %{
        id: id,
        song_count: Enum.count(songs),
        duration: duration,
        songs: get_playlist_songs(id)
      }
    end)
  end
end
