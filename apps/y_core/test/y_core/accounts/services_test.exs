defmodule YCore.Accounts.ServicesTest do
  use ExUnit.Case, async: true
  import Mox

  alias YCore.Accounts.RegistrationService
  alias YCore.Accounts.AuthenticationService
  alias YCore.Accounts.PasswordResetService
  alias YCore.Accounts.User

  setup :set_mox_from_context
  setup :verify_on_exit!

  defmock(UserRepositoryMock, for: YCore.Accounts.UserRepository)

  describe "RegistrationService.register/2" do
    test "Successful registration returns {:ok, %{user: _, seed_phrase: words}}" do
      params = %{username: "newuser", password: "securepassword123"}
      
      UserRepositoryMock
      |> expect(:get_by_username, fn "newuser" -> {:error, :not_found} end)
      |> expect(:create, fn attrs ->
        assert attrs.username == "newuser"
        assert is_binary(attrs.password_hash)
        assert is_binary(attrs.seed_phrase_hash)
        assert is_binary(attrs.bitmoji_id)
        {:ok, struct(User, Map.put(attrs, :id, "uuid-1"))}
      end)

      assert {:ok, %{user: user, seed_phrase: words}} = RegistrationService.register(params, UserRepositoryMock)
      assert user.username == "newuser"
      assert length(words) == 12
    end

    test "Duplicate username returns {:error, :username_taken}" do
      params = %{username: "taken", password: "securepassword123"}
      
      UserRepositoryMock
      |> expect(:get_by_username, fn "taken" -> {:ok, %User{id: "1", username: "taken", password_hash: "...", seed_phrase_hash: "...", bitmoji_id: "...", is_locked: false}} end)

      assert {:error, :username_taken} = RegistrationService.register(params, UserRepositoryMock)
    end

    test "Invalid password returns {:error, _}" do
      params = %{username: "newuser", password: "short"}
      assert {:error, "Password must be at least 10 characters long"} = RegistrationService.register(params, UserRepositoryMock)
    end
  end

  describe "AuthenticationService.authenticate/3" do
    test "Valid credentials return {:ok, user}" do
      password = "securepassword123"
      hash = Bcrypt.hash_pwd_salt(password)
      user = %User{id: "1", username: "user1", password_hash: hash, seed_phrase_hash: "...", bitmoji_id: "...", is_locked: false}

      UserRepositoryMock
      |> expect(:get_by_username, fn "user1" -> {:ok, user} end)

      assert {:ok, ^user} = AuthenticationService.authenticate("user1", password, UserRepositoryMock)
    end

    test "Wrong password returns {:error, :invalid_credentials}" do
      hash = Bcrypt.hash_pwd_salt("realpassword")
      user = %User{id: "1", username: "user1", password_hash: hash, seed_phrase_hash: "...", bitmoji_id: "...", is_locked: false}

      UserRepositoryMock
      |> expect(:get_by_username, fn "user1" -> {:ok, user} end)

      assert {:error, :invalid_credentials} = AuthenticationService.authenticate("user1", "wrongpassword", UserRepositoryMock)
    end

    test "Unknown username returns {:error, :invalid_credentials} (timing-safe)" do
      UserRepositoryMock
      |> expect(:get_by_username, fn "ghost" -> {:error, :not_found} end)

      assert {:error, :invalid_credentials} = AuthenticationService.authenticate("ghost", "anypassword", UserRepositoryMock)
    end
  end

  describe "PasswordResetService.reset/4" do
    test "Successful reset with valid seed phrase" do
      seed_phrase = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon"
      seed_hash = Argon2.hash_pwd_salt(seed_phrase)
      user = %User{id: "1", username: "user1", password_hash: "oldhash", seed_phrase_hash: seed_hash, bitmoji_id: "...", is_locked: false}

      UserRepositoryMock
      |> expect(:get_by_username, fn "user1" -> {:ok, user} end)
      |> expect(:update, fn ^user, attrs ->
        assert is_binary(attrs.password_hash)
        {:ok, %{user | password_hash: attrs.password_hash}}
      end)

      assert {:ok, updated_user} = PasswordResetService.reset("user1", seed_phrase, "newsecurepassword123", UserRepositoryMock)
      assert updated_user.password_hash != "oldhash"
    end

    test "Error with invalid seed phrase" do
      user = %User{id: "1", username: "user1", password_hash: "...", seed_phrase_hash: Argon2.hash_pwd_salt("real phrase"), bitmoji_id: "...", is_locked: false}

      UserRepositoryMock
      |> expect(:get_by_username, fn "user1" -> {:ok, user} end)

      assert {:error, :invalid_credentials} = PasswordResetService.reset("user1", "wrong phrase", "newpassword123", UserRepositoryMock)
    end
  end
end
