defmodule YCore.Notifications.NotificationService do
  @moduledoc """
  Service for creating and broadcasting notifications.
  """
  alias YCore.Accounts.UserRepository
  alias YCore.Notifications.Notification
  alias YCore.Notifications.NotificationRepository

  @spec notify_agreed(String.t(), String.t(), atom(), String.t(), module(), module()) :: :ok
  def notify_agreed(actor_id, recipient_id, target_type, target_id, repo, user_repo) do
    if should_notify?(actor_id, recipient_id) do
      case repo.create(%{
             actor_id: actor_id,
             recipient_id: recipient_id,
             type: "agreed",
             target_type: to_string(target_type),
             target_id: target_id
           }) do
        {:ok, notification} ->
          actor = user_repo.get_by_id!(actor_id)
          broadcast(notification, actor)
          {:ok, notification}

        error ->
          error
      end
    else
      :ok
    end
  end

  @spec notify_opined(String.t(), String.t(), String.t(), String.t(), module(), module(), module()) :: :ok
  def notify_opined(actor_id, recipient_id, _take_id, opinion_id, repo, user_repo, opinion_repo) do
    if should_notify?(actor_id, recipient_id) do
      case repo.create(%{
             actor_id: actor_id,
             recipient_id: recipient_id,
             type: "opined",
             target_type: "opinion",
             target_id: opinion_id
           }) do
        {:ok, notification} ->
          actor = user_repo.get_by_id!(actor_id)
          # Fetch the opinion body for the excerpt
          excerpt = if opinion_repo do
            case opinion_repo.get_by_id(opinion_id) do
              {:ok, op} -> op.body
              _ -> nil
            end
          else
            nil
          end
          broadcast(notification, actor, excerpt)
          {:ok, notification}

        error ->
          error
      end
    else
      :ok
    end
  end

  @spec notify_retook(String.t(), String.t(), String.t(), String.t(), module(), module(), module()) :: :ok
  def notify_retook(actor_id, recipient_id, _take_id, retake_id, repo, user_repo, retake_repo) do
    if should_notify?(actor_id, recipient_id) do
      case repo.create(%{
             actor_id: actor_id,
             recipient_id: recipient_id,
             type: "retook",
             target_type: "retake",
             target_id: retake_id
           }) do
        {:ok, notification} ->
          actor = user_repo.get_by_id!(actor_id)
          # Fetch the retake comment for the excerpt
          excerpt = if retake_repo do
            case retake_repo.get_by_id(retake_id) do
              {:ok, retake} -> retake.comment
              _ -> nil
            end
          else
            nil
          end
          broadcast(notification, actor, excerpt)
          {:ok, notification}

        error ->
          error
      end
    else
      :ok
    end
  end

  @spec notify_followed(String.t(), String.t(), module(), module()) :: :ok
  def notify_followed(actor_id, recipient_id, repo, user_repo) do
    if should_notify?(actor_id, recipient_id) do
      case repo.create(%{
             actor_id: actor_id,
             recipient_id: recipient_id,
             type: "followed"
           }) do
        {:ok, notification} ->
          actor = user_repo.get_by_id!(actor_id)
          broadcast(notification, actor)
          {:ok, notification}

        error ->
          error
      end
    else
      :ok
    end
  end

  @spec broadcast(Notification.t(), map(), String.t() | nil) :: :ok
  def broadcast(notification, actor, excerpt \\ nil) do
    enriched_map = %{
      id: notification.id,
      type: notification.type,
      target_type: notification.target_type,
      target_id: notification.target_id,
      read: false,
      inserted_at: notification.inserted_at,
      actor: %{
        id: actor.id,
        username: actor.username,
        bitmoji_color: actor.bitmoji_color
      },
      excerpt: excerpt
    }

    Phoenix.PubSub.broadcast(
      Y.PubSub,
      "user:#{notification.recipient_id}:notifications",
      {:new_notification, enriched_map}
    )
  end

  defp should_notify?(actor_id, recipient_id), do: actor_id != recipient_id
end
