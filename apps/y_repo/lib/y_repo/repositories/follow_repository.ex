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
