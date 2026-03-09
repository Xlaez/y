defmodule YRepo.Schemas.Bookmark do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "bookmarks" do
    field :target_type, Ecto.Enum, values: [:take, :retake, :opinion]
    field :target_id, :binary_id
    belongs_to :user, YRepo.Schemas.User

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(bookmark, attrs) do
    bookmark
    |> cast(attrs, [:user_id, :target_type, :target_id])
    |> validate_required([:user_id, :target_type, :target_id])
    |> unique_constraint([:user_id, :target_type, :target_id])
  end
end
