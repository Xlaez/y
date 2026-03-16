defmodule YWeb.ConnectionsLive do
  use YWeb, :live_view

  def mount(%{"username" => username}, _session, socket) do
    # Find user by username in dummy data
    user = 
      Enum.find(YWeb.DummyData.users(), fn u -> u.username == username end) || 
      Enum.at(YWeb.DummyData.users(), 0)

    {:ok,
     socket
     |> assign(:active_tab, :profile)
     |> assign(:user, user)
     |> assign(:followers, YWeb.DummyData.followers(user.id))
     |> assign(:following_list, YWeb.DummyData.following(user.id)),
     layout: {YWeb.Layouts, :authenticated}}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  def handle_event("toggle_follow", %{"id" => _id}, socket) do
    # Currently just toggles a visual state in the lists if we were tracking it per-user.
    # For now, just a dummy event.
    {:noreply, put_flash(socket, :info, "Action updated")}
  end
end
