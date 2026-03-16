defmodule YCore.Social.BlockService do
  alias YCore.Social.Block

  @spec block(String.t(), String.t(), module(), module()) ::
          {:ok, Block.t()} | {:error, :cannot_block_self} | {:error, :already_blocked} | {:error, term()}
  def block(blocker_id, blocked_id, _block_repo, _follow_repo) when blocker_id == blocked_id,
    do: {:error, :cannot_block_self}

  def block(blocker_id, blocked_id, block_repo, follow_repo) do
    follow_repo.unfollow(blocker_id, blocked_id)
    follow_repo.unfollow(blocked_id, blocker_id)
    block_repo.block(blocker_id, blocked_id)
  end

  @spec unblock(String.t(), String.t(), module()) :: :ok | {:error, :not_blocked}
  def unblock(blocker_id, blocked_id, block_repo) do
    block_repo.unblock(blocker_id, blocked_id)
  end
end
