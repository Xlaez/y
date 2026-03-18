defmodule YWeb.ConnectionsLive do
  use YWeb, :live_view
  alias YRepo.Repositories.{UserRepository, FollowRepository, NotificationRepository}
  alias YCore.Social.FollowService

  def mount(%{"username" => username}, _session, socket) do
    case UserRepository.get_by_username(username) do
      {:ok, user} ->
        {:ok,
         socket
         |> assign(:user, user)
         |> assign(:followers, [])
         |> assign(:following_list, []),
         layout: {YWeb.Layouts, :authenticated}}

      {:error, :not_found} ->
        {:ok, push_navigate(socket, to: "/"), layout: {YWeb.Layouts, :authenticated}}
    end
  end

  def handle_params(_params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action)}
  end

  defp apply_action(socket, :followers) do
    user_id = socket.assigns.user.id
    follower_ids = FollowRepository.list_followers(user_id)
    followers = UserRepository.list_by_ids(follower_ids) |> enrich_users(socket)
    assign(socket, followers: followers)
  end

  defp apply_action(socket, :following) do
    user_id = socket.assigns.user.id
    following_ids = FollowRepository.list_following(user_id)
    following_list = UserRepository.list_by_ids(following_ids) |> enrich_users(socket)
    assign(socket, following_list: following_list)
  end

  defp enrich_users(users, socket) do
    viewer_id = (socket.assigns[:current_user] && socket.assigns.current_user.id) || nil
    
    Enum.map(users, fn user ->
      is_following = if viewer_id, do: FollowRepository.following?(viewer_id, user.id), else: false
      Map.put(user, :is_following, is_following)
    end)
  end

  def handle_event("toggle_follow", %{"id" => id}, socket) do
    if current_user = socket.assigns.current_user do
      case FollowRepository.following?(current_user.id, id) do
        true ->
          FollowService.unfollow(current_user.id, id, FollowRepository)
          {:noreply, refresh_lists(socket)}
        false ->
          FollowService.follow(current_user.id, id, FollowRepository, NotificationRepository)
          {:noreply, refresh_lists(socket)}
      end
    else
      {:noreply, push_navigate(socket, to: "/login")}
    end
  end

  defp refresh_lists(socket) do
    apply_action(socket, socket.assigns.live_action)
  end
end
