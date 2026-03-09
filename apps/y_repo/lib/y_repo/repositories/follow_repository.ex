defmodule YRepo.Repositories.FollowRepository do
  @behaviour YCore.Social.FollowRepository

  alias YRepo.Repo
  alias YRepo.Schemas.Follow
  alias YCore.Social.Follow, as: DomainFollow

  def create(params) do
    %Follow{}
    |> Follow.changeset(params)
    |> Repo.insert()
    |> case do
      {:ok, schema} -> {:ok, to_domain(schema)}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def delete(%DomainFollow{id: id}) do
    case Repo.get(Follow, id) do
      nil -> {:error, :not_found}
      schema ->
        Repo.delete(schema)
        :ok
    end
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
