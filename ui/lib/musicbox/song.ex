defmodule Musicbox.Song do
  defstruct id: 0, artist: nil, album: nil, title: nil, duration: 0, path: nil, playlists: []

  def description(%__MODULE__{artist: artist, title: title})
    when is_binary(artist) and is_binary(title), do: "#{artist} - #{title}"
  def description(%__MODULE__{title: title}) when is_binary(title), do: title
  def description(%__MODULE__{path: path}), do: path
  def description(x), do: inspect(x)

  def on_a_playlist?(%__MODULE__{playlists: pl}) when length(pl) > 0, do: true
  def on_a_playlist?(_), do: false

  def from_mpd(data) do
    %__MODULE__{
      id: data["Id"] || 0,
      title: data["Title"],
      album: data["Album"],
      artist: data["Artist"],
      duration: parse_duration(data),
      path: data["file"],
    }
  end

  def duration(%__MODULE__{duration: seconds}) when is_number(seconds) and seconds > 0 do
    minutes = (seconds / 60)
    minutes = minutes |> floor
    seconds = seconds - minutes * 60
    "#{minutes}:#{format_seconds(seconds)}"
  end
  def duration(_), do: 0

  defp format_seconds(seconds) when seconds < 60 do
    :io_lib.format("~2..0B", [seconds]) |> to_string
  end

  defp parse_duration(%{"duration" => duration}) when is_binary(duration) do
    Integer.parse(duration) |> elem(0)
  end
  defp parse_duration(_), do: 0
end
