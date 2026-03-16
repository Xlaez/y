defmodule YCore.Content.TakeService do
  @moduledoc """
  Service for managing Takes.
  """
  alias YCore.Content.TakeBody

  @spec post(String.t(), String.t(), module()) ::
          {:ok, YCore.Content.Take.t()} | {:error, term()}
  def post(user_id, body, take_repo) do
    with {:ok, trimmed_body} <- TakeBody.new(body) do
      take_repo.create(%{
        user_id: user_id,
        body: trimmed_body
      })
    end
  end

  @spec delete(String.t(), String.t(), module()) ::
          :ok | {:error, :not_found | :forbidden}
  def delete(take_id, requesting_user_id, take_repo) do
    take_repo.delete(take_id, requesting_user_id)
  end
end
