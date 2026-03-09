defmodule YRepo.Repo.Migrations.CreateMutes do
  use Ecto.Migration

  def change do
    create table(:mutes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :muter_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :muted_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:mutes, [:muter_id, :muted_id])
    create index(:mutes, [:muted_id])
  end
end
