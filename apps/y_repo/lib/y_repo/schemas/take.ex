defmodule YRepo.Schemas.Take do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "takes" do
    field :body, :string
    belongs_to :user, YRepo.Schemas.User

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(take, attrs) do
    take
    |> cast(attrs, [:body, :user_id])
    |> validate_required([:body, :user_id])
    |> validate_length(:body, max: 250)
  end
end
