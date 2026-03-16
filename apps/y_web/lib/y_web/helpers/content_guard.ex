defmodule YWeb.Helpers.ContentGuard do
  @spec can_view?(String.t() | nil, map(), module()) :: boolean()
  def can_view?(nil, %{is_locked: true}, _follow_repo), do: false
  def can_view?(nil, _target_user, _follow_repo), do: true
  def can_view?(viewer_id, %{id: user_id}, _follow_repo) when viewer_id == user_id, do: true
  def can_view?(_viewer_id, %{is_locked: false}, _follow_repo), do: true

  def can_view?(viewer_id, %{id: user_id, is_locked: true}, follow_repo) do
    follow_repo.following?(viewer_id, user_id)
  end

  @spec mutual_block?(String.t(), String.t(), module()) :: boolean()
  def mutual_block?(user_id_a, user_id_b, block_repo) do
    block_repo.blocked?(user_id_a, user_id_b) || block_repo.blocked?(user_id_b, user_id_a)
  end
end
