defmodule YRepo.Repo.Migrations.CreateMutes do
  use Ecto.Migration

  def up do
    create table(:mutes, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("gen_random_uuid()")
      add :muter_id, references(:users, type: :uuid, on_delete: :delete_all), null: false
      add :muted_id, references(:users, type: :uuid, on_delete: :delete_all), null: false
      add :inserted_at, :utc_datetime_usec, null: false, default: fragment("now()")
    end

    create unique_index(:mutes, [:muter_id, :muted_id])
    create index(:mutes, [:muted_id])
    create index(:mutes, [:muter_id])

    execute "ALTER TABLE mutes ADD CONSTRAINT no_self_mute CHECK (muter_id != muted_id);"
  end

  def down do
    drop table(:mutes)
  end
end
