defmodule YCore.Social.RecommendationService do
  @moduledoc """
  Service for generating user recommendations (Who to Follow).
  """

  @spec who_to_follow(String.t(), map()) :: [map()]
  def who_to_follow(user_id, repos) do
    case YRepo.Cache.Recommendations.get(user_id) do
      {:ok, cached} ->
        cached

      :miss ->
        results = compute_recommendations(user_id, repos)
        
        # Serialize only what's needed for the UI
        cacheable = Enum.map(results, fn %{user: u, mutual_count: m} ->
          %{
            user_id: u.id,
            username: u.username,
            bitmoji_color: u.bitmoji_color,
            mutual_count: m
          }
        end)
        
        YRepo.Cache.Recommendations.put(user_id, cacheable)
        cacheable
    end
  end

  defp compute_recommendations(user_id, repos) do
    # 1. Get IDs of users current user has blocked
    blocked = repos.block_repo.list_blocked_ids(user_id)
    # 2. Get IDs of users who have blocked current user
    blocked_by = repos.block_repo.list_blocked_by_ids(user_id)
    # 3. Union both lists
    blocked_ids = Enum.uniq(blocked ++ blocked_by)

    # 4. Call follow_repo.suggestions(user_id, blocked_ids, limit: 10)
    suggestions = repos.follow_repo.suggestions(user_id, blocked_ids, limit: 10)

    if suggestions == [] do
      []
    else
      user_ids = Enum.map(suggestions, & &1.user_id)
      users = repos.user_repo.list_by_ids(user_ids)
      users_map = Map.new(users, &{&1.id, &1})

      suggestions
      |> Enum.map(fn %{user_id: id, mutual_count: count} ->
        case Map.get(users_map, id) do
          nil -> nil
          user -> %{user: user, mutual_count: count}
        end
      end)
      |> Enum.reject(&is_nil/1)
    end
  end
end
