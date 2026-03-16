defmodule YRepo.Schemas.Block do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID
  schema "blocks" do
    belongs_to :blocker, YRepo.Schemas.User
    belongs_to :blocked, YRepo.Schemas.User

    field :inserted_at, :utc_datetime_usec, read_after_writes: true
  end

  def changeset(block, attrs) do
    block
    |> cast(attrs, [:blocker_id, :blocked_id])
    |> validate_required([:blocker_id, :blocked_id])
    |> unique_constraint([:blocker_id, :blocked_id])
    |> check_constraint(:blocker_id, name: :no_self_block, message: "cannot block yourself")
  end
end
