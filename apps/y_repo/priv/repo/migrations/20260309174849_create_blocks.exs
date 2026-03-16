defmodule YRepo.Repo.Migrations.CreateBlocks do
  use Ecto.Migration

  def up do
    create table(:blocks, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("gen_random_uuid()")
      add :blocker_id, references(:users, type: :uuid, on_delete: :delete_all), null: false
      add :blocked_id, references(:users, type: :uuid, on_delete: :delete_all), null: false
      add :inserted_at, :utc_datetime_usec, null: false, default: fragment("now()")
    end

    create unique_index(:blocks, [:blocker_id, :blocked_id])
    create index(:blocks, [:blocked_id])
    create index(:blocks, [:blocker_id])

    execute "ALTER TABLE blocks ADD CONSTRAINT no_self_block CHECK (blocker_id != blocked_id);"
  end

  def down do
    drop table(:blocks)
  end
end
