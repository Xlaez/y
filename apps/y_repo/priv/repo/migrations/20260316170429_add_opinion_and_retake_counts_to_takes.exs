defmodule YRepo.Repo.Migrations.AddOpinionAndRetakeCountsToTakes do
  use Ecto.Migration

  def change do
    alter table(:takes) do
      add :opinion_count, :integer, default: 0, null: false, if_not_exists: true
      add :retake_count, :integer, default: 0, null: false, if_not_exists: true
    end
  end
end
