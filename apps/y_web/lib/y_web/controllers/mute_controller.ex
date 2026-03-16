defmodule YWeb.MuteController do
  use YWeb, :controller

  alias YCore.Social.MuteService
  alias YRepo.Repositories.MuteRepository

  action_fallback YWeb.FallbackController

  def create(conn, %{"muted_id" => muted_id}) do
    current_user = conn.assigns.current_user

    case MuteService.mute(current_user.id, muted_id, MuteRepository) do
      {:ok, _mute} ->
        conn
        |> put_status(:created)
        |> json(%{status: "ok"})

      {:error, :cannot_mute_self} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "cannot_mute_self"})

      {:error, :already_muted} ->
        conn
        |> put_status(:ok)
        |> json(%{status: "already_muted"})

      {:error, _} ->
        {:error, :internal_server_error}
    end
  end

  def delete(conn, %{"muted_id" => muted_id}) do
    current_user = conn.assigns.current_user

    case MuteService.unmute(current_user.id, muted_id, MuteRepository) do
      :ok ->
        send_resp(conn, :no_content, "")

      _ ->
        {:error, :internal_server_error}
    end
  end
end
