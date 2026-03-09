defmodule YRepo.Repositories.NotificationRepository do
  @behaviour YCore.Notifications.NotificationRepository

  import Ecto.Query
  alias YRepo.Repo
  alias YRepo.Schemas.Notification
  alias YCore.Notifications.Notification, as: DomainNotification

  def list_for_user(user_id) do
    Notification
    |> where([n], n.recipient_id == ^user_id)
    |> order_by([n], desc: n.inserted_at)
    |> Repo.all()
    |> Enum.map(&to_domain/1)
  end

  def mark_as_read(id) do
    case Repo.get(Notification, id) do
      nil -> {:error, :not_found}
      schema ->
        schema
        |> Notification.changeset(%{read: true})
        |> Repo.update()
        |> case do
          {:ok, _} -> :ok
          {:error, changeset} -> {:error, changeset}
        end
    end
  end

  defp to_domain(schema) do
    %DomainNotification{
      id: schema.id,
      recipient_id: schema.recipient_id,
      actor_id: schema.actor_id,
      type: schema.type,
      target_id: schema.target_id,
      target_type: schema.target_type,
      read: schema.read,
      inserted_at: schema.inserted_at
    }
  end
end
