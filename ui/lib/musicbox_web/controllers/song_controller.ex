defmodule MusicboxWeb.SongController do
  alias Musicbox.Player
  use MusicboxWeb, :controller

  def index(conn, _params) do
    conn
    |> assign(:songs, Player.list_songs)
    |> render("index.html")
  end

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"song" => song_params}) do
    upload = song_params["file"]
    upload_path = Application.get_env(:musicbox, :music_upload_path)
    File.cp(upload.path, "#{upload_path}#{upload.filename}")
    Player.update_database

    conn
    |> put_flash(:info, "Added #{upload.filename}")
    |> redirect(to: "/songs")
  end
end
