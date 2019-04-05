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

  defp handle_upload(files) when is_list(files) do
    upload_path = Application.get_env(:musicbox, :music_upload_path)

    files
    |> Enum.each(fn file ->
      File.cp(file.path, "#{upload_path}#{file.filename}")
    end)

    Player.update_database

    :ok
  end
  defp handle_upload(file), do: handle_upload([file])
end
