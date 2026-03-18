defmodule YRepo.Schemas.Notification do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "notifications" do
    field :type, :string
    field :target_id, :binary_id
    field :target_type, :string
    field :read, :boolean, default: false

    belongs_to :recipient, YRepo.Schemas.User
    belongs_to :actor, YRepo.Schemas.User

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(notification, attrs) do
    notification
    |> cast(attrs, [:recipient_id, :actor_id, :type, :target_id, :target_type, :read])
    |> validate_required([:recipient_id, :actor_id, :type])
  end
end
