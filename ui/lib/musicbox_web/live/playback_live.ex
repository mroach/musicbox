defmodule MusicboxWeb.PlaybackLive do
  use Phoenix.LiveView
  alias Musicbox.Player
  require Logger

  def render(assigns) do
    ~L"""
    <div class="columns">
      <div class="column is-12-mobile is-4">
        <form phx-change="change_volume">
          <input name="volume" type="range" class="slider is-fullwidth" step="5" min="0" max="100" value="<%= @player.status.volume %>">
        </form>
        <p class="content is-small">
          Current volume <%= @player.status.volume %>%
        </p>
      </div>
      <div class="column is-narrow">
        <button phx-click="previous" class="button is-rounded">
          <span class="icon">
            <i class="mdi mdi-24px mdi-skip-previous" aria-hidden="true"></i>
          </span>
        </button>
        <button phx-click="toggle" class="button is-rounded">
          <span class="icon">
            <i class="mdi mdi-24px mdi-<%= play_pause_icon(@player.status.state) %>" aria-hidden="true"></i>
          </span>
        </button>
        <button phx-click="next" class="button is-rounded">
          <span class="icon">
            <i class="mdi mdi-24px mdi-skip-next" aria-hidden="true"></i>
          </span>
        </button>
      </div>
      <div class="column is-narrow">
        <div class="content is-small">
          <%= if @player.status.state == :stop do %>
            <em>Nothing playing</em>
          <% else %>
            <em>Currently playing:</em>
            <div><%= Musicbox.Song.description(@player.current_song) %></div>
          <% end %>
        </div>
      </div>
    </div>
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

  def handle_event("toggle", _value, socket) do
    Player.toggle()
    {:noreply, socket}
  end

  def handle_event("next", _value, socket) do
    Player.next()
    {:noreply, socket}
  end

  def handle_event("previous", _value, socket) do
    Player.previous()
    {:noreply, socket}
  end

  def handle_event("change_volume", %{"volume" => volume}, socket) do
    set_player_volume(volume)
    {:noreply, socket}
  end
  def handle_event("change_volume", _, socket) do
    {:noreply, socket}
  end

  defp put_status(socket) do
    assign(socket, player: Player.status())
  end

  defp play_pause_icon(:play), do: "pause"
  defp play_pause_icon(:pause), do: "play"
  defp play_pause_icon(:stop), do: "play"

  defp set_player_volume(volume) do
    case Integer.parse(volume) do
      {volume, _} ->
        Player.volume(volume)
      :error ->
        Logger.debug "Could set volume, tried #{volume}"
    end
  end
end
