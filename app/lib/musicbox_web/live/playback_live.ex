defmodule MusicboxWeb.PlaybackLive do
  use Phoenix.LiveView
  alias Musicbox.Player
  require Logger

  def render(assigns) do
    ~L"""
      <div>
        <button phx-click="previous" class="button is-rounded is-small">
          <span class="material-icons">skip_previous</span></button>
        </button>
        <button phx-click="toggle" class="button is-rounded is-small">
          <span class="material-icons"><%= play_pause_icon(@player.status.state) %></span></button>
        </button>
        <button phx-click="next" class="button is-rounded is-small">
          <span class="material-icons">skip_next</span></button>
        </button>
      </div>

      <div class="content is-small">
        <%= if @player.status.state == :stop do %>
          <em>Nothing playing</em>
        <% else %>
          <%= song_description @player.current_song %>
        <% end %>
      </div>
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

  def handle_event("toggle", _value, socket) do
    Player.toggle
    {:noreply, socket}
  end

  def handle_event("next", _value, socket) do
    Player.next
    {:noreply, socket}
  end

  def handle_event("previous", _value, socket) do
    Player.previous
    {:noreply, socket}
  end

  defp put_status(socket) do
    assign(socket, player: Player.status)
  end

  defp play_pause_icon(:play), do: "pause"
  defp play_pause_icon(:pause), do: "play_arrow"
  defp play_pause_icon(:stop), do: "play_arrow"

  defp song_description(%{"Artist" => artist, "Title" => title}) do
    "#{artist} - #{title}"
  end
  defp song_description(%{"Title" => title}), do: title
  defp song_description(%{"file" => file}), do: file
  defp song_description(nil), do: ""

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
