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
      opinion_repo: _opinion_repo,
      retake_repo: retake_repo
    } = repos

    # Get followees (including self)
    following_ids = follow_repo.list_following(user_id)
    target_ids = if following_ids == [], do: :all, else: [user_id | following_ids]

    # Fetch takes and retakes
    takes = take_repo.list_for_feed(target_ids, opts)
    retakes = retake_repo.list_for_users(target_ids, opts)

    # Batch fetch all necessary data
    all_take_ids = Enum.map(takes, & &1.id) ++ Enum.map(retakes, & &1.original_take_id)
    |> Enum.uniq()

    # Fetch original takes for retakes
    referenced_takes = take_repo.list_by_ids(all_take_ids) |> Map.new(& {&1.id, &1})

    user_ids = (Enum.map(takes, & &1.user_id) ++ 
                Enum.map(retakes, & &1.user_id) ++ 
                Enum.map(Map.values(referenced_takes), & &1.user_id))
               |> Enum.uniq()

    users_map = user_repo.list_by_ids(user_ids) |> Map.new(& {&1.id, &1})
    agreed_ids = agree_repo.list_agreed_ids(user_id, :take, all_take_ids) |> MapSet.new()
    agree_counts = agree_repo.count_batch(:take, all_take_ids)
    bookmarked_ids = bookmark_repo.list_for_user(user_id, target_type: :take)
                     |> Enum.map(& &1.target_id)
                     |> MapSet.new()
    retook_ids = retake_repo.list_retook_ids(user_id, all_take_ids) |> MapSet.new()

    # Assemble feed items using precomputed counts from the take schema
    # and batch-fetched agree counts to avoid N+1 queries
    take_items = Enum.map(takes, fn take ->
      %{
        type: :take,
        id: take.id,
        timestamp: take.inserted_at,
        take: take,
        author: Map.get(users_map, take.user_id),
        agree_count: Map.get(agree_counts, take.id, 0),
        retake_count: take.retake_count,
        opinion_count: take.opinion_count,
        viewer_agreed: MapSet.member?(agreed_ids, take.id),
        viewer_bookmarked: MapSet.member?(bookmarked_ids, take.id),
        viewer_retook: MapSet.member?(retook_ids, take.id)
      }
    end)

    retake_items =
      retakes
      |> Enum.map(fn retake ->
        case Map.get(referenced_takes, retake.original_take_id) do
          nil -> nil
          original_take ->
            %{
              type: :retake,
              id: retake.id,
              timestamp: retake.inserted_at,
              take: original_take,
              author: Map.get(users_map, original_take.user_id),
              retaker: Map.get(users_map, retake.user_id),
              comment: retake.comment,
              agree_count: Map.get(agree_counts, original_take.id, 0),
              retake_count: original_take.retake_count,
              opinion_count: original_take.opinion_count,
              viewer_agreed: MapSet.member?(agreed_ids, original_take.id),
              viewer_bookmarked: MapSet.member?(bookmarked_ids, original_take.id),
              viewer_retook: MapSet.member?(retook_ids, original_take.id)
            }
        end
      end)
      |> Enum.reject(&is_nil/1)

    (take_items ++ retake_items)
    |> Enum.sort_by(& &1.timestamp, {:desc, DateTime})
    |> Enum.take(Keyword.get(opts, :limit, 20))
    # Note: Retakes interspersing as per requirements will be added as Step 4 progress continues
  end
end
