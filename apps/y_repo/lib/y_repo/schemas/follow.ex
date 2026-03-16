defmodule YRepo.Schemas.Follow do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "follows" do
    belongs_to :follower, YRepo.Schemas.User
    belongs_to :followee, YRepo.Schemas.User

    field :inserted_at, :utc_datetime_usec, read_after_writes: true
  end

  def changeset(follow, attrs) do
    follow
    |> cast(attrs, [:follower_id, :followee_id])
    |> validate_required([:follower_id, :followee_id])
    |> unique_constraint([:follower_id, :followee_id])
    |> check_constraint(:follower_id, name: :no_self_follow, message: "cannot follow yourself")
  end
end
