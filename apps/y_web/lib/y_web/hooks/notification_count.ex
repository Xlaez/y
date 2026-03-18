defmodule YWeb.Hooks.NotificationCount do
  import Phoenix.Component
  import Phoenix.LiveView
  
  alias YRepo.Repositories.NotificationRepository

  def on_mount(:default, _params, _session, socket) do
    if user = socket.assigns[:current_user] do
      if connected?(socket) do
        Phoenix.PubSub.subscribe(Y.PubSub, "user:#{user.id}:notifications")
      end

      socket = 
        socket
        |> assign(:unread_notification_count, NotificationRepository.unread_count(user.id))
        |> attach_hook(:notification_count_handler, :handle_info, fn
          {:new_notification, _}, socket ->
            new_count = (socket.assigns[:unread_notification_count] || 0) + 1
            {:halt, assign(socket, :unread_notification_count, new_count)}
          
          :refresh_unread_count, socket ->
            user_id = socket.assigns.current_user.id
            new_count = NotificationRepository.unread_count(user_id)
            schedule_refresh()
            {:halt, assign(socket, :unread_notification_count, new_count)}

          _message, socket ->
            {:cont, socket}
        end)

      if connected?(socket), do: schedule_refresh()

      {:cont, socket}
    else
      {:cont, socket}
    end
  end

  defp schedule_refresh() do
    Process.send_after(self(), :refresh_unread_count, 60_000) # Poll every 60 seconds
  end
end
