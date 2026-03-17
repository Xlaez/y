defmodule YCore.Interactions.BookmarkService do
  @moduledoc """
  Service for managing and listing Bookmarks.
  """

  @spec list_bookmarks(String.t(), module(), module(), module(), module()) :: [map()]
  def list_bookmarks(user_id, bookmark_repo, take_repo, retake_repo, user_repo) do
    # 1. Fetch bookmark records
    bookmarks = bookmark_repo.list_for_user(user_id, [])
    
    # 2. Extract IDs by type
    take_ids = for b <- bookmarks, b.target_type == "take", do: b.target_id
    # retake_ids = for b <- bookmarks, b.target_type == "retake", do: b.target_id

    # 3. Batch fetch
    takes = take_repo.list_by_ids(take_ids) |> Map.new(& {&1.id, &1})
    
    # 4. Assemble
    bookmarks
    |> Enum.map(fn b ->
      case b.target_type do
        "take" ->
          take = Map.get(takes, b.target_id)
          author = if take, do: user_repo.get_by_id!(take.user_id), else: nil
          
          if take do
            %{
              type: :take,
              take: take,
              author: author,
              agree_count: 0,
              retake_count: 0,
              opinion_count: 0,
              viewer_agreed: false,
              viewer_bookmarked: true,
              viewer_retook: false,
              inserted_at: b.inserted_at # sorting by bookmark time
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
