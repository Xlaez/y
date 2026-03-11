defmodule YWeb.NotificationsLive do
  use YWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(active_tab: :notifications)
     |> assign(notifications: YWeb.DummyData.notifications()),
     layout: {YWeb.Layouts, :authenticated}}
  end

  def handle_event("mark_read", %{"id" => id}, socket) do
    # Dummy logic to mark notification as read
    updated_notifications = Enum.map(socket.assigns.notifications, fn n ->
      if to_string(n.id) == id, do: %{n | unread: false}, else: n
    end)
    {:noreply, assign(socket, notifications: updated_notifications)}
  end
end
