defmodule YRepo.Repositories.FollowRepository do
  @behaviour YCore.Social.FollowRepository

  import Ecto.Query
  alias YRepo.Repo
  alias YRepo.Schemas.Follow
  alias YCore.Social.Follow, as: DomainFollow

  @impl true
  def follow(follower_id, followee_id) do
    %Follow{}
    |> Follow.changeset(%{follower_id: follower_id, followee_id: followee_id})
    |> Repo.insert()
    |> case do
      {:ok, schema} -> {:ok, to_domain(schema)}
      {:error, %Ecto.Changeset{errors: errors}} ->
        if Keyword.has_key?(errors, :follower_id) || has_unique_error?(errors) do
          {:error, :already_following}
        else
          {:error, errors}
        end
    end
  end

  @impl true
  def unfollow(follower_id, followee_id) do
    query = from f in Follow,
      where: f.follower_id == ^follower_id and f.followee_id == ^followee_id

    case Repo.delete_all(query) do
      {0, _} -> {:error, :not_following}
      {_, _} -> :ok
    end
  end

  @impl true
  def following?(follower_id, followee_id) do
    from(f in Follow,
      where: f.follower_id == ^follower_id and f.followee_id == ^followee_id
    )
    |> Repo.exists?()
  end

  @impl true
  def follower_count(user_id) do
    from(f in Follow, where: f.followee_id == ^user_id)
    |> Repo.aggregate(:count)
  end

  @impl true
  def following_count(user_id) do
    from(f in Follow, where: f.follower_id == ^user_id)
    |> Repo.aggregate(:count)
  end

  @impl true
  def list_followers(user_id) do
    from(f in Follow,
      where: f.followee_id == ^user_id,
      select: f.follower_id
    )
    |> Repo.all()
  end

  @impl true
  def list_following(user_id) do
    from(f in Follow,
      where: f.follower_id == ^user_id,
      select: f.followee_id
    )
    |> Repo.all()
  end

  @impl true
  def suggestions(user_id, blocked_ids, opts \\ []) do
    limit = Keyword.get(opts, :limit, 10)
    
    # Handle empty blocked_ids to avoid invalid SQL for 'not in'
    blocked_ids = if blocked_ids == [], do: ["00000000-0000-0000-0000-000000000000"], else: blocked_ids

    query = from f1 in Follow,
      join: f2 in Follow, on: f2.follower_id == f1.followee_id,
      where: f1.follower_id == ^user_id,
      where: f2.followee_id != ^user_id,
      where: f2.followee_id not in ^blocked_ids,
      where: f2.followee_id not in subquery(
        from f3 in Follow,
        where: f3.follower_id == ^user_id,
        select: f3.followee_id
      ),
      group_by: f2.followee_id,
      order_by: [desc: count(f2.followee_id)],
      limit: ^limit,
      select: %{
        user_id: f2.followee_id,
        mutual_count: count(f2.followee_id)
      }

    Repo.all(query)
  end

  @impl true
  def invalidate_recommendations(user_id) do
    YRepo.Cache.Recommendations.invalidate(user_id)
  end

  defp has_unique_error?(errors) do
    Enum.any?(errors, fn {_field, {_msg, opts}} ->
      opts[:constraint] == :unique
    end)
  rescue
    _ -> false
  end

  defp to_domain(schema) do
    %DomainFollow{
      id: schema.id,
      follower_id: schema.follower_id,
      followee_id: schema.followee_id,
      inserted_at: schema.inserted_at
    }
  end
end
