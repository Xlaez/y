defmodule YCore.Social.MuteService do
  alias YCore.Social.Mute

  @spec mute(String.t(), String.t(), module()) ::
          {:ok, Mute.t()} | {:error, :cannot_mute_self} | {:error, :already_muted} | {:error, term()}
  def mute(muter_id, muted_id, _repo) when muter_id == muted_id,
    do: {:error, :cannot_mute_self}

  def mute(muter_id, muted_id, repo) do
    repo.mute(muter_id, muted_id)
  end

  @spec unmute(String.t(), String.t(), module()) :: :ok | {:error, :not_muted}
  def unmute(muter_id, muted_id, repo) do
    repo.unmute(muter_id, muted_id)
  end
end
