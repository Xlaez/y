defmodule YRepo.Repo.Migrations.UpdateUsersForUserManagement do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :bitmoji_color, :text, default: "#3A3A3C", null: false
    end
  end
end
