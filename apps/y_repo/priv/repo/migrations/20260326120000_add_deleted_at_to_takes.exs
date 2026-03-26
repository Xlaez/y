defmodule YRepo.Repo.Migrations.AddDeletedAtToTakes do
  use Ecto.Migration

  def change do
    alter table(:takes) do
      add :deleted_at, :utc_datetime_usec, null: true
    end
  end
end
