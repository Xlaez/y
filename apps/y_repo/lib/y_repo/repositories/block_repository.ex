defmodule YRepo.Repositories.BlockRepository do
  @behaviour YCore.Social.BlockRepository

  alias YRepo.Repo
  alias YRepo.Schemas.Block
  alias YCore.Social.Block, as: DomainBlock

  def create(params) do
    %Block{}
    |> Block.changeset(params)
    |> Repo.insert()
    |> case do
      {:ok, schema} -> {:ok, to_domain(schema)}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def delete(%DomainBlock{id: id}) do
    case Repo.get(Block, id) do
      nil -> {:error, :not_found}
      schema ->
        Repo.delete(schema)
        :ok
    end
  end

  defp to_domain(schema) do
    %DomainBlock{
      id: schema.id,
      blocker_id: schema.blocker_id,
      blocked_id: schema.blocked_id,
      inserted_at: schema.inserted_at
    }
  end
end
