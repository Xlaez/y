defmodule YRepo.Helpers.Color do
  @doc """
  Generates a stable HEX color from a binary ID (UUID).
  """
  def from_id(id) when is_binary(id) do
    # Simple hash-based color generation
    <<r, g, b, _::binary>> = :crypto.hash(:md5, id)
    # We want darkish colors for the 'y' aesthetic
    r = rem(r, 64) + 20
    g = rem(g, 64) + 20
    b = rem(b, 64) + 20
    
    "##{Integer.to_string(r, 16) |> String.pad_leading(2, "0")}#{Integer.to_string(g, 16) |> String.pad_leading(2, "0")}#{Integer.to_string(b, 16) |> String.pad_leading(2, "0")}"
  end
  def from_id(_), do: "#3A3A3C"
end
