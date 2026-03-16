defmodule YRepo.Schemas.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID

  schema "users" do
    field :username, :string
    field :password_hash, :string
    field :seed_phrase_hash, :string
    field :bitmoji_id, Ecto.UUID
    field :bitmoji_color, :string, default: "#3A3A3C"
    field :display_name, :string
    field :profile_picture_base64, :string
    field :is_locked, :boolean, default: false

    timestamps(type: :utc_datetime_usec)
  end

  def creation_changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:id, :username, :password_hash, :seed_phrase_hash, :bitmoji_id, :bitmoji_color, :display_name, :profile_picture_base64])
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

  def bitmoji_color_changeset(user, attrs) do
    user
    |> cast(attrs, [:bitmoji_color])
    |> validate_required([:bitmoji_color])
  end

  def update_profile_changeset(user, attrs) do
    user
    |> cast(attrs, [:display_name, :profile_picture_base64])
    |> validate_length(:display_name, max: 50)
  end

  def update_changeset(user, attrs) do
    user
    |> cast(attrs, [:password_hash, :bitmoji_color, :is_locked])
  end

  defp ensure_id(changeset) do
    if get_field(changeset, :id) do
      changeset
    else
      put_change(changeset, :id, Ecto.UUID.generate())
    end
  end

  defp validate_username_format(changeset) do
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
