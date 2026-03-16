defmodule YRepo.Repo.Migrations.CreateFollows do
  use Ecto.Migration

  def up do
    execute """
    CREATE TABLE follows (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      follower_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      followee_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      inserted_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );
    """

    create unique_index(:follows, [:follower_id, :followee_id])
    create index(:follows, [:followee_id])
    create index(:follows, [:follower_id])

    execute "ALTER TABLE follows ADD CONSTRAINT no_self_follow CHECK (follower_id != followee_id);"
  end

  def down do
    drop table(:follows)
  end
end
