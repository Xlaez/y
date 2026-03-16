defmodule YRepo.TestInsert do
  alias YRepo.Repo
  alias YRepo.Schemas.User

  def run do
    attrs = %{
      id: "manual-id-123",
      username: "manualuser",
      password_hash: "manualpw",
      seed_phrase_hash: "manualseed",
      bitmoji_id: "manualbit"
    }
    
    %User{}
    |> Ecto.Changeset.cast(attrs, [:id, :username, :password_hash, :seed_phrase_hash, :bitmoji_id])
    |> Repo.insert()
    |> IO.inspect()
  end
end
