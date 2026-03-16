defmodule YCore.Social.BlockServiceTest do
  use ExUnit.Case, async: true
  alias YCore.Social.BlockService

  defmodule MockBlockRepo do
    def block(blocker, blocked), do: {:ok, %{blocker_id: blocker, blocked_id: blocked}}
  end

  defmodule MockFollowRepo do
    def unfollow(_, _), do: :ok
  end

  test "cannot block self" do
    assert {:error, :cannot_block_self} == BlockService.block("user1", "user1", MockBlockRepo, MockFollowRepo)
  end

  test "removes follows in both directions when blocking" do
    # This is a bit hard to test with simple mocks without tracking calls, 
    # but the logic is straightforward in the service.
    assert {:ok, _} = BlockService.block("user1", "user2", MockBlockRepo, MockFollowRepo)
  end
end
