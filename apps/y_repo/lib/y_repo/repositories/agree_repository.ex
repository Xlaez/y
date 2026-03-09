defmodule YRepo.Repositories.AgreeRepository do
  @behaviour YCore.Interactions.AgreeRepository

  alias YRepo.Repo
  alias YRepo.Schemas.Agree
  alias YCore.Interactions.Agree, as: DomainAgree

  def create(params) do
    %Agree{}
    |> Agree.changeset(params)
    |> Repo.insert()
    |> case do
      {:ok, schema} -> {:ok, to_domain(schema)}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def delete(%DomainAgree{id: id}) do
    case Repo.get(Agree, id) do
      nil -> {:error, :not_found}
      schema ->
        Repo.delete(schema)
        :ok
    end
  end

  defp to_domain(schema) do
    %DomainAgree{
      id: schema.id,
      user_id: schema.user_id,
      target_type: schema.target_type,
      target_id: schema.target_id,
      inserted_at: schema.inserted_at
    }
  end
end
