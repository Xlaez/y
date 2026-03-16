defmodule YRepo.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("gen_random_uuid()")
      add :recipient_id, references(:users, type: :uuid, on_delete: :delete_all), null: false
      add :actor_id, references(:users, type: :uuid, on_delete: :delete_all), null: false
      add :type, :string, null: false
      add :target_id, :uuid, null: false
      add :target_type, :string, null: false
      add :read, :boolean, default: false, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create index(:notifications, [:recipient_id])
    create index(:notifications, [:inserted_at])
  end
end
