defmodule YWeb.Helpers.Time do
  @moduledoc """
  Time related helper functions.
  """

  @doc """
  Returns a relative time string (e.g., "2m ago", "1h ago").
  """
  def relative(datetime) when is_struct(datetime, DateTime) do
    diff = DateTime.diff(DateTime.utc_now(), datetime)
    format_diff(diff)
  end

  def relative(_), do: ""

  defp format_diff(diff) when diff < 60, do: "just now"
  defp format_diff(diff) when diff < 3600 do
    minutes = div(diff, 60)
    "#{minutes}m"
  end
  defp format_diff(diff) when diff < 86400 do
    hours = div(diff, 3600)
    "#{hours}h"
  end
  defp format_diff(diff) when diff < 604800 do
    days = div(diff, 86400)
    "#{days}d"
  end
  defp format_diff(diff) do
    # Fallback to date for older items
    # Since we don't have Timex, we'll just show weeks or days
    weeks = div(diff, 604800)
    "#{weeks}w"
  end
end
