defmodule YCore.Notifications.Notification do
  @moduledoc """
  Domain entity for Notification.
  """
  defstruct [
    :id,
    :recipient_id,
    :actor_id,
    :type,        # :agreed, :opined, :retook, :followed
    :target_type, # :take, :retake, :opinion, or nil
    :target_id,
    :read,
    :inserted_at
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          recipient_id: String.t(),
          actor_id: String.t(),
          type: atom(),
          target_type: atom() | nil,
          target_id: String.t() | nil,
          read: boolean(),
          inserted_at: DateTime.t()
        }
end
