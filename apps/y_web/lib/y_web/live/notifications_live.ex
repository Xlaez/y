defmodule YWeb.NotificationsLive do
  use YWeb, :live_view
  use YWeb.Live.RecommendationEvents

  alias YRepo.Repositories.{NotificationRepository, UserRepository, TakeRepository, OpinionRepository, RetakeRepository}

  def mount(_params, _session, socket) do
    user_id = socket.assigns.current_user.id
    
    # Mark all as read when opening the page
    NotificationRepository.mark_all_read(user_id)
    
    # Pre-assign as 0 since we just marked all as read
    socket = assign(socket, unread_notification_count: 0)

    if connected?(socket), do: schedule_refresh()

    {:ok,
     socket
     |> assign(active_tab: :notifications)
     |> fetch_notifications(),
     layout: {YWeb.Layouts, :authenticated}}
  end

  def handle_info(:refresh_notifications, socket) do
    # Periodic refresh (polling fallback)
    schedule_refresh()
    {:noreply, fetch_notifications(socket)}
  end

  def handle_info({:new_notification, _}, socket) do
    # When a new notification arrives while on this page, 
    # we refresh the list. 
    # Since the user is *on* the page, maybe we should mark it as read immediately?
    # For now, just refresh the list.
    {:noreply, fetch_notifications(socket)}
  end

  def handle_event("mark_all_read", _, socket) do
    NotificationRepository.mark_all_read(socket.assigns.current_user.id)
    {:noreply, 
      socket 
      |> assign(unread_notification_count: 0)
      |> fetch_notifications()
    }
  end

  def handle_event("mark_read", %{"id" => id}, socket) do
    NotificationRepository.mark_read(id)
    {:noreply, fetch_notifications(socket)}
  end

  defp fetch_notifications(socket) do
    user_id = socket.assigns.current_user.id
    notifications = NotificationRepository.list_for_user(user_id, limit: 50)
    enriched = enrich_notifications(notifications)
    assign(socket, notifications: enriched)
  end

  defp enrich_notifications([]), do: []
  defp enrich_notifications(notifications) do
    # 1. Collect IDs for batch fetching
    actor_ids = Enum.map(notifications, & &1.actor_id) |> Enum.uniq()
    
    take_ids = 
      notifications 
      |> Enum.filter(& &1.target_type == :take) 
      |> Enum.map(& &1.target_id)
      
    opinion_ids = 
      notifications 
      |> Enum.filter(& &1.target_type == :opinion) 
      |> Enum.map(& &1.target_id)
      
    retake_ids = 
      notifications 
      |> Enum.filter(& &1.target_type == :retake) 
      |> Enum.map(& &1.target_id)

    # 2. Batch fetch
    actors = UserRepository.list_by_ids(actor_ids) |> Map.new(&{&1.id, &1})
    takes = TakeRepository.list_by_ids(take_ids) |> Map.new(&{&1.id, &1})
    opinions = OpinionRepository.list_by_ids(opinion_ids) |> Map.new(&{&1.id, &1})
    retakes = RetakeRepository.list_by_ids(retake_ids) |> Map.new(&{&1.id, &1})

    # 3. Assemble
    Enum.map(notifications, fn n ->
      actor = Map.get(actors, n.actor_id)
      
      {text, excerpt} = case n.type do
        :agreed -> 
          target_text = case n.target_type do
            :take -> "your take"
            :retake -> "your retake"
            :opinion -> "your opinion"
            _ -> "your content"
          end
          {"agreed with #{target_text}", resolve_excerpt(n, takes, opinions, retakes)}
          
        :opined -> 
          {"dropped an opinion on your take", resolve_excerpt(n, takes, opinions, retakes)}
          
        :retook -> 
          {"retook your take", resolve_excerpt(n, takes, opinions, retakes)}
          
        :followed -> 
          {"followed you", nil}
      end

      %{
        id: n.id,
        type: n.type,
        actor: actor,
        text: text,
        excerpt: excerpt,
        unread: !n.read,
        timestamp: YWeb.Helpers.Time.relative(n.inserted_at)
      }
    end)
  end

  defp resolve_excerpt(n, takes, opinions, retakes) do
    case n.target_type do
      :take -> Map.get(takes, n.target_id, %{}) |> Map.get(:body)
      :opinion -> Map.get(opinions, n.target_id, %{}) |> Map.get(:body)
      :retake -> Map.get(retakes, n.target_id, %{}) |> Map.get(:comment)
      _ -> nil
    end
  rescue
    _ -> nil
  end

  defp schedule_refresh() do
    Process.send_after(self(), :refresh_notifications, 60_000)
  end
end
