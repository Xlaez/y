defmodule YRepo.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :username, :string, null: false
      add :password_hash, :string, null: false
      add :seed_phrase_hash, :string, null: false
      add :bitmoji_id, :string
      add :is_locked, :boolean, default: false, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:users, [:username])
    create index(:users, [:bitmoji_id])
  end
end
