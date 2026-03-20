defmodule YRepo.Schemas.Opinion do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "opinions" do
    field :body, :string
    field :depth, :integer, default: 0
    belongs_to :user, YRepo.Schemas.User
    belongs_to :take, YRepo.Schemas.Take
    belongs_to :parent_opinion, YRepo.Schemas.Opinion

    timestamps(type: :utc_datetime_usec, updated_at: false)
  end

  def changeset(opinion, attrs) do
    opinion
    |> cast(attrs, [:body, :user_id, :take_id, :parent_opinion_id, :depth])
    |> validate_required([:body, :user_id, :take_id, :depth])
    |> validate_length(:body, min: 1, max: 250)
    |> validate_number(:depth, greater_than_or_equal_to: 0, less_than_or_equal_to: 4)
  end
end
