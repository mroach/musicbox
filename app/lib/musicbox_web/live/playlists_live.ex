defmodule MusicboxWeb.PlaylistsLive do
  use Phoenix.LiveView
  alias Musicbox.Player
  require Logger

  def render(assigns) do
    ~L"""
      <h3 class="title is-3">Playlists</h3>

      <table class="table">
        <thead>
          <tr>
            <th></th>
            <th>ID</th>
            <th>Songs</th>
            <th>Playtime</th>
          </tr>
        </thead>

        <%= for playlist <- @player.playlists do %>
          <tr>
            <td>
              <button phx-click="play_playlist" value="<%= playlist.id %>" class="button is-small is-outlined is-rounded">
                <span class="material-icons">playlist_play</span>
              </button>
            </td>
            <td><%= playlist.id %></td>
            <td><%= playlist.song_count %></td>
            <td><%= duration playlist.duration %></td>
          </tr>
        <% end %>
      </table>
    """
  end

  def mount(_session, socket) do
    if connected?(socket), do: :timer.send_interval(10000, self(), :tick)

    Player.subscribe(self())

    {:ok, put_status(socket)}
  end

  def handle_info(:tick, socket) do
    {:noreply, put_status(socket)}
  end

  def handle_info({:paracusia, _}, socket) do
    # When there's an event, just fetch the latest status
    {:noreply, put_status(socket)}
  end

  def handle_event("play_playlist", playlist, socket) do
    Logger.debug "Playing playlist #{playlist}"
    Player.play_playlist(playlist)
    {:noreply, socket}
  end

  defp put_status(socket) do
    assign(socket, player: Player.status)
  end

  defp duration(seconds) when is_binary(seconds) do
    {seconds, _} = Integer.parse(seconds)
    duration(seconds)
  end
  defp duration(seconds) do
    minutes = seconds / 60 |> floor
    seconds = seconds - minutes * 60
    "#{minutes}:#{format_seconds(seconds)}"
  end

  defp format_seconds(seconds) when seconds < 60 do
    :io_lib.format("~2..0B", [seconds]) |> to_string
  end
end
