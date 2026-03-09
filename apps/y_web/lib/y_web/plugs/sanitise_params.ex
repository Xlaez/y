defmodule YWeb.Plugs.SanitiseParams do
  @moduledoc """
  Recursively trims whitespace and strips nul bytes from string parameters.
  """

  def init(opts), do: opts

  def call(conn, _opts) do
    %{conn | params: sanitise(conn.params)}
  end

  defp sanitise(params) when is_map(params) do
    Map.new(params, fn {k, v} -> {k, sanitise(v)} end)
  end

  defp sanitise(params) when is_list(params) do
    Enum.map(params, &sanitise/1)
  end

  defp sanitise(v) when is_binary(v) do
    v |> String.trim() |> String.replace("\0", "")
  end

  defp sanitise(v), do: v
end
