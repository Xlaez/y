defmodule YRepo.Cache.Recommendations do
  @moduledoc """
  Redis-based caching for user recommendations.
  """
  
  @ttl 600 # 10 minutes in seconds

  @spec get(String.t()) :: {:ok, list()} | :miss
  def get(user_id) do
    case Redix.command(:redix, ["GET", key(user_id)]) do
      {:ok, nil} -> :miss
      {:ok, json} -> 
        try do
          {:ok, Jason.decode!(json, keys: :atoms)}
        rescue
          _ -> :miss
        end
      _ -> :miss
    end
  end

  @spec put(String.t(), list()) :: :ok
  def put(user_id, recommendations) do
    case Jason.encode(recommendations) do
      {:ok, json} ->
        Redix.command(:redix, ["SETEX", key(user_id), @ttl, json])
        :ok
      _ -> :ok
    end
  end

  @spec invalidate(String.t()) :: :ok
  def invalidate(user_id) do
    Redix.command(:redix, ["DEL", key(user_id)])
    :ok
  end

  defp key(user_id), do: "recommendations:#{user_id}"
end
