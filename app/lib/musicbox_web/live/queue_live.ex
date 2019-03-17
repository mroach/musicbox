defmodule MusicboxWeb.QueueLive do
  use Phoenix.LiveView
  alias Musicbox.Player
  require Logger

  def render(assigns) do
    ~L"""
      <h3 class="title is-3">Queue</h3>

      <table class="table">
      <%= for song <- @player.queue do %>
        <tr>
          <td><%= song_description(song) %></td>
          <td><%= duration(song["Time"]) %></td>
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

  defp put_status(socket) do
    assign(socket, player: Player.status)
  end

  defp song_description(%{"Artist" => artist, "Title" => title}) do
    "#{artist} - #{title}"
  end
  defp song_description(%{"Title" => title}), do: title
  defp song_description(%{"file" => file}), do: file
  defp song_description(what), do: inspect(what)

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
