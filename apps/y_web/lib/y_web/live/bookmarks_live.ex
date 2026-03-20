defmodule YWeb.BookmarksLive do
  use YWeb, :live_view
  use YWeb.Live.RecommendationEvents

  alias YCore.Interactions.BookmarkService
  alias YRepo.Repositories.{BookmarkRepository, TakeRepository, RetakeRepository, UserRepository}

  def mount(_params, _session, socket) do
    user_id = socket.assigns.current_user.id
    bookmarks = fetch_bookmarks(user_id)
    
    {:ok,
     socket
     |> assign(active_tab: :bookmarks)
     |> assign(feed: bookmarks),
     layout: {YWeb.Layouts, :authenticated}}
  end

  def handle_event("toggle_bookmark", %{"target_type" => type, "target_id" => id}, socket) do
    user_id = socket.assigns.current_user.id
    target_type = String.to_existing_atom(type)

    case BookmarkRepository.toggle(user_id, target_type, id) do
      {:ok, _} -> {:noreply, refresh_bookmarks(socket)}
      _ -> {:noreply, socket}
    end
  end

  def handle_event("navigate_to_take", %{"take_id" => id}, socket) do
    {:noreply, push_navigate(socket, to: ~p"/takes/#{id}")}
  end

  defp fetch_bookmarks(user_id) do
    BookmarkService.list_bookmarks(user_id, BookmarkRepository, TakeRepository, RetakeRepository, UserRepository)
  end

  defp refresh_bookmarks(socket) do
    assign(socket, feed: fetch_bookmarks(socket.assigns.current_user.id))
  end
end
