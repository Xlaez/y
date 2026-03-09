defmodule YRepoTest do
  use YRepo.DataCase

  test "repo is started" do
    assert Process.whereis(YRepo.Repo)
  end
end
