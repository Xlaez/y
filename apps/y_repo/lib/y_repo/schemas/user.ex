defmodule YRepo.Schemas.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :string, autogenerate: false}
  @foreign_key_type :string

  schema "users" do
    field :username, :string
    field :password_hash, :string
    field :seed_phrase_hash, :string
    field :bitmoji_id, :string
    field :is_locked, :boolean, default: false

    timestamps(type: :utc_datetime_usec)
  end

  @doc """
  Changeset for initial user creation.
  Hash values arrive pre-computed from domain services.
  """
  def creation_changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:id, :username, :password_hash, :seed_phrase_hash, :bitmoji_id])
    |> validate_required([:username, :password_hash, :seed_phrase_hash, :bitmoji_id])
    |> ensure_id()
    |> validate_username_format()
    |> unique_constraint(:username, name: :users_username_lower_idx)
  end

  def password_update_changeset(user, attrs) do
    user
    |> cast(attrs, [:password_hash])
    |> validate_required([:password_hash])
  end

  def lock_changeset(user, attrs) do
    user
    |> cast(attrs, [:is_locked])
    |> validate_required([:is_locked])
  end

  defp ensure_id(changeset) do
    if get_field(changeset, :id) do
      changeset
    else
      put_change(changeset, :id, Ecto.UUID.generate())
    end
  end

  defp validate_username_format(changeset) do
    # Replicating Value Object logic in database changeset for layered defense
    validate_format(changeset, :username, ~r/^[a-z0-9_]+$/,
      message: "can only contain alphanumeric characters and underscores"
    )
    |> validate_change(:username, fn :username, username ->
      if String.starts_with?(username, "_") do
        [username: "cannot start with an underscore"]
      else
        []
      end
    end)
    |> validate_length(:username, min: 3, max: 30)
  end
end
