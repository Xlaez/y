defmodule YCore.Notifications.Notification do
  defstruct [
    :id,
    :recipient_id,
    :type,
    :actor_id,
    :target_id,
    :target_type,
    :read,
    :inserted_at
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          recipient_id: String.t(),
          type: :agreed | :opined | :retook | :followed,
          actor_id: String.t(),
          target_id: String.t(),
          target_type: :take | :retake | :opinion,
          read: boolean(),
          inserted_at: DateTime.t()
        }
end

defmodule YCore.Notifications.NotificationRepository do
  @callback list_for_user(user_id :: String.t()) :: [YCore.Notifications.Notification.t()]
  @callback mark_as_read(notification_id :: String.t()) :: :ok | {:error, any()}
end
