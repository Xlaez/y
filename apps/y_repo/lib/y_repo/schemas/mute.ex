defmodule YRepo.Schemas.Mute do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "mutes" do
    belongs_to :muter, YRepo.Schemas.User
    belongs_to :muted, YRepo.Schemas.User

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(mute, attrs) do
    mute
    |> cast(attrs, [:muter_id, :muted_id])
    |> validate_required([:muter_id, :muted_id])
    |> unique_constraint([:muter_id, :muted_id])
  end
end
