defmodule YRepo.Session do
  @moduledoc """
  Redis-backed session store with a 30-day sliding TTL.
  """

  @redis_key_prefix "session:"
  @session_ttl_seconds 30 * 24 * 60 * 60

  def create_session(user_id) do
    token = generate_token()
    key = session_key(token)
    
    case Redix.command(:redix, ["SET", key, user_id, "EX", @session_ttl_seconds]) do
      {:ok, "OK"} -> {:ok, token}
      {:error, reason} -> {:error, reason}
    end
  end

  def get_user_id(token) do
    key = session_key(token)
    
    case Redix.command(:redix, ["GET", key]) do
      {:ok, nil} -> {:error, :not_found}
      {:ok, user_id} ->
        # Sliding TTL: refresh expiry on every access
        Redix.command(:redix, ["EXPIRE", key, @session_ttl_seconds])
        {:ok, user_id}
      {:error, reason} -> {:error, reason}
    end
  end

  def delete_session(token) do
    key = session_key(token)
    Redix.command(:redix, ["DEL", key])
  end

  defp generate_token do
    :crypto.strong_rand_bytes(32) |> Base.url_encode64()
  end

  defp session_key(token), do: @redis_key_prefix <> token
end
