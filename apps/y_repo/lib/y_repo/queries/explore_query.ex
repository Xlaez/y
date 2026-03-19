defmodule YRepo.Queries.ExploreQuery do
  @moduledoc """
  Queries for the Explore page, including hashtag extraction and user search.
  """
  import Ecto.Query

  alias YRepo.Schemas.Take
  alias YRepo.Schemas.User

  @doc """
  Returns trending hashtags by extracting them from recent takes.
  """
  def trending_hashtags(limit \\ 10) do
    since = DateTime.add(DateTime.utc_now(), -24, :hour)

    # Subquery to extract hashtags from recent takes
    # Each regexp_matches('... #foo ... #bar', '#\w+', 'g') returns rows of {String.t()}
    # We unnest them to get individual hashtag strings.
    hashtags_subquery = 
      from t in Take,
        where: t.inserted_at > ^since,
        select: %{tag: fragment("unnest(regexp_matches(?, '#[[:alnum:]_]+', 'g'))", t.body)}

    from h in subquery(hashtags_subquery),
      group_by: h.tag,
      order_by: [desc: count(h.tag)],
      limit: ^limit,
      select: %{name: h.tag, count: count(h.tag)}
  end

  @doc """
  Searches for users by username or display name.
  """
  def search_users(query, limit \\ 20) do
    search_term = "%#{query}%"

    from u in User,
      where: ilike(u.username, ^search_term) or ilike(u.display_name, ^search_term),
      limit: ^limit,
      order_by: [asc: u.username]
  end

  @doc """
  Searches for takes containing a specific keyword or hashtag.
  """
  def search_takes(query, limit \\ 20) do
    search_term = "%#{query}%"

    from t in Take,
      where: ilike(t.body, ^search_term),
      order_by: [desc: t.inserted_at],
      limit: ^limit,
      preload: [:user]
  end
end
