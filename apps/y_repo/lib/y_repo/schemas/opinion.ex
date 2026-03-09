defmodule YRepo.Schemas.Opinion do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "opinions" do
    field :body, :string
    belongs_to :user, YRepo.Schemas.User
    belongs_to :parent_take, YRepo.Schemas.Take
    belongs_to :parent_opinion, YRepo.Schemas.Opinion

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(opinion, attrs) do
    opinion
    |> cast(attrs, [:body, :user_id, :parent_take_id, :parent_opinion_id])
    |> validate_required([:body, :user_id])
  end
end
