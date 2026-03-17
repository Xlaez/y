defmodule YRepo.Repo.Migrations.FixOutOfSyncDevDb do
  use Ecto.Migration

  def change do
    rename table(:opinions), :parent_take_id, to: :take_id
    alter table(:opinions) do
      add :depth, :integer, null: false, default: 0
    end
    rename table(:retakes), :take_id, to: :original_take_id
  end
end
