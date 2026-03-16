defmodule YRepo.Repo.Migrations.CreateAgrees do
  use Ecto.Migration

  def change do
    create table(:agrees, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("gen_random_uuid()")
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false
      add :target_type, :string, size: 10, null: false
      add :target_id, :uuid, null: false

      timestamps(type: :utc_datetime_usec, updated_at: false)
    end

    create constraint(:agrees, :target_type_values, check: "target_type IN ('take', 'retake', 'opinion')")

    create unique_index(:agrees, [:user_id, :target_type, :target_id])
    create index(:agrees, [:target_type, :target_id])
  end
end
