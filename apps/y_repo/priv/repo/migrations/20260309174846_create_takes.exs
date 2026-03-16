defmodule YRepo.Repo.Migrations.CreateTakes do
  use Ecto.Migration

  def change do
    create table(:takes, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("gen_random_uuid()")
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false
      add :body, :text, null: false
      add :opinion_count, :integer, default: 0, null: false
      add :retake_count, :integer, default: 0, null: false

      timestamps(type: :utc_datetime_usec, updated_at: false)
    end

    create constraint(:takes, :body_length, check: "char_length(body) >= 1 AND char_length(body) <= 250")

    create index(:takes, [:user_id, :inserted_at])
    create index(:takes, [:inserted_at])
  end
end
