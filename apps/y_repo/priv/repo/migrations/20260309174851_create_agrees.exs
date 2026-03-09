defmodule YRepo.Repo.Migrations.CreateAgrees do
  use Ecto.Migration

  def change do
    create table(:agrees, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :target_type, :string, null: false
      add :target_id, :binary_id, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:agrees, [:user_id, :target_type, :target_id])
    create index(:agrees, [:target_type, :target_id])
  end
end
