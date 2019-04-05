defmodule MusicboxWeb.SongsLive do
  use Phoenix.LiveView
  alias Musicbox.Player
  require Logger

  def render(assigns) do
    ~L"""
      <h3 class="title is-title">Songs</h3>

      <%= if Enum.empty?(@songs) do %>
        <p>There are no songs yet</p>
      <% else %>
        <table class="table">
          <thead>
            <tr>
              <th>Song</th>
              <th>Duration</th>
              <th>On a Playlist?</th>
              <th>Playlists</th>
              <th>Quick Add</th>
            </tr>
          </thead>

          <%= for song <- @songs do %>
            <tr>
              <td><%= Musicbox.Song.description(song) %></td>
              <td><%= Musicbox.Song.duration(song) %></td>
              <td style="text-align: center;">
                <%= if Musicbox.Song.on_a_playlist?(song) do %>
                  <span class="icon has-text-success">
                    <i class="mdi mdi-24px mdi-check-circle" aria-hidden="true"></i>
                  </span>
                <% else %>
                  <span class="icon has-text-danger">
                    <i class="mdi mdi-24px mdi-close-circle" aria-hidden="true"></i>
                  </span>
                <% end %>
              </td>
              <td><%= song.playlists %></td>
              <td>
                <form phx-change="quick-add">
                  <input name="song" id="song" type="hidden" value="<%= song.path %>" />
                  <select name="playlist" id="playlist">
                    <option value="" selected>-- Select a Playlist --</option>
                    <%= for playlist <- @playlists do %>
                      <option value="<%= playlist.id %>"><%= playlist.id %></option>
                    <% end %>
                  </select>
                </form>
              </td>
            </tr>
          <% end %>
        </table>
      <% end %>

      <a href="/songs/new" class="button">Add Song</a>
    """
  end

  def mount(_session, socket) do
    if connected?(socket), do: :timer.send_interval(10_000, self(), :tick)

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

  def handle_event("quick-add", %{"playlist" => playlist, "song" => song}, socket) do
    Player.add_to_playlist(playlist, song)

    {:noreply, put_status(socket)}
  end

  defp put_status(socket) do
    assign(socket, songs: Player.list_songs, playlists: Player.list_playlists)
  end
end
