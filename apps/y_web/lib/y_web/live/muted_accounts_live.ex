defmodule YWeb.MutedAccountsLive do
  use YWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Muted accounts")
     |> assign(:active_tab, :settings)
     |> assign(:users, YWeb.DummyData.muted_users())
     |> assign(:active_menu_user_id, nil)}
  end

  def handle_event("open_menu", %{"id" => id}, socket) do
    {:noreply, assign(socket, :active_menu_user_id, String.to_integer(id))}
  end

  def handle_event("close_menu", _, socket) do
    {:noreply, assign(socket, :active_menu_user_id, nil)}
  end

  def handle_event("unmute", %{"id" => id}, socket) do
    user_id = String.to_integer(id)
    updated_users = Enum.reject(socket.assigns.users, &(&1.id == user_id))
    
    {:noreply,
     socket
     |> assign(:users, updated_users)
     |> assign(:active_menu_user_id, nil)
     |> put_flash(:info, "Account unmuted")}
  end
end
