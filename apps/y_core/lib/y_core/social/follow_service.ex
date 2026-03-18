defmodule YCore.Social.FollowService do
  alias YCore.Social.Follow

  @spec follow(String.t(), String.t(), module(), module()) ::
          {:ok, Follow.t()} | {:error, :cannot_follow_self} | {:error, :already_following} | {:error, term()}
  def follow(follower_id, followee_id, _repo, _notification_repo) when follower_id == followee_id,
    do: {:error, :cannot_follow_self}

  def follow(follower_id, followee_id, repo, notification_repo) do
    case repo.follow(follower_id, followee_id) do
      {:ok, follow} ->
        Task.start(fn ->
          YCore.Notifications.NotificationService.notify_followed(follower_id, followee_id, notification_repo)
        end)
        {:ok, follow}
      error -> error
    end
  end

  @spec unfollow(String.t(), String.t(), module()) :: :ok | {:error, :not_following}
  def unfollow(follower_id, followee_id, repo) do
    repo.unfollow(follower_id, followee_id)
  end
end
