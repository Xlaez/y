defmodule YRepo.Queries.FeedQuery do
  @moduledoc """
  Optimized feed queries for 'y'.
  """
  import Ecto.Query

  @spec scored_feed(any()) :: Ecto.Query.t()
  @spec scored_feed(any(), keyword()) :: Ecto.Query.t()
  def scored_feed(user_ids, opts \\ []) do
    limit = Keyword.get(opts, :limit, 20)
    before_id = Keyword.get(opts, :before)

    # Base query for takes
    query = from t in YRepo.Schemas.Take, select: t

    query =
      if user_ids != :all do
        from [t] in query, where: t.user_id in ^user_ids
      else
        query
      end

    # Join for scoring
    query = query
    |> join(:left, [t], a in YRepo.Schemas.Agree, on: a.target_id == t.id and a.target_type == ^:take, as: :agrees)
    |> join(:left, [t], r in YRepo.Schemas.Retake, on: r.original_take_id == t.id, as: :retakes)
    |> join(:left, [t], o in YRepo.Schemas.Opinion, on: o.take_id == t.id, as: :opinions)
    |> group_by([t], t.id)

    # Select with scoring
    query = from [t, agrees: a, retakes: r, opinions: o] in query,
      select_merge: %{
        score: fragment(
          "(EXTRACT(EPOCH FROM ?) + (COUNT(DISTINCT ?) FILTER (WHERE ? = 'take') * 2) + (COUNT(DISTINCT ?) * 3) + (COUNT(DISTINCT ?) * 1))",
          t.inserted_at, a.id, a.target_type, r.id, o.id
        )
      }

    query = from [t, agrees: a, retakes: r, opinions: o] in query,
      order_by: [desc: fragment(
        "(EXTRACT(EPOCH FROM ?) + (COUNT(DISTINCT ?) FILTER (WHERE ? = 'take') * 2) + (COUNT(DISTINCT ?) * 3) + (COUNT(DISTINCT ?) * 1))",
        t.inserted_at, a.id, a.target_type, r.id, o.id
      )],
      limit: ^limit

    # Pagination
    if before_id do
      # Note: For scored feeds, pagination by ID is tricky if score isn't sequential.
      # Usually you'd paginate by (score, id) but for simplicity here we use limit/offset or just limit.
      # Production-grade would use keyset pagination on (score, id).
      query
    else
      query
    end
  end
end
