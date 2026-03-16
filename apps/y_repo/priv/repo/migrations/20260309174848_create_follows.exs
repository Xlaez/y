defmodule YRepo.Repo.Migrations.CreateFollows do
  use Ecto.Migration

  def up do
    create table(:follows, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("gen_random_uuid()")
      add :follower_id, references(:users, type: :uuid, on_delete: :delete_all), null: false
      add :followee_id, references(:users, type: :uuid, on_delete: :delete_all), null: false
      add :inserted_at, :utc_datetime_usec, null: false, default: fragment("now()")
    end

    create unique_index(:follows, [:follower_id, :followee_id])
    create index(:follows, [:followee_id])
    create index(:follows, [:follower_id])

    execute "ALTER TABLE follows ADD CONSTRAINT no_self_follow CHECK (follower_id != followee_id);"
  end

  def down do
    drop table(:follows)
  end
end
