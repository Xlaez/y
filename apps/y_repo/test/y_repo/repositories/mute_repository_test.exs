defmodule YRepo.Repositories.MuteRepositoryTest do
  use YRepo.DataCase, async: true
  alias YRepo.Repositories.MuteRepository

  setup do
    user1 = insert(:user)
    user2 = insert(:user)
    {:ok, user1: user1, user2: user2}
  end

  test "mutes and unmutes users", %{user1: user1, user2: user2} do
    assert {:ok, _} = MuteRepository.mute(user1.id, user2.id)
    assert MuteRepository.muted?(user1.id, user2.id)
    
    assert :ok = MuteRepository.unmute(user1.id, user2.id)
    refute MuteRepository.muted?(user1.id, user2.id)
  end
end
