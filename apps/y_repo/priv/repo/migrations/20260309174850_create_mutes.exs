defmodule YRepo.Repo.Migrations.CreateMutes do
  use Ecto.Migration

  def up do
    execute """
    CREATE TABLE mutes (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      muter_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      muted_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      inserted_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );
    """

    create unique_index(:mutes, [:muter_id, :muted_id])
    create index(:mutes, [:muter_id])

    execute "ALTER TABLE mutes ADD CONSTRAINT no_self_mute CHECK (muter_id != muted_id);"
  end

  def down do
    drop table(:mutes)
  end
end
