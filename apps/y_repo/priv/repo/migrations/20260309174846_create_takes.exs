defmodule YRepo.Repo.Migrations.CreateTakes do
  use Ecto.Migration

  def change do
    create table(:takes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :body, :string, size: 250, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create index(:takes, [:user_id])
    create index(:takes, [:inserted_at])
  end
end
