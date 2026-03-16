defmodule YRepo.Factory do
  use ExMachina.Ecto, repo: YRepo.Repo

  def user_factory do
    %YRepo.Schemas.User{
      id: Ecto.UUID.generate(),
      username: sequence(:username, &"user_#{&1}"),
      password_hash: "hashed_password",
      seed_phrase_hash: "hashed_seed",
      bitmoji_id: Ecto.UUID.generate()
    }
  end

  def take_factory do
    %YRepo.Schemas.Take{
      body: "Sample take content",
      user: build(:user)
    }
  end
end
