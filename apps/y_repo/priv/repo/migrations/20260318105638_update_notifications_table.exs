defmodule YRepo.Repo.Migrations.UpdateNotificationsTable do
  use Ecto.Migration

  def change do
    execute "ALTER TABLE notifications ALTER COLUMN target_id DROP NOT NULL"
    execute "ALTER TABLE notifications ALTER COLUMN target_type DROP NOT NULL"

    execute "CREATE UNIQUE INDEX notifications_dedup_idx ON notifications (recipient_id, actor_id, type, COALESCE(target_type, 'nil'), COALESCE(target_id::text, 'nil'))"
  end
end
