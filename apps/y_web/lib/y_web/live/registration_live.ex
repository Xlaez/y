defmodule YWeb.RegistrationLive do
  use YWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, 
      username: "", 
      password: "",
      confirm_password: "",
      show_password: false,
      show_confirm_password: false,
      error: nil,
      trigger_submit: false
    )}
  end

  def handle_event("validate", %{"username" => username, "password" => password, "confirm_password" => cp}, socket) do
    {:noreply, assign(socket, username: username, password: password, confirm_password: cp)}
  end

  def handle_event("toggle_password", %{"field" => "password"}, socket) do
    {:noreply, assign(socket, show_password: !socket.assigns.show_password)}
  end

  def handle_event("toggle_password", %{"field" => "confirm"}, socket) do
    {:noreply, assign(socket, show_confirm_password: !socket.assigns.show_confirm_password)}
  end

  def handle_event("submit", _params, socket) do
    %{username: username, password: password, confirm_password: cp} = socket.assigns
    
    if password != cp do
      {:noreply, assign(socket, error: "Passwords do not match")}
    else
      repo = Application.get_env(:y_core, :repositories)[:user]
      case YCore.Accounts.RegistrationService.register(%{username: username, password: password}, repo) do
        {:ok, %{user: user, seed_phrase: words}} ->
          {:noreply, assign(socket, 
            trigger_submit: true, 
            user_id: user.id, 
            words: Enum.join(words, "-"),
            error: nil
          )}
        {:error, :username_taken} ->
          {:noreply, assign(socket, error: "Username is already taken")}
        {:error, reason} ->
          {:noreply, assign(socket, error: msg_error(reason))}
      end
    end
  end

  defp msg_error(reason) when is_atom(reason), do: String.capitalize(to_string(reason))
  defp msg_error(_), do: "Something went wrong"
end
