defmodule YRepo.Repositories.NotificationRepository do
  @behaviour YCore.Notifications.NotificationRepository

  import Ecto.Query
  alias YRepo.Repo
  alias YRepo.Schemas.Notification, as: SchemaNotification
  alias YCore.Notifications.Notification, as: DomainNotification

  @impl true
  def create(attrs) do
    %SchemaNotification{}
    |> SchemaNotification.changeset(attrs)
    |> Repo.insert(
      on_conflict: :nothing, 
      conflict_target: {:unsafe_fragment, "(recipient_id, actor_id, type, COALESCE(target_type, 'nil'::character varying), COALESCE(target_id, '00000000-0000-0000-0000-000000000000'::uuid))"}
    )
    |> case do
      {:ok, schema} -> {:ok, to_domain(schema)}
      {:error, changeset} -> {:error, changeset}
    end
  end

  @impl true
  def list_for_user(recipient_id, opts \\ []) do
    limit = Keyword.get(opts, :limit, 30)
    before_cursor = Keyword.get(opts, :before)

    SchemaNotification
    |> where(recipient_id: ^recipient_id)
    |> then(fn query ->
      if before_cursor do
        where(query, [n], n.inserted_at < ^before_cursor)
      else
        query
      end
    end)
    |> order_by(desc: :inserted_at)
    |> limit(^limit)
    |> Repo.all()
    |> Enum.map(&to_domain/1)
  end

  @impl true
  def unread_count(recipient_id) do
    SchemaNotification
    |> where(recipient_id: ^recipient_id)
    |> where(read: false)
    |> Repo.aggregate(:count, :id)
  end

  @impl true
  def mark_all_read(recipient_id) do
    SchemaNotification
    |> where(recipient_id: ^recipient_id)
    |> where(read: false)
    |> Repo.update_all(set: [read: true])

    :ok
  end

  @impl true
  def mark_read(notification_id) do
    SchemaNotification
    |> where(id: ^notification_id)
    |> Repo.update_all(set: [read: true])

    :ok
  end

  @impl true
  def delete_expired() do
    thirty_days_ago = DateTime.utc_now() |> DateTime.add(-30, :day)

    SchemaNotification
    |> where([n], n.inserted_at < ^thirty_days_ago)
    |> Repo.delete_all()
  end

  defp to_domain(%SchemaNotification{} = schema) do
    %DomainNotification{
      id: schema.id,
      recipient_id: schema.recipient_id,
      actor_id: schema.actor_id,
      type: safe_to_atom(schema.type),
      target_type: safe_to_atom(schema.target_type),
      target_id: schema.target_id,
      read: schema.read,
      inserted_at: schema.inserted_at
    }
  end

  defp safe_to_atom(nil), do: nil
  defp safe_to_atom(binary) when is_binary(binary) do
    case binary do
      "agreed" -> :agreed
      "opined" -> :opined
      "retook" -> :retook
      "followed" -> :followed
      "take" -> :take
      "opinion" -> :opinion
      "retake" -> :retake
      _ -> String.to_atom(binary)
    end
  end
end
