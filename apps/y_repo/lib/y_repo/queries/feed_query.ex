defmodule YRepo.Queries.FeedQuery do
  @moduledoc """
  Optimized feed queries for 'y'.
  Uses precomputed counts on the takes table to avoid expensive JOINs.
  """
  import Ecto.Query

  @spec scored_feed(any()) :: Ecto.Query.t()
  @spec scored_feed(any(), keyword()) :: Ecto.Query.t()
  def scored_feed(user_ids, opts \\ []) do
    limit = Keyword.get(opts, :limit, 20)
    before = Keyword.get(opts, :before)

    query = from t in YRepo.Schemas.Take, select: t

    query =
      if user_ids != :all do
        from [t] in query, where: t.user_id in ^user_ids
      else
        query
      end

    # Cursor-based pagination: fetch items older than the cursor timestamp
    query =
      if before do
        from t in query, where: t.inserted_at < ^before
      else
        query
      end

    # Use precomputed counts for scoring instead of expensive JOINs.
    # Score = epoch_seconds + retake_count * 3 + opinion_count * 1
    from t in query,
      order_by: [desc: fragment(
        "(EXTRACT(EPOCH FROM ?) + ? * 3 + ?)",
        t.inserted_at, t.retake_count, t.opinion_count
      )],
      limit: ^limit
  end
end
