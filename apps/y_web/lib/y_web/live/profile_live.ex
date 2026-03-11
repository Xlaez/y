defmodule YWeb.ProfileLive do
  use YWeb, :live_view

  def mount(%{"username" => username}, _session, socket) do
    # Find user by username in dummy data
    user = 
      Enum.find(YWeb.DummyData.users(), fn u -> u.username == username end) || 
      Enum.at(YWeb.DummyData.users(), 0)

    takes = Enum.filter(YWeb.DummyData.takes(), fn t -> t.user.id == user.id end)
    
    # If user has no takes in dummy data, just show first 5 for variety
    takes = if Enum.empty?(takes), do: Enum.take(YWeb.DummyData.takes(), 5), else: takes

    {:ok,
     socket
     |> assign(active_tab: :profile)
     |> assign(user: user)
     |> assign(takes: takes)
     |> assign(following: false),
     layout: {YWeb.Layouts, :authenticated}}
  end

  def handle_event("toggle_follow", _, socket) do
    {:noreply, assign(socket, following: !socket.assigns.following)}
  end
end
