defmodule YRepo.Schemas.Agree do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "agrees" do
    field :target_type, Ecto.Enum, values: [:take, :retake, :opinion]
    field :target_id, :binary_id
    belongs_to :user, YRepo.Schemas.User

    timestamps(type: :utc_datetime_usec, updated_at: false)
  end

  def changeset(agree, attrs) do
    agree
    |> cast(attrs, [:user_id, :target_type, :target_id])
    |> validate_required([:user_id, :target_type, :target_id])
    |> unique_constraint([:user_id, :target_type, :target_id])
  end
end
