defmodule YWeb.SettingsLive do
  use YWeb, :live_view

  def mount(_params, _session, socket) do
    user = YWeb.DummyData.current_user()
    {:ok,
     socket
     |> assign(active_tab: :settings)
     |> assign(user: user)
     |> assign(show_password_form: false)
     |> assign(show_bitmoji_modal: false)
     |> assign(show_delete_modal: false)
     |> assign(lock_account: user.is_locked)
     |> assign(colors: [
       "#E040FB", "#00E5FF", "#FF5252", "#FFB300", 
       "#00E676", "#FF6D00", "#40C4FF", "#F50057",
       "#7C4DFF", "#64FFDA", "#FF4081", "#FFD740",
       "#B2FF59", "#FFAB40", "#448AFF", "#FF1744"
     ]),
     layout: {YWeb.Layouts, :authenticated}}
  end

  def handle_event("toggle_password_form", _, socket) do
    {:noreply, assign(socket, show_password_form: !socket.assigns.show_password_form)}
  end

  def handle_event("open_bitmoji_modal", _, socket) do
    {:noreply, assign(socket, show_bitmoji_modal: true)}
  end

  def handle_event("close_modal", _, socket) do
    {:noreply, assign(socket, show_bitmoji_modal: false, show_delete_modal: false)}
  end

  def handle_event("select_color", %{"color" => color}, socket) do
    user = %{socket.assigns.user | bitmoji_color: color}
    {:noreply, 
     socket 
     |> assign(user: user, show_bitmoji_modal: false)
     |> put_flash(:info, "Bitmoji updated!")}
  end

  def handle_event("toggle_lock", _, socket) do
    state = !socket.assigns.lock_account
    msg = if state, do: "Account locked", else: "Account unlocked"
    {:noreply, 
     socket 
     |> assign(lock_account: state)
     |> put_flash(:info, msg)}
  end

  def handle_event("open_delete_modal", _, socket) do
    {:noreply, assign(socket, show_delete_modal: true)}
  end

  def handle_event("confirm_delete", _, socket) do
    {:noreply, push_navigate(socket, to: "/login")}
  end
end
