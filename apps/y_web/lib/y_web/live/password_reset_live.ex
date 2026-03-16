defmodule YWeb.PasswordResetLive do
  use YWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, 
      assign(socket, 
        step: :verify, 
        username: "",
        phrase: "",
        password: "",
        confirm_password: "",
        show_password: false, 
        show_confirm: false, 
        error: nil,
        success: false
      )}
  end

  def handle_event("validate", %{"username" => u, "phrase" => p}, socket) do
    {:noreply, assign(socket, username: u, phrase: p)}
  end

  def handle_event("validate", %{"password" => p, "confirm_password" => cp}, socket) do
    {:noreply, assign(socket, password: p, confirm_password: cp)}
  end

  def handle_event("verify", %{"username" => username, "phrase" => phrase}, socket) do
    repo = Application.get_env(:y_core, :repositories)[:user]
    
    case YCore.Accounts.PasswordResetService.verify_identity(username, phrase, repo) do
      {:ok, _user} ->
        {:noreply, assign(socket, step: :reset, error: nil)}
      {:error, :invalid_credentials} ->
        {:noreply, assign(socket, error: "Invalid username or recovery phrase")}
    end
  end

  def handle_event("toggle_password", %{"field" => "password"}, socket) do
    {:noreply, assign(socket, show_password: !socket.assigns.show_password)}
  end

  def handle_event("toggle_password", %{"field" => "confirm"}, socket) do
    {:noreply, assign(socket, show_confirm: !socket.assigns.show_confirm)}
  end

  def handle_event("reset_password", %{"password" => password, "confirm_password" => cp}, socket) do
    if password != cp do
      {:noreply, assign(socket, error: "Passwords do not match")}
    else
      %{username: username, phrase: phrase} = socket.assigns
      repo = Application.get_env(:y_core, :repositories)[:user]
      
      case YCore.Accounts.PasswordResetService.reset(username, phrase, password, repo) do
        {:ok, _user} ->
          {:noreply, assign(socket, success: true, error: nil)}
        {:error, :invalid_credentials} ->
          {:noreply, assign(socket, error: "Identity verification failed. Please start over.", step: :verify)}
        {:error, :invalid_password} ->
          {:noreply, assign(socket, error: "Password does not meet security requirements")}
        {:error, _} ->
          {:noreply, assign(socket, error: "Something went wrong. Please try again.")}
      end
    end
  end
end
