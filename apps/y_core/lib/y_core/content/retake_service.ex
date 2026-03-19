defmodule YCore.Content.RetakeService do
  @moduledoc """
  Service for managing Retakes.
  """
  alias YCore.Content.TakeBody

  @spec retake(String.t(), String.t(), String.t() | nil, module(), module(), module()) ::
          {:ok, YCore.Content.Retake.t()} | {:error, :already_retook | :cannot_retake_own | term()}
  def retake(user_id, original_take_id, comment, retake_repo, take_repo, notification_repo) do
    with {:ok, take} <- get_original_take(original_take_id, take_repo),
         :ok <- check_not_own_take(user_id, take),
         {:ok, valid_comment} <- validate_comment(comment),
         :ok <- check_not_already_retook(user_id, original_take_id, retake_repo) do
      retake_repo.create(%{
        user_id: user_id,
        original_take_id: original_take_id,
        comment: valid_comment
      })
      |> case do
        {:ok, retake} ->
          take_repo.increment_retake_count(original_take_id)
          Task.start(fn ->
            YCore.Notifications.NotificationService.notify_retook(
              user_id, take.user_id, take.id, retake.id, notification_repo
            )
          end)
          {:ok, retake}

        error -> error
      end
    end
  end

  @spec toggle_retake(String.t(), String.t(), module(), module(), module()) ::
          {:ok, :retook | :removed} | {:error, term()}
  def toggle_retake(user_id, original_take_id, retake_repo, take_repo, notification_repo) do
    case retake_repo.get_by_user_and_take(user_id, original_take_id) do
      {:ok, retake} ->
        # Already retook, so we undo it
        with :ok <- retake_repo.delete(retake.id, user_id) do
          take_repo.decrement_retake_count(original_take_id)
          {:ok, :removed}
        end

      {:error, :not_found} ->
        # Not retook yet, so we perform simple retake
        case retake(user_id, original_take_id, nil, retake_repo, take_repo, notification_repo) do
          {:ok, _} -> {:ok, :retook}
          error -> error
        end
    end
  end

  @spec delete(String.t(), String.t(), module(), module()) ::
          :ok | {:error, :not_found | :forbidden}
  def delete(retake_id, requesting_user_id, retake_repo, take_repo) do
    case retake_repo.get_by_id(retake_id) do
      {:ok, retake} ->
        with :ok <- retake_repo.delete(retake_id, requesting_user_id) do
          take_repo.decrement_retake_count(retake.original_take_id)
          :ok
        end
      error -> error
    end
  end

  defp get_original_take(take_id, take_repo) do
    case take_repo.get_by_id(take_id) do
      {:ok, take} -> {:ok, take}
      {:error, :not_found} -> {:error, :not_found}
    end
  end

  defp check_not_own_take(user_id, %{user_id: take_user_id}) when user_id == take_user_id, do: {:error, :cannot_retake_own}
  defp check_not_own_take(_user_id, _take), do: :ok

  defp validate_comment(nil), do: {:ok, nil}
  defp validate_comment(""), do: {:ok, nil}
  defp validate_comment(comment) do
    case TakeBody.new(comment) do
      {:ok, trimmed} -> {:ok, trimmed}
      {:error, reason} -> {:error, reason}
    end
  end

  defp check_not_already_retook(user_id, take_id, retake_repo) do
    if retake_repo.already_retook?(user_id, take_id) do
      {:error, :already_retook}
    else
      :ok
    end
  end
end
