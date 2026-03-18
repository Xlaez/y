defmodule YCore.Notifications.NotificationService do
  @moduledoc """
  Service for creating and broadcasting notifications.
  """
  alias YCore.Notifications.Notification
  alias YCore.Notifications.NotificationRepository
  alias YRepo.Repositories.UserRepository

  @spec notify_agreed(String.t(), String.t(), atom(), String.t(), module()) :: :ok
  def notify_agreed(actor_id, recipient_id, target_type, target_id, repo \\ NotificationRepository) do
    if should_notify?(actor_id, recipient_id) do
      case repo.create(%{
             actor_id: actor_id,
             recipient_id: recipient_id,
             type: "agreed",
             target_type: to_string(target_type),
             target_id: target_id
           }) do
        {:ok, notification} ->
          actor = UserRepository.get_by_id!(actor_id)
          broadcast(notification, actor)
          {:ok, notification}

        error ->
          error
      end
    else
      :ok
    end
  end

  @spec notify_opined(String.t(), String.t(), String.t(), String.t(), module()) :: :ok
  def notify_opined(actor_id, recipient_id, take_id, opinion_id, repo \\ NotificationRepository) do
    if should_notify?(actor_id, recipient_id) do
      case repo.create(%{
             actor_id: actor_id,
             recipient_id: recipient_id,
             type: "opined",
             target_type: "opinion",
             target_id: opinion_id
           }) do
        {:ok, notification} ->
          actor = UserRepository.get_by_id!(actor_id)
          # Fetch the opinion body for the excerpt
          opinion = YRepo.Repo.get!(YRepo.Schemas.Opinion, opinion_id)
          broadcast(notification, actor, opinion.body)
          {:ok, notification}

        error ->
          error
      end
    else
      :ok
    end
  end

  @spec notify_retook(String.t(), String.t(), String.t(), String.t(), module()) :: :ok
  def notify_retook(actor_id, recipient_id, take_id, retake_id, repo \\ NotificationRepository) do
    if should_notify?(actor_id, recipient_id) do
      case repo.create(%{
             actor_id: actor_id,
             recipient_id: recipient_id,
             type: "retook",
             target_type: "retake",
             target_id: retake_id
           }) do
        {:ok, notification} ->
          actor = UserRepository.get_by_id!(actor_id)
          # Fetch the retake comment for the excerpt
          retake = YRepo.Repo.get!(YRepo.Schemas.Retake, retake_id)
          broadcast(notification, actor, retake.comment)
          {:ok, notification}

        error ->
          error
      end
    else
      :ok
    end
  end

  @spec notify_followed(String.t(), String.t(), module()) :: :ok
  def notify_followed(actor_id, recipient_id, repo \\ NotificationRepository) do
    if should_notify?(actor_id, recipient_id) do
      case repo.create(%{
             actor_id: actor_id,
             recipient_id: recipient_id,
             type: "followed"
           }) do
        {:ok, notification} ->
          actor = UserRepository.get_by_id!(actor_id)
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
