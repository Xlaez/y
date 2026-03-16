defmodule YRepo.Repo.Migrations.CreateBlocks do
  use Ecto.Migration

  def up do
    execute """
    CREATE TABLE blocks (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      blocker_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      blocked_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      inserted_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );
    """

    create unique_index(:blocks, [:blocker_id, :blocked_id])
    create index(:blocks, [:blocker_id])

    execute "ALTER TABLE blocks ADD CONSTRAINT no_self_block CHECK (blocker_id != blocked_id);"
  end

  def down do
    drop table(:blocks)
  end
end
