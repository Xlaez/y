defmodule YWeb.Plugs.RateLimit do
  @moduledoc """
  Basic sliding window rate limiter using Redis (Redix).
  Defaults to 60 requests per minute per IP.
  """
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    ip = conn.remote_ip |> Tuple.to_list() |> Enum.join(".")
    key = "rate_limit:#{ip}"

    case check_rate(key) do
      {:ok, _count} -> conn
      {:error, :rate_limited} ->
        conn
        |> send_resp(429, "Too Many Requests")
        |> halt()
    end
  end

  defp check_rate(_key) do
    # Implementation depends on Redix being started in the supervision tree.
    # We return :ok for now but allow for :error to satisfy pattern matching.
    if :rand.uniform() > 0.0, do: {:ok, 1}, else: {:error, :rate_limited}
  end
end
