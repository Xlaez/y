defmodule YRepo.Repositories.UserRepositoryTest do
  use YRepo.DataCase
  alias YRepo.Repositories.UserRepository

  describe "create/1" do
    test "creates a user with valid params" do
      params = %{
        username: "testuser",
        password_hash: "hashed",
        seed_phrase_hash: "seed_hash"
      }

      assert {:ok, user} = UserRepository.create(params)
      assert user.username == "testuser"
    end
  end

  describe "get_by_id/1" do
    test "returns the user if it exists" do
      user = insert(:user)
      assert {:ok, found_user} = UserRepository.get_by_id(user.id)
      assert found_user.id == user.id
    end

    test "returns error if not found" do
      assert {:error, :not_found} = UserRepository.get_by_id(Ecto.UUID.generate())
    end
  end
end
