defmodule YRepo.Repo.Migrations.CreateOpinions do
  use Ecto.Migration

  def change do
    create table(:opinions, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("gen_random_uuid()")
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false
      add :take_id, references(:takes, type: :uuid, on_delete: :delete_all), null: false
      add :parent_opinion_id, references(:opinions, type: :uuid, on_delete: :delete_all)
      add :body, :text, null: false
      add :depth, :integer, null: false, default: 0

      timestamps(type: :utc_datetime_usec, updated_at: false)
    end

    create constraint(:opinions, :body_length, check: "char_length(body) >= 1 AND char_length(body) <= 250")
    create constraint(:opinions, :max_depth, check: "depth >= 0 AND depth <= 4")

    create index(:opinions, [:take_id, :inserted_at])
    create index(:opinions, [:parent_opinion_id])
    create index(:opinions, [:user_id, :inserted_at])
  end
end
