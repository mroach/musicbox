defmodule MusicboxWeb.Router do
  use MusicboxWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_layout, {MusicboxWeb.LayoutView, :app}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MusicboxWeb do
    pipe_through :browser

    get "/", PageController, :index

    resources "/songs", SongController

    live("/playback", PlaybackLive)
    live("/playlists", PlaylistsLive)
    live("/queue", QueueLive)
  end

  # Other scopes may use custom stacks.
  # scope "/api", MusicboxWeb do
  #   pipe_through :api
  # end

  scope "/system", MusicboxWeb do
    get "/alive", SystemController, :alive
    get "/stats", SystemController, :stats
  end
end
