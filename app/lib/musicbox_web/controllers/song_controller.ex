defmodule MusicboxWeb.SongController do
  use MusicboxWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"song" => song_params}) do
    upload = song_params["file"]
    File.cp(upload.path, "/media/music/#{upload.filename}")

    conn
    |> put_flash(:info, "Added #{upload.filename}")
    |> redirect(to: Routes.song_path(conn, :index))
  end
end
