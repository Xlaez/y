defmodule YRepo.Schemas.Retake do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "retakes" do
    field :comment, :string
    belongs_to :user, YRepo.Schemas.User
    belongs_to :original_take, YRepo.Schemas.Take

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(retake, attrs) do
    retake
    |> cast(attrs, [:comment, :user_id, :original_take_id])
    |> validate_required([:user_id, :original_take_id])
    |> validate_length(:comment, max: 250)
    |> unique_constraint([:user_id, :original_take_id])
  end
end
