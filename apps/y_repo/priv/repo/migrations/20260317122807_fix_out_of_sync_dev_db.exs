defmodule YRepo.Repo.Migrations.FixOutOfSyncDevDb do
  use Ecto.Migration

  def change do
    # This migration was redundant as initial migrations already define the correct schema.
    # Emptying to allow clean runs in test environment.
  end
end
