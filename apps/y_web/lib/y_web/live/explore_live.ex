defmodule YWeb.ExploreLive do
  use YWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(active_tab: :explore)
     |> assign(hashtags: YWeb.DummyData.trending_hashtags())
     |> assign(search_query: "")
     |> assign(results: %{users: [], takes: []}),
     layout: {YWeb.Layouts, :authenticated}}
  end

  def handle_event("search", %{"query" => ""}, socket) do
    {:noreply, assign(socket, search_query: "", results: %{users: [], takes: []})}
  end

  def handle_event("search", %{"query" => query}, socket) do
    # Dummy search logic
    results = %{
      users: Enum.take(YWeb.DummyData.users(), 3),
      takes: Enum.take(YWeb.DummyData.takes(), 3)
    }
    {:noreply, assign(socket, search_query: query, results: results)}
  end
end
