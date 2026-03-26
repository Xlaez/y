defmodule YRepo.Schemas.Take do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "takes" do
    field :body, :string
    field :opinion_count, :integer, default: 0
    field :retake_count, :integer, default: 0
    field :deleted_at, :utc_datetime_usec
    field :score, :float, virtual: true
    belongs_to :user, YRepo.Schemas.User

    timestamps(type: :utc_datetime_usec, updated_at: false)
  end

  def changeset(take, attrs) do
    take
    |> cast(attrs, [:body, :user_id, :opinion_count, :retake_count])
    |> validate_required([:body, :user_id])
    |> validate_length(:body, min: 1, max: 250)
  end
end
