defmodule YWorkersTest do
  use ExUnit.Case
  doctest YWorkers

  test "greets the world" do
    assert YWorkers.hello() == :world
  end
end
