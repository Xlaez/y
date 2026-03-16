defmodule YWeb.SessionLive do
  use YWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, username: "", password: "", show_password: false, error: nil, trigger_submit: false)}
  end

  def handle_event("validate", %{"username" => username, "password" => password}, socket) do
    {:noreply, assign(socket, username: username, password: password)}
  end

  def handle_event("toggle_password", _, socket) do
    {:noreply, assign(socket, show_password: !socket.assigns.show_password)}
  end

  def handle_event("submit", %{"username" => username, "password" => password}, socket) do
    user_repo = Application.get_env(:y_core, :repositories)[:user]
    
    case YCore.Accounts.AuthenticationService.authenticate(username, password, user_repo) do
      {:ok, _user} ->
        {:noreply, assign(socket, trigger_submit: true, error: nil)}

      {:error, :invalid_credentials} ->
        {:noreply, assign(socket, error: "Invalid username or password")}
    end
  end
end
