defmodule YRepoTest do
  use ExUnit.Case
  doctest YRepo

  test "greets the world" do
    assert YRepo.hello() == :world
  end
end
