defmodule YWeb.HomeLive do
  use YWeb, :live_view

  alias YCore.Content.TakeService
  alias YCore.Content.FeedService
  alias YRepo.Repositories.{TakeRepository, FollowRepository, AgreeRepository, BookmarkRepository, UserRepository, OpinionRepository, RetakeRepository, NotificationRepository}
  @notification_repo NotificationRepository

  def mount(_params, _session, socket) do
    if connected?(socket) do
      # Subscribe to updates could go here in a real app
    end

    current_user = socket.assigns.current_user
    feed = fetch_feed(current_user.id)

    {:ok,
     socket
     |> assign(active_tab: :home)
     |> assign(feed: feed)
     |> assign(compose_body: "")
     |> assign(compose_char_count: 0)
     |> assign(retake_modal: nil)
     |> assign(who_to_follow: []), # Real "Who to follow" logic would use UserRepository.list_suggested
     layout: {YWeb.Layouts, :authenticated}}
  end

  def handle_event("validate_compose", %{"body" => body}, socket) do
    {:noreply, assign(socket, compose_body: body, compose_char_count: String.length(body))}
  end

  def handle_event("post_take", %{"body" => body}, socket) do
    user_id = socket.assigns.current_user.id

    case TakeService.post(user_id, body, TakeRepository) do
      {:ok, _take} ->
        {:noreply,
         socket
         |> put_flash(:info, "Your take was shared!")
         |> assign(compose_body: "", compose_char_count: 0)
         |> refresh_feed()}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Could not share take: #{reason}")}
    end
  end

  def handle_event("toggle_agree", %{"target_type" => type, "target_id" => id}, socket) do
    user_id = socket.assigns.current_user.id
    target_type = String.to_existing_atom(type)

    case AgreeRepository.toggle(user_id, target_type, id, @notification_repo) do
      {:ok, _} -> {:noreply, refresh_feed(socket)}
      _ -> {:noreply, socket}
    end
  end

  def handle_event("toggle_bookmark", %{"target_type" => type, "target_id" => id}, socket) do
    user_id = socket.assigns.current_user.id
    target_type = String.to_existing_atom(type)

    case BookmarkRepository.toggle(user_id, target_type, id) do
      {:ok, _} -> {:noreply, refresh_feed(socket)}
      _ -> {:noreply, socket}
    end
  end

  def handle_event("navigate_to_take", %{"take_id" => id}, socket) do
    {:noreply, push_navigate(socket, to: ~p"/takes/#{id}")}
  end

  defp fetch_feed(user_id) do
    repos = %{
      take_repo: TakeRepository,
      follow_repo: FollowRepository,
      agree_repo: AgreeRepository,
      bookmark_repo: BookmarkRepository,
      user_repo: UserRepository,
      opinion_repo: OpinionRepository,
      retake_repo: RetakeRepository
    }
    FeedService.build_feed(user_id, [limit: 20], repos)
  end

  defp refresh_feed(socket) do
    assign(socket, feed: fetch_feed(socket.assigns.current_user.id))
  end
end
