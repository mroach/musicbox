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
    :ok = song_params["file"] |> handle_upload

    conn
    |> put_flash(:info, "Upload complete")
    |> redirect(to: "/songs")
  end
  def create(conn, _) do
    conn
    |> put_flash(:error, "Please choose at lease one mp3 file to upload")
    |> render("new.html")
  end

  defp handle_upload(files) when is_list(files) do
    for file <- files, do: copy_to_music_directory(file)
    Player.update_database

    :ok
  end
  defp handle_upload(file), do: handle_upload([file])

  defp copy_to_music_directory(file) do
    upload_path = Application.get_env(:musicbox, :music_upload_path)
    File.cp!(file.path, upload_path <> file.filename)
  end
end
