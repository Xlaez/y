defmodule YWeb.BookmarksLive do
  use YWeb, :live_view

  def mount(_params, _session, socket) do
    # For testing empty state, you can set bookmarks to []
    bookmarks = Enum.take(YWeb.DummyData.takes(), 5)
    
    {:ok,
     socket
     |> assign(active_tab: :bookmarks)
     |> assign(bookmarks: bookmarks)
     |> assign(current_user: YWeb.DummyData.current_user()),
     layout: {YWeb.Layouts, :authenticated}}
  end
end
