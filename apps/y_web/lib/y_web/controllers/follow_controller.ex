defmodule YWeb.FollowController do
  use YWeb, :controller

  alias YCore.Social.FollowService
  alias YRepo.Repositories.FollowRepository

  action_fallback YWeb.FallbackController

  def create(conn, %{"followee_id" => followee_id}) do
    current_user = conn.assigns.current_user

    case FollowService.follow(current_user.id, followee_id, FollowRepository, YRepo.Repositories.UserRepository, YRepo.Repositories.NotificationRepository) do
      {:ok, _follow} ->
        conn
        |> put_status(:created)
        |> json(%{status: "ok"})

      {:error, :cannot_follow_self} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "cannot_follow_self"})

      {:error, :already_following} ->
        conn
        |> put_status(:ok)
        |> json(%{status: "already_following"})

      {:error, _} ->
        {:error, :internal_server_error}
    end
  end

  def delete(conn, %{"followee_id" => followee_id}) do
    current_user = conn.assigns.current_user

    case FollowService.unfollow(current_user.id, followee_id, FollowRepository) do
      :ok ->
        send_resp(conn, :no_content, "")

      _ ->
        {:error, :internal_server_error}
    end
  end
end
