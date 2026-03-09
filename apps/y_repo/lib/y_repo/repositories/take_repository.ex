defmodule YRepo.Repositories.TakeRepository do
  @behaviour YCore.Content.TakeRepository

  alias YRepo.Repo
  alias YRepo.Schemas.Take
  alias YCore.Content.Take, as: DomainTake

  def get_by_id(id) do
    case Repo.get(Take, id) do
      nil -> {:error, :not_found}
      schema -> {:ok, to_domain(schema)}
    end
  end

  def create(params) do
    %Take{}
    |> Take.changeset(params)
    |> Repo.insert()
    |> case do
      {:ok, schema} -> {:ok, to_domain(schema)}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def delete(%DomainTake{id: id}) do
    case Repo.get(Take, id) do
      nil -> {:error, :not_found}
      schema ->
        Repo.delete(schema)
        :ok
    end
  end

  defp to_domain(schema) do
    %DomainTake{
      id: schema.id,
      user_id: schema.user_id,
      body: schema.body,
      inserted_at: schema.inserted_at
    }
  end
end
