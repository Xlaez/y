defmodule YCore.Interactions.BookmarkService do
  @moduledoc """
  Service for managing and listing Bookmarks.
  """

  @spec list_bookmarks(String.t(), module(), module(), module(), module()) :: [map()]
  def list_bookmarks(user_id, bookmark_repo, take_repo, retake_repo, user_repo) do
    # Fetch bookmark records
    bookmarks = bookmark_repo.list_for_user(user_id, [])

    # Extract IDs by type
    take_ids = for b <- bookmarks, b.target_type == :take, do: b.target_id

    # Batch fetch
    takes_map = take_repo.list_by_ids(take_ids) |> Map.new(& {&1.id, &1})

    user_ids = Map.values(takes_map) |> Enum.map(& &1.user_id) |> Enum.uniq()
    users_map = user_repo.list_by_ids(user_ids) |> Map.new(& {&1.id, &1})

    retook_ids = retake_repo.list_retook_ids(user_id, take_ids) |> MapSet.new()

    # Assemble
    bookmarks
    |> Enum.map(fn b ->
      case b.target_type do
        :take ->
          take = Map.get(takes_map, b.target_id)

          if take do
            %{
              type: :take,
              take: take,
              author: Map.get(users_map, take.user_id),
              agree_count: 0,
              retake_count: take.retake_count,
              opinion_count: take.opinion_count,
              viewer_agreed: false,
              viewer_bookmarked: true,
              viewer_retook: MapSet.member?(retook_ids, take.id),
              inserted_at: b.inserted_at
            }
          else
            nil
          end

        _ -> nil
      end
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.sort_by(& &1.inserted_at, {:desc, DateTime})
  end
end
