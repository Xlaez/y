defmodule YRepo.SimpleTest do
  use YRepo.DataCase, async: true
  alias YRepo.Repo
  alias YRepo.Schemas.User

  test "simple insert" do
    user = %User{
      id: "simple-test-123",
      username: "simpleuser",
      password_hash: "pw",
      seed_phrase_hash: "seed",
      bitmoji_id: "bit",
      is_locked: false
    }
    assert {:ok, _} = Repo.insert(user)
  end
end
