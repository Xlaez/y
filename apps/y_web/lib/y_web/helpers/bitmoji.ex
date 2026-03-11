defmodule YWeb.Helpers.Bitmoji do
  @doc """
  Returns a deterministic background color for a given username.
  """
  def color_for_username(username) do
    palette = [
      "#E040FB", # purple
      "#00E5FF", # cyan
      "#FF5252", # error/red
      "#FFB300", # warning/orange
      "#00E676", # green
      "#FF6D00", # deep orange
      "#40C4FF", # light blue
      "#F50057"  # pink
    ]
    # Use phash2 for deterministic indexing
    index = :erlang.phash2(username, length(palette))
    Enum.at(palette, index)
  end

  @doc """
  Returns the first two characters of a username as initials.
  """
  def initials(username) do
    username
    |> String.replace("@", "")
    |> String.slice(0, 2)
    |> String.upcase()
  end
end
