defmodule YRepo.Repositories.FollowRepositoryTest do
  use YRepo.DataCase, async: true
  alias YRepo.Repositories.FollowRepository

  setup do
    user1 = insert(:user)
    user2 = insert(:user)
    {:ok, user1: user1, user2: user2}
  end

  describe "follow/2" do
    test "creates a follow relationship", %{user1: user1, user2: user2} do
      assert {:ok, _} = FollowRepository.follow(user1.id, user2.id)
      assert FollowRepository.following?(user1.id, user2.id)
    end

    test "cannot follow self", %{user1: user1} do
      # This is enforced by SQL CHECK constraint
      assert {:error, %Ecto.Changeset{}} = FollowRepository.follow(user1.id, user1.id)
    end

    test "handles duplicate follows", %{user1: user1, user2: user2} do
      FollowRepository.follow(user1.id, user2.id)
      assert {:error, :already_following} = FollowRepository.follow(user1.id, user2.id)
    end
  end

  describe "counts" do
    test "returns correct counts", %{user1: user1, user2: user2} do
      FollowRepository.follow(user1.id, user2.id)
      assert FollowRepository.follower_count(user2.id) == 1
      assert FollowRepository.following_count(user1.id) == 1
    end
  end

  describe "unfollow/2" do
    test "removes a follow relationship", %{user1: user1, user2: user2} do
      FollowRepository.follow(user1.id, user2.id)
      assert :ok = FollowRepository.unfollow(user1.id, user2.id)
      refute FollowRepository.following?(user1.id, user2.id)
    end
  end
end
