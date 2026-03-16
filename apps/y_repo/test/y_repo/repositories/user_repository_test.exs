defmodule YRepo.Repositories.UserRepositoryTest do
  use YRepo.DataCase, async: true
  alias YRepo.Repositories.UserRepository

  describe "create/1" do
    test "inserts a user and returns domain struct" do
      attrs = %{
        username: "voidwalker",
        password_hash: "hashed_pw",
        seed_phrase_hash: "hashed_seed",
        bitmoji_id: Ecto.UUID.generate()
      }

      assert {:ok, user} = UserRepository.create(attrs)
      assert user.username == "voidwalker"
      assert is_binary(user.id)
    end

    test "Duplicate username returns error due to unique index" do
      insert(:user, username: "taken")
      attrs = %{
        username: "taken",
        password_hash: "hashed_pw",
        seed_phrase_hash: "hashed_seed",
        bitmoji_id: Ecto.UUID.generate()
      }

      assert {:error, changeset} = UserRepository.create(attrs)
    end
  end

  describe "get_by_username/1" do
    test "is case-insensitive" do
      insert(:user, username: "voidwalker")
      assert {:ok, user} = UserRepository.get_by_username("voidwalker")
      assert user.username == "voidwalker"
    end
  end

  describe "update/2" do
    test "updates password_hash correctly" do
      schema_user = insert(:user)
      {:ok, user} = UserRepository.get_by_id(schema_user.id)
      assert {:ok, updated_user} = UserRepository.update(user, %{password_hash: "new_hash"})
      assert updated_user.password_hash == "new_hash"
    end
  end

  describe "delete/1" do
    test "removes user" do
      schema_user = insert(:user)
      assert :ok = UserRepository.delete(schema_user.id)
      assert {:error, :not_found} = UserRepository.get_by_id(schema_user.id)
    end
  end
end
