defmodule YRepo.Repo.Migrations.CreateOpinions do
  use Ecto.Migration

  def change do
    create table(:opinions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :parent_take_id, references(:takes, type: :binary_id, on_delete: :nilify_all)
      add :parent_opinion_id, references(:opinions, type: :binary_id, on_delete: :nilify_all)
      add :body, :text, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create index(:opinions, [:user_id])
    create index(:opinions, [:parent_take_id])
    create index(:opinions, [:parent_opinion_id])
  end
end
