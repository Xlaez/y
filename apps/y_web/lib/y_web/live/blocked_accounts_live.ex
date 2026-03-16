defmodule YWeb.BlockedAccountsLive do
  use YWeb, :live_view

  @block_repo YRepo.Repositories.BlockRepository

  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_user
    users = @block_repo.list_blocked(current_user.id)

    {:ok,
     socket
     |> assign(:page_title, "Blocked accounts")
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

  def handle_event("unblock", %{"id" => id}, socket) do
    case YCore.Social.BlockService.unblock(socket.assigns.current_user.id, id, @block_repo) do
      :ok ->
        users = @block_repo.list_blocked(socket.assigns.current_user.id)

        {:noreply,
         socket
         |> assign(:users, users)
         |> assign(:active_menu_user_id, nil)
         |> put_flash(:info, "Account unblocked")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Could not unblock user")}
    end
  end
end
