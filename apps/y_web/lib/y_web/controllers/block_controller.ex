defmodule YWeb.BlockController do
  use YWeb, :controller

  alias YCore.Social.BlockService
  alias YRepo.Repositories.BlockRepository
  alias YRepo.Repositories.FollowRepository

  action_fallback YWeb.FallbackController

  def create(conn, %{"blocked_id" => blocked_id}) do
    current_user = conn.assigns.current_user

    case BlockService.block(current_user.id, blocked_id, BlockRepository, FollowRepository) do
      {:ok, _block} ->
        conn
        |> put_status(:created)
        |> json(%{status: "ok"})

      {:error, :cannot_block_self} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "cannot_block_self"})

      {:error, :already_blocked} ->
        conn
        |> put_status(:ok)
        |> json(%{status: "already_blocked"})

      {:error, _} ->
        {:error, :internal_server_error}
    end
  end

  def delete(conn, %{"blocked_id" => blocked_id}) do
    current_user = conn.assigns.current_user

    case BlockService.unblock(current_user.id, blocked_id, BlockRepository) do
      :ok ->
        send_resp(conn, :no_content, "")

      _ ->
        {:error, :internal_server_error}
    end
  end
end
