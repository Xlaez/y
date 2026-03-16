defmodule YRepo.Repo.Migrations.CreateBookmarks do
  use Ecto.Migration

  def change do
    create table(:bookmarks, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("gen_random_uuid()")
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false
      add :target_type, :string, null: false
      add :target_id, :uuid, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:bookmarks, [:user_id, :target_type, :target_id])
    create index(:bookmarks, [:target_type, :target_id])
  end
end
