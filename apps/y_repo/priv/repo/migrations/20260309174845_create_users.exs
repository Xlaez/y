defmodule YRepo.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS \"pgcrypto\""

    create table(:users, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("gen_random_uuid()")
      add :username, :string, null: false
      add :password_hash, :text, null: false
      add :seed_phrase_hash, :text, null: false
      add :bitmoji_id, :uuid, null: false
      add :is_locked, :boolean, default: false, null: false

      timestamps(type: :utc_datetime_usec)
    end

    # Case-insensitive unique index
    execute "CREATE UNIQUE INDEX users_username_lower_idx ON users (LOWER(username))"
    
    # Performance index for recent users
    create index(:users, ["inserted_at DESC"], name: :users_inserted_at_idx)

    # Database-level constraints
    execute """
    ALTER TABLE users ADD CONSTRAINT username_length
      CHECK (char_length(username) >= 3 AND char_length(username) <= 30)
    """

    execute """
    ALTER TABLE users ADD CONSTRAINT username_format
      CHECK (username ~ '^[a-z0-9_]+$' AND username NOT LIKE '\\_%')
    """
  end
end
