defmodule YRepo.Repo.Migrations.CreateRetakes do
  use Ecto.Migration

  def change do
    create table(:retakes, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("gen_random_uuid()")
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false
      add :take_id, references(:takes, type: :uuid, on_delete: :delete_all), null: false
      add :comment, :string, size: 250

      timestamps(type: :utc_datetime_usec)
    end

    create index(:retakes, [:user_id])
    create index(:retakes, [:take_id])
  end
end
