defmodule YCore.Social.FollowServiceTest do
  use ExUnit.Case, async: true
  alias YCore.Social.FollowService

  defmodule MockRepo do
    def follow(follower, followee), do: {:ok, %{follower_id: follower, followee_id: followee}}
    def unfollow(_, _), do: :ok
  end

  defmodule MockNotificationRepo do
    def create(_), do: {:ok, %{id: "n1", recipient_id: "u1", inserted_at: DateTime.utc_now()}}
  end

  test "cannot follow self" do
    assert {:error, :cannot_follow_self} == FollowService.follow("user1", "user1", MockRepo, MockNotificationRepo)
  end

  test "delegates follow to repo" do
    assert {:ok, _} = FollowService.follow("user1", "user2", MockRepo, MockNotificationRepo)
  end

  test "delegates unfollow to repo" do
    assert :ok == FollowService.unfollow("user1", "user2", MockRepo)
  end
end
