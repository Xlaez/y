defmodule YRepo.Repo.Migrations.CreateFollows do
  use Ecto.Migration

  def change do
    create table(:follows, primary_key: false) do
      add :id, :binary, primary_key: true
      add :follower_id, references(:users, type: :binary, on_delete: :delete_all), null: false
      add :followee_id, references(:users, type: :binary, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:follows, [:follower_id, :followee_id])
    create index(:follows, [:followee_id])
  end
end
