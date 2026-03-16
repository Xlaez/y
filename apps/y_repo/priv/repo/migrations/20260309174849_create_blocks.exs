defmodule YRepo.Repo.Migrations.CreateBlocks do
  use Ecto.Migration

  def change do
    create table(:blocks, primary_key: false) do
      add :id, :binary, primary_key: true
      add :blocker_id, references(:users, type: :binary, on_delete: :delete_all), null: false
      add :blocked_id, references(:users, type: :binary, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:blocks, [:blocker_id, :blocked_id])
    create index(:blocks, [:blocked_id])
  end
end
