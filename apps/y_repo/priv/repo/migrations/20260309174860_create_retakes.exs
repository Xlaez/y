defmodule YRepo.Repo.Migrations.CreateRetakes do
  use Ecto.Migration

  def change do
    create table(:retakes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :original_take_id, references(:takes, type: :binary_id, on_delete: :delete_all), null: false
      add :comment, :string, size: 250

      timestamps(type: :utc_datetime_usec)
    end

    create index(:retakes, [:user_id])
    create index(:retakes, [:original_take_id])
  end
end
