defmodule YWeb.MutedAccountsLive do
  use YWeb, :live_view

  @mute_repo YRepo.Repositories.MuteRepository

  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_user
    users = @mute_repo.list_muted(current_user.id)

    {:ok,
     socket
     |> assign(:page_title, "Muted accounts")
     |> assign(:active_tab, :settings)
     |> assign(:users, users)
     |> assign(:active_menu_user_id, nil)}
  end

  def handle_event("open_menu", %{"id" => id}, socket) do
    {:noreply, assign(socket, :active_menu_user_id, id)}
  end

  def handle_event("close_menu", _, socket) do
    {:noreply, assign(socket, :active_menu_user_id, nil)}
  end

  def handle_event("unmute", %{"id" => id}, socket) do
    case YCore.Social.MuteService.unmute(socket.assigns.current_user.id, id, @mute_repo) do
      :ok ->
        users = @mute_repo.list_muted(socket.assigns.current_user.id)

        {:noreply,
         socket
         |> assign(:users, users)
         |> assign(:active_menu_user_id, nil)
         |> put_flash(:info, "Account unmuted")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Could not unmute user")}
    end
  end
end
