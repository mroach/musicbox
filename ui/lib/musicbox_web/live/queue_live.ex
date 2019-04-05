defmodule MusicboxWeb.QueueLive do
  use Phoenix.LiveView
  alias Musicbox.Player
  require Logger

  def render(assigns) do
    ~L"""
      <h3 class="title is-3">Queue</h3>

      <table class="table">
      <%= for song <- @player.queue do %>
        <tr class="<%= if playing?(song, @player.current_song), do: "is-selected" %>">
          <td><%= Musicbox.Song.description(song) %></td>
          <td><%= Musicbox.Song.duration(song) %></td>
        </tr>
      <% end %>
      </table>
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

  defp put_status(socket) do
    assign(socket, player: Player.status())
  end

  defp playing?(%{id: id1}, %{id: id2}) when id2 > 0 and id1 == id2, do: true
  defp playing?(_, _), do: false
end
