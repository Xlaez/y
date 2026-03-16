defmodule YRepo.Repositories.BlockRepositoryTest do
  use YRepo.DataCase, async: true
  alias YRepo.Repositories.BlockRepository

  setup do
    user1 = insert(:user)
    user2 = insert(:user)
    {:ok, user1: user1, user2: user2}
  end

  test "blocks and unblocks users", %{user1: user1, user2: user2} do
    assert {:ok, _} = BlockRepository.block(user1.id, user2.id)
    assert BlockRepository.blocked?(user1.id, user2.id)
    assert [%{id: id}] = BlockRepository.list_blocked(user1.id)
    assert id == user2.id

    assert :ok = BlockRepository.unblock(user1.id, user2.id)
    refute BlockRepository.blocked?(user1.id, user2.id)
  end

  test "cannot block self", %{user1: user1} do
    assert {:error, %Ecto.Changeset{}} = BlockRepository.block(user1.id, user1.id)
  end
end
