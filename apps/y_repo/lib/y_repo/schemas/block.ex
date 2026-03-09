defmodule YRepo.Schemas.Block do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "blocks" do
    belongs_to :blocker, YRepo.Schemas.User
    belongs_to :blocked, YRepo.Schemas.User

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(block, attrs) do
    block
    |> cast(attrs, [:blocker_id, :blocked_id])
    |> validate_required([:blocker_id, :blocked_id])
    |> unique_constraint([:blocker_id, :blocked_id])
  end
end
