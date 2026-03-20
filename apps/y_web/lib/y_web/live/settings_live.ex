defmodule YWeb.SettingsLive do
  use YWeb, :live_view
  use YWeb.Live.RecommendationEvents

  @user_repo YRepo.Repositories.UserRepository
  @session_repo YRepo.Repositories.SessionRepository
  @block_repo YRepo.Repositories.BlockRepository
  @mute_repo YRepo.Repositories.MuteRepository

  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_user

    blocked_users = @block_repo.list_blocked(current_user.id)
    muted_users = @mute_repo.list_muted(current_user.id)

    {:ok,
     socket
     |> assign(active_tab: :settings)
     |> assign(blocked_users: blocked_users)
     |> assign(muted_users: muted_users)
     |> assign(show_password_form: false)
     |> assign(show_bitmoji_modal: false)
     |> assign(show_delete_modal: false)
     |> assign(password_error: nil)
     |> assign(password_success: false)
     |> assign(bitmoji_error: nil)
     |> assign(colors: YCore.Accounts.SettingsService.permitted_colors()),
     layout: {YWeb.Layouts, :authenticated}}
  end

  def handle_event("toggle_password_form", _, socket) do
    {:noreply, 
     assign(socket, 
       show_password_form: !socket.assigns.show_password_form,
       password_error: nil,
       password_success: false
     )}
  end

  def handle_event("change_password", %{"current_password" => current, "new_password" => new}, socket) do
    case YCore.Accounts.SettingsService.change_password(
           socket.assigns.current_user.id,
           current,
           new,
           @user_repo
         ) do
      {:ok, user} ->
        {:noreply,
         socket
         |> assign(current_user: user, password_success: true, password_error: nil)
         |> put_flash(:info, "Password updated successfully!")}

      {:error, :invalid_current_password} ->
        {:noreply, assign(socket, password_error: "Current password is incorrect")}

      {:error, reason} when is_binary(reason) ->
        {:noreply, assign(socket, password_error: reason)}

      {:error, _} ->
        {:noreply, assign(socket, password_error: "Something went wrong")}
    end
  end

  def handle_event("open_bitmoji_modal", _, socket) do
    {:noreply, assign(socket, show_bitmoji_modal: true)}
  end

  def handle_event("close_modal", _, socket) do
    {:noreply, assign(socket, show_bitmoji_modal: false, show_delete_modal: false)}
  end

  def handle_event("select_color", %{"color" => color}, socket) do
    case YCore.Accounts.SettingsService.change_bitmoji(
           socket.assigns.current_user.id,
           color,
           @user_repo
         ) do
      {:ok, user} ->
        {:noreply,
         socket
         |> assign(current_user: user, show_bitmoji_modal: false)
         |> put_flash(:info, "Bitmoji updated!")}

      {:error, _} ->
        {:noreply,
         socket
         |> assign(bitmoji_error: "Could not update bitmoji")
         |> put_flash(:error, "Could not update bitmoji")}
    end
  end

  def handle_event("toggle_lock", _, socket) do
    case YCore.Accounts.SettingsService.toggle_lock(
           socket.assigns.current_user.id,
           @user_repo
         ) do
      {:ok, user} ->
        msg = if user.is_locked, do: "Account locked", else: "Account unlocked"

        {:noreply,
         socket
         |> assign(current_user: user)
         |> put_flash(:info, msg)}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Could not toggle lock")}
    end
  end

  def handle_event("unblock", %{"user_id" => user_id}, socket) do
    case YCore.Social.BlockService.unblock(
           socket.assigns.current_user.id,
           user_id,
           @block_repo
         ) do
      :ok ->
        blocked_users = @block_repo.list_blocked(socket.assigns.current_user.id)
        {:noreply, assign(socket, blocked_users: blocked_users)}

      _ ->
        {:noreply, put_flash(socket, :error, "Could not unblock user")}
    end
  end

  def handle_event("unmute", %{"user_id" => user_id}, socket) do
    case YCore.Social.MuteService.unmute(
           socket.assigns.current_user.id,
           user_id,
           @mute_repo
         ) do
      :ok ->
        muted_users = @mute_repo.list_muted(socket.assigns.current_user.id)
        {:noreply, assign(socket, muted_users: muted_users)}

      _ ->
        {:noreply, put_flash(socket, :error, "Could not unmute user")}
    end
  end

  def handle_event("open_delete_modal", _, socket) do
    {:noreply, assign(socket, show_delete_modal: true)}
  end

  def handle_event("confirm_delete", %{"password" => password}, socket) do
    case YCore.Accounts.SettingsService.delete_account(
           socket.assigns.current_user.id,
           password,
           @user_repo,
           @session_repo
         ) do
      :ok ->
        {:noreply,
         socket
         |> clear_flash()
         |> push_navigate(to: "/login")
         |> put_flash(:info, "Your account has been deleted")}

      {:error, :invalid_password} ->
        {:noreply, put_flash(socket, :error, "Incorrect password")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Could not delete account")}
    end
  end
end
