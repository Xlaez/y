defmodule YWeb.PasswordResetLive do
  use YWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, step: :verify, show_password: false, show_confirm: false, success: false)}
  end

  def handle_event("verify", _params, socket) do
    {:noreply, assign(socket, step: :reset)}
  end

  def handle_event("toggle_password", %{"field" => "password"}, socket) do
    {:noreply, assign(socket, show_password: !socket.assigns.show_password)}
  end

  def handle_event("toggle_password", %{"field" => "confirm"}, socket) do
    {:noreply, assign(socket, show_confirm: !socket.assigns.show_confirm)}
  end

  def handle_event("reset_password", _params, socket) do
    {:noreply, assign(socket, success: true)}
  end
end
