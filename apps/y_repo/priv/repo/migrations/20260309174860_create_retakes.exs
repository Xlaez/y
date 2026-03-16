defmodule YRepo.Repo.Migrations.CreateRetakes do
  use Ecto.Migration

  def change do
    create table(:retakes, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("gen_random_uuid()")
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false
      add :original_take_id, references(:takes, type: :uuid, on_delete: :delete_all), null: false
      add :comment, :text

      timestamps(type: :utc_datetime_usec, updated_at: false)
    end

    create constraint(:retakes, :comment_length, check: "comment IS NULL OR char_length(comment) <= 250")

    create unique_index(:retakes, [:user_id, :original_take_id])
    create index(:retakes, [:original_take_id])
    create index(:retakes, [:user_id, :inserted_at])
  end
end
