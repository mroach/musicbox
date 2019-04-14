defmodule RFID.Handler do
  require Logger

  def tag_scanned(tag_id) when is_number(tag_id), do: tag_id |> to_string |> tag_scanned
  def tag_scanned(tag_id) when is_binary(tag_id) do
    Logger.info "Scanned RFID tag #{tag_id}"
    play_or_create(tag_id)
  end

  def play_or_create(tag_id) do
    case find_playlist_by_tag_id(tag_id) do
      nil -> Musicbox.Player.create_playlist(tag_id)
      name -> Musicbox.Player.play_playlist(name)
    end
  end

  def find_playlist_by_tag_id(tag_id) do
    Musicbox.Player.list_playlists
    |> Enum.find(fn playlist -> extract_tag_id(playlist.id) == tag_id end)
    |> case do
      %{id: id} -> id
      _ -> nil
    end
  end

  defp extract_tag_id(playlist) do
    case Musicbox.Player.playlist_information(playlist) do
      %{"id" => id} -> id
      _ -> nil
    end
  end
end
