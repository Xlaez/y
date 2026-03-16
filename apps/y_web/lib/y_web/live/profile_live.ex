defmodule YWeb.ProfileLive do
  use YWeb, :live_view

  @user_repo YRepo.Repositories.UserRepository
  @follow_repo YRepo.Repositories.FollowRepository
  @block_repo YRepo.Repositories.BlockRepository

  def mount(%{"username" => username}, _session, socket) do
    current_user = socket.assigns.current_user
    viewer_id = if current_user, do: current_user.id, else: nil

    case YCore.Accounts.ProfileService.get_profile(
           username,
           viewer_id,
           @user_repo,
           @follow_repo,
           @block_repo
         ) do
      {:ok, profile} ->
        # For now, we still use dummy takes until they are implemented
        takes = Enum.take(YWeb.DummyData.takes(), 5)

        {:ok,
         socket
         |> assign(active_tab: :profile)
         |> assign(profile: profile)
         |> assign(takes: takes), layout: {YWeb.Layouts, :authenticated}}

      {:error, :not_found} ->
        {:ok, push_navigate(socket, to: "/home")}
    end
  end

  def handle_event("follow", _, socket) do
    if current_user = socket.assigns.current_user do
      case YCore.Social.FollowService.follow(
             current_user.id,
             socket.assigns.profile.user.id,
             @follow_repo
           ) do
        {:ok, _} ->
          {:noreply, update_profile(socket)}

        {:error, _} ->
          {:noreply, put_flash(socket, :error, "Could not follow user")}
      end
    else
      {:noreply, push_navigate(socket, to: "/login")}
    end
  end

  def handle_event("unfollow", _, socket) do
    if current_user = socket.assigns.current_user do
      case YCore.Social.FollowService.unfollow(
             current_user.id,
             socket.assigns.profile.user.id,
             @follow_repo
           ) do
        :ok ->
          {:noreply, update_profile(socket)}

        {:error, _} ->
          {:noreply, put_flash(socket, :error, "Could not unfollow user")}
      end
    else
      {:noreply, push_navigate(socket, to: "/login")}
    end
  end

  defp update_profile(socket) do
    username = socket.assigns.profile.user.username
    viewer_id = socket.assigns.current_user.id

    case YCore.Accounts.ProfileService.get_profile(
           username,
           viewer_id,
           @user_repo,
           @follow_repo,
           @block_repo
         ) do
      {:ok, profile} ->
        assign(socket, profile: profile)

      _ ->
        socket
    end
  end
end
