defmodule MusicboxWeb.SystemLive do
  use Phoenix.LiveView
  alias MusicboxWeb.Router.Helpers, as: Routes

  def render(assigns) do
    ~L"""
    <div class="columns">
      <div class="column">
        <h5 class="title is-5">Platform</h5>
        <div class="media-content">
          <div><%= @info.product() %></div>
          <div><%= @info.hardware.processor_model %></div>
          <div><%= @info.platform.arch %> <%= @info.platform.os_version %></div>
        </div>
      </div>

      <div class="column">
        <h5 class="title is-5">Elixir</h5>
        <div class="media-content">
          <%= @info.elixir.build %>
        </div>
      </div>
    </div>

    <h5 class="title is-5">VM Stats</h5>
    <pre><%= inspect @info.vm_stats, pretty: true %></pre>
    """
  end

  def mount(_session, socket) do
    if connected?(socket), do: :timer.send_interval(1_000, self(), :tick)

    {:ok, put_system_info(socket)}
  end

  def handle_info(:tick, socket) do
    {:noreply, put_system_info(socket)}
  end

  defp put_system_info(socket) do
    data = %{
      elixir: SystemInfo.elixir_info(),
      vm_stats: SystemInfo.vm_stats(),
      platform: SystemInfo.platform(),
      hardware: SystemInfo.hardware(),
      network: SystemInfo.network(),
      product: SystemInfo.product()
    }

    assign(socket, info: data)
  end
end
