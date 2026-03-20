defmodule YRepo.Repo.Migrations.AddOpinionAndRetakeCountsToTakes do
  use Ecto.Migration

  def up do
    execute "ALTER TABLE takes ADD COLUMN IF NOT EXISTS opinion_count INTEGER DEFAULT 0 NOT NULL"
    execute "ALTER TABLE takes ADD COLUMN IF NOT EXISTS retake_count INTEGER DEFAULT 0 NOT NULL"
  end

  def down do
    alter table(:takes) do
      remove :opinion_count
      remove :retake_count
    end
  end
end
