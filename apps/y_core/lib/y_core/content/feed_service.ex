defmodule YCore.Content.FeedService do
  @moduledoc """
  Service for building the application feed.
  """

  @spec build_feed(String.t(), keyword(), map()) :: [map()]
  def build_feed(user_id, opts, repos) do
    %{
      take_repo: take_repo,
      follow_repo: follow_repo,
      # mute_repo: mute_repo,
      # block_repo: block_repo,
      agree_repo: agree_repo,
      bookmark_repo: bookmark_repo,
      user_repo: user_repo,
      opinion_repo: opinion_repo,
      retake_repo: retake_repo
    } = repos

    # 1. Get followees (including self)
    following_ids = follow_repo.list_following(user_id)
    target_ids = [user_id | following_ids]

    # 2. Fetch takes (scored by SQL)
    takes = take_repo.list_for_feed(target_ids, opts)
    
    # 3. Batch fetch all necessary data
    all_take_ids = Enum.map(takes, & &1.id)
    user_ids = Enum.map(takes, & &1.user_id) |> Enum.uniq()
    
    users_map = user_repo.list_by_ids(user_ids) |> Map.new(& {&1.id, &1})
    agreed_ids = agree_repo.list_agreed_ids(user_id, :take, all_take_ids) |> MapSet.new()
    bookmarked_ids = bookmark_repo.list_for_user(user_id, target_type: :take) 
                     |> Enum.map(& &1.target_id) 
                     |> MapSet.new()

    # 4. Assemble feed items
    takes
    |> Enum.map(fn take ->
      %{
        type: :take,
        take: take,
        author: Map.get(users_map, take.user_id),
        agree_count: agree_repo.count(:take, take.id),
        retake_count: retake_repo.count_for_take(take.id),
        opinion_count: opinion_repo.count_for_take(take.id),
        viewer_agreed: MapSet.member?(agreed_ids, take.id),
        viewer_bookmarked: MapSet.member?(bookmarked_ids, take.id)
      }
    end)
    # Note: Retakes interspersing as per requirements will be added as Step 4 progress continues
  end
end
