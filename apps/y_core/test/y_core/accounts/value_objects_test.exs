defmodule YCore.Accounts.ValueObjectsTest do
  use ExUnit.Case, async: true
  alias YCore.Accounts.ValueObjects.Username
  alias YCore.Accounts.ValueObjects.Password

  describe "Username" do
    test "Success: valid usernames" do
      assert {:ok, %Username{value: "voidwalker"}} = Username.new("voidwalker")
      assert {:ok, %Username{value: "user_99"}} = Username.new("user_99")
      assert {:ok, %Username{value: "abc"}} = Username.new("abc")
    end

    test "Success: lowercases the value" do
      assert {:ok, %Username{value: "voidwalker"}} = Username.new("VoidWalker")
    end

    test "Error: too short" do
      assert {:error, "Username must be between 3 and 30 characters"} = Username.new("ab")
    end

    test "Error: too long" do
      long_name = String.duplicate("a", 31)
      assert {:error, "Username must be between 3 and 30 characters"} = Username.new(long_name)
    end

    test "Error: starts with underscore" do
      assert {:error, "Username cannot start with an underscore"} = Username.new("_user")
    end

    test "Error: invalid characters" do
      assert {:error, "Username can only contain alphanumeric characters and underscores"} = Username.new("user@123")
      assert {:error, "Username can only contain alphanumeric characters and underscores"} = Username.new("user 123")
    end
  end

  describe "Password" do
    test "Success: valid password" do
      assert :ok = Password.validate("thisisalongpassword")
    end

    test "Error: too short" do
      assert {:error, "Password must be at least 10 characters long"} = Password.validate("short")
    end
  end
end
