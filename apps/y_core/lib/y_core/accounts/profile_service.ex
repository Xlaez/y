defmodule YCore.Accounts.ProfileService do
  @spec get_profile(String.t(), String.t() | nil, module(), module(), module()) ::
          {:ok, map()} | {:error, :not_found}
  def get_profile(username, viewer_id, user_repo, follow_repo, block_repo) do
    case user_repo.get_by_username(username) do
      {:error, :not_found} ->
        {:error, :not_found}

      {:ok, user} ->
        follower_count = follow_repo.follower_count(user.id)
        following_count = follow_repo.following_count(user.id)

        {is_following, is_blocked_by_viewer, viewer_is_blocked} =
          if viewer_id && viewer_id != user.id do
            {
              follow_repo.following?(viewer_id, user.id),
              block_repo.blocked?(viewer_id, user.id),
              block_repo.blocked?(user.id, viewer_id)
            }
          else
            {false, false, false}
          end

        can_view_content = cond do
          !user.is_locked -> true
          viewer_id == user.id -> true
          viewer_id && follow_repo.following?(viewer_id, user.id) -> true
          true -> false
        end

        {:ok, %{
          user: user,
          follower_count: follower_count,
          following_count: following_count,
          take_count: 0,
          is_following: is_following,
          is_blocked_by_viewer: is_blocked_by_viewer,
          viewer_is_blocked: viewer_is_blocked,
          can_view_content: can_view_content && !viewer_is_blocked
        }}
    end
  end
end
