defmodule YRepo.Repositories.OpinionRepository do
  @behaviour YCore.Content.OpinionRepository

  alias YRepo.Repo
  alias YRepo.Schemas.Opinion
  alias YCore.Content.Opinion, as: DomainOpinion

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
    %DomainOpinion{
      id: schema.id,
      user_id: schema.user_id,
      parent_take_id: schema.parent_take_id,
      parent_opinion_id: schema.parent_opinion_id,
      body: schema.body,
      inserted_at: schema.inserted_at
    }
  end
end
