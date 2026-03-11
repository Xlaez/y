defmodule YWeb.RegistrationLive do
  use YWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, 
      username: "", 
      show_password: false,
      show_confirm_password: false,
      error: nil
    )}
  end

  def handle_event("validate", %{"username" => username}, socket) do
    {:noreply, assign(socket, username: username)}
  end

  def handle_event("toggle_password", %{"field" => "password"}, socket) do
    {:noreply, assign(socket, show_password: !socket.assigns.show_password)}
  end

  def handle_event("toggle_password", %{"field" => "confirm"}, socket) do
    {:noreply, assign(socket, show_confirm_password: !socket.assigns.show_confirm_password)}
  end

  def handle_event("submit", _params, socket) do
    # Dummy registration logic
    {:noreply, push_navigate(socket, to: "/onboarding/seed-phrase")}
  end
end
