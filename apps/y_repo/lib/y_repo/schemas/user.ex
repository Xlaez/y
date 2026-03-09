defmodule YRepo.Schemas.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :username, :string
    field :password_hash, :string
    field :seed_phrase_hash, :string
    field :bitmoji_id, :string
    field :is_locked, :boolean, default: false

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :password_hash, :seed_phrase_hash, :bitmoji_id, :is_locked])
    |> validate_required([:username, :password_hash, :seed_phrase_hash])
    |> unique_constraint(:username)
  end
end
