defmodule YWeb.SessionLive do
  use YWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, show_password: false, error: nil)}
  end

  def handle_event("toggle_password", _, socket) do
    {:noreply, assign(socket, show_password: !socket.assigns.show_password)}
  end

  def handle_event("submit", %{"username" => username, "password" => _password}, socket) do
    # Dummy login logic
    if username == "error" do
      {:noreply, assign(socket, error: "Invalid username or password")}
    else
      {:noreply, push_navigate(socket, to: "/home")}
    end
  end
end
