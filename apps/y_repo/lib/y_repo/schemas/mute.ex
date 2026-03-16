defmodule YRepo.Schemas.Mute do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "mutes" do
    belongs_to :muter, YRepo.Schemas.User
    belongs_to :muted_user, YRepo.Schemas.User, foreign_key: :muted_id

    field :inserted_at, :utc_datetime_usec, read_after_writes: true
  end

  def changeset(mute, attrs) do
    mute
    |> cast(attrs, [:muter_id, :muted_id])
    |> validate_required([:muter_id, :muted_id])
    |> unique_constraint([:muter_id, :muted_id])
    |> check_constraint(:muter_id, name: :no_self_mute, message: "cannot mute yourself")
  end
end
