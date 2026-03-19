defmodule YWeb.ExploreLive do
  use YWeb, :live_view

  alias YRepo.Repositories.{UserRepository, TakeRepository}
  alias YRepo.Queries.ExploreQuery
  alias YRepo.Repo

  def mount(_params, _session, socket) do
    trending = Repo.all(ExploreQuery.trending_hashtags())

    {:ok,
     socket
     |> assign(active_tab: :explore)
     |> assign(hashtags: trending)
     |> assign(search_query: "")
     |> assign(results: %{users: [], takes: []}),
     layout: {YWeb.Layouts, :authenticated}}
  end

  def handle_event("search", %{"query" => ""}, socket) do
    {:noreply, assign(socket, search_query: "", results: %{users: [], takes: []})}
  end

  def handle_event("search", %{"query" => query}, socket) do
    # Real search logic using repositories for domain mapping
    users = UserRepository.search(query, limit: 10)
    takes = TakeRepository.search(query, limit: 10)

    results = %{
      users: users,
      takes: takes
    }
    {:noreply, assign(socket, search_query: query, results: results)}
  end
end
