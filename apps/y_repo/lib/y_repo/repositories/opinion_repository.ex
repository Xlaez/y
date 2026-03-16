defmodule YRepo.Repositories.OpinionRepository do
  @behaviour YCore.Content.OpinionRepository

  import Ecto.Query
  alias YRepo.Repo
  alias YRepo.Schemas.Opinion, as: SchemaOpinion
  alias YCore.Content.Opinion, as: DomainOpinion

  @impl true
  def create(attrs) do
    %SchemaOpinion{}
    |> SchemaOpinion.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, schema} -> {:ok, to_domain(schema)}
      {:error, changeset} -> {:error, changeset}
    end
  end

  @impl true
  def get_by_id(id) do
    case Repo.get(SchemaOpinion, id) do
      nil -> {:error, :not_found}
      schema -> {:ok, to_domain(schema)}
    end
  end

  @impl true
  def delete(id, requesting_user_id) do
    case Repo.get(SchemaOpinion, id) do
      nil -> {:error, :not_found}
      schema ->
        if schema.user_id == requesting_user_id do
          Repo.delete!(schema)
          :ok
        else
          {:error, :forbidden}
        end
    end
  end

  @impl true
  def list_for_take(take_id) do
    SchemaOpinion
    |> where(take_id: ^take_id)
    |> order_by(asc: :inserted_at)
    |> Repo.all()
    |> Enum.map(&to_domain/1)
  end

  @impl true
  def count_for_take(take_id) do
    SchemaOpinion
    |> where(take_id: ^take_id)
    |> Repo.aggregate(:count, :id)
  end

  defp to_domain(%SchemaOpinion{} = schema) do
    %DomainOpinion{
      id: schema.id,
      user_id: schema.user_id,
      take_id: schema.take_id,
      parent_opinion_id: schema.parent_opinion_id,
      body: schema.body,
      depth: schema.depth,
      inserted_at: schema.inserted_at
    }
  end
end
