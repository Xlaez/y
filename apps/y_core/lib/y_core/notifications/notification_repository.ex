defmodule YCore.Notifications.NotificationRepository do
  @moduledoc """
  Repository behaviour for Notification.
  """
  alias YCore.Notifications.Notification

  @callback create(map()) :: {:ok, Notification.t()} | {:error, term()}

  @callback list_for_user(recipient_id :: String.t(), opts :: keyword()) ::
              [Notification.t()]

  @callback unread_count(recipient_id :: String.t()) :: non_neg_integer()

  @callback mark_all_read(recipient_id :: String.t()) :: :ok

  @callback mark_read(notification_id :: String.t()) :: :ok

  @callback delete_expired() :: {non_neg_integer(), nil}
end
