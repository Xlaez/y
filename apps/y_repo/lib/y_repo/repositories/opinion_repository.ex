defmodule YRepo.Repositories.OpinionRepository do
  @behaviour YCore.Content.OpinionRepository

  import Ecto.Query
  alias YRepo.Repo
  alias YRepo.Schemas.Opinion
  alias YCore.Content.Opinion, as: DomainOpinion

  def list_by_take(take_id) do
    Opinion
    |> where(parent_take_id: ^take_id)
    |> order_by(asc: :inserted_at)
    |> preload(:user)
    |> Repo.all()
    |> Enum.map(&to_domain/1)
  end

  def list_by_opinion(opinion_id) do
    Opinion
    |> where(parent_opinion_id: ^opinion_id)
    |> order_by(asc: :inserted_at)
    |> preload(:user)
    |> Repo.all()
    |> Enum.map(&to_domain/1)
  end

  def create(params) do
    %Opinion{}
    |> Opinion.changeset(params)
    |> Repo.insert()
    |> case do
      {:ok, schema} -> {:ok, to_domain(schema)}
      {:error, changeset} -> {:error, changeset}
    end
  end

  defp to_domain(schema) do
    user = 
      if Ecto.assoc_loaded?(schema.user) and schema.user != nil do
        %{
          id: schema.user.id,
          username: schema.user.username,
          bitmoji_id: schema.user.bitmoji_id,
          bitmoji_color: YRepo.Helpers.Color.from_id(schema.user.bitmoji_id),
          handle: "@#{schema.user.username}"
        }
      else
        nil
      end

    %DomainOpinion{
      id: schema.id,
      user_id: schema.user_id,
      parent_take_id: schema.parent_take_id,
      parent_opinion_id: schema.parent_opinion_id,
      body: schema.body,
      inserted_at: schema.inserted_at
    }
    |> Map.put(:user, user)
  end
end
