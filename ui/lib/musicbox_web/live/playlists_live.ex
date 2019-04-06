defmodule MusicboxWeb.PlaylistsLive do
  use Phoenix.LiveView
  alias Musicbox.Player
  require Logger

  def render(assigns) do
    ~L"""
      <h3 class="title is-3">Playlists</h3>

      <%= if Enum.empty?(@player.playlists) do %>
        <p>There are no playlists created yet.</p>
      <% else %>
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
                <button phx-click="play_playlist" value="<%= playlist.id %>" class="button is-outlined is-rounded">
                  <span class="icon">
                    <i class="mdi mdi-18px mdi-playlist-play" aria-hidden="true"></i>
                  </span>
                </button>
              </td>
              <td>
                <%= if @edit_playlist == playlist.id do %>
                  <form phx-submit="set_playlist_name">
                    <input name="id" type="hidden" value="<%= playlist.id %>">
                    <div class="field has-addons">
                      <div class="control">
                        <input name="name" autocomplete="off" class="input" placeholder="<%= playlist.name %>" />
                      </div>
                      <div class="control">
                        <button class="button" type="submit">Update name</button>
                      </div>
                    </div>
                  </form>
                <% else %>
                  <button phx-click="edit_playlist_name" value="<%= playlist.id %>" class="button">
                    <%= playlist.name %>
                  </button>
                <% end %>
              </td>
              <td><%= playlist.song_count %></td>
              <td><%= duration playlist.duration %></td>
            </tr>
          <% end %>
        </table>
      <% end %>
    """
  end

  def mount(_session, socket) do
    if connected?(socket), do: :timer.send_interval(10_000, self(), :tick)
    Player.subscribe(self())

    socket = socket
    |> put_status()
    |> set_edit_playlist()

    {:ok, socket}
  end

  def handle_info(:tick, socket) do
    {:noreply, put_status(socket)}
  end

  def handle_info({:paracusia, _}, socket) do
    # When there's an event, just fetch the latest status
    {:noreply, put_status(socket)}
  end

  def handle_event("play_playlist", playlist, socket) do
    Logger.debug("Playing playlist #{playlist}")
    Player.play_playlist(playlist)
    {:noreply, socket}
  end

  def handle_event("edit_playlist_name", playlist, socket) when is_binary(playlist) do
    {:noreply, set_edit_playlist(socket, playlist)}
  end
  def handle_event("edit_playlist_name", _, socket) do
    {:noreply, socket}
  end

  def handle_event("set_playlist_name", playlist, socket) do
    Player.rename_playlist(playlist)
    {:noreply, socket}
  end

  defp put_status(socket) do
    assign(socket, player: Player.status())
  end

  defp set_edit_playlist(socket) do
    assign(socket, edit_playlist: nil)
  end

  defp set_edit_playlist(socket, playlist) when is_binary(playlist) do
    assign(socket, edit_playlist: playlist)
  end
  defp set_edit_playlist(socket, _playlist) do
    assign(socket, edit_playlist: nil)
  end

  defp duration(seconds) when is_binary(seconds) do
    {seconds, _} = Integer.parse(seconds)
    duration(seconds)
  end

  defp duration(seconds) do
    minutes = (seconds / 60)
    minutes = minutes |> floor
    seconds = seconds - minutes * 60
    "#{minutes}:#{format_seconds(seconds)}"
  end

  defp format_seconds(seconds) when seconds < 60 do
    :io_lib.format("~2..0B", [seconds]) |> to_string
  end
end
