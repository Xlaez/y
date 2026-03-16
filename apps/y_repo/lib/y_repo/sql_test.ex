defmodule YRepo.SqlTest do
  alias YRepo.Repo

  def run do
    # Repo.query test
    sql = "INSERT INTO users (id, username, password_hash, seed_phrase_hash, bitmoji_id, is_locked, inserted_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6, NOW(), NOW())"
    params = ["999", "test999", "pw", "seed", "bit", false]
    Repo.query!(sql, params)
    IO.puts("Repo.query! worked")

    # Repo.insert test
    user = %YRepo.Schemas.User{
      id: "insert-test-999",
      username: "insertuser999",
      password_hash: "pw",
      seed_phrase_hash: "seed",
      bitmoji_id: Ecto.UUID.generate(),
      is_locked: false
    }
    Repo.insert!(user)
    IO.puts("Repo.insert! worked")
  end
end
