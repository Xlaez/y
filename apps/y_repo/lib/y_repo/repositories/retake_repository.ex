defmodule YRepo.Repositories.RetakeRepository do
  @behaviour YCore.Content.RetakeRepository

  alias YRepo.Repo
  alias YRepo.Schemas.Retake
  alias YCore.Content.Retake, as: DomainRetake

  def create(params) do
    %Retake{}
    |> Retake.changeset(params)
    |> Repo.insert()
    |> case do
      {:ok, schema} -> {:ok, to_domain(schema)}
      {:error, changeset} -> {:error, changeset}
    end
  end

  defp to_domain(schema) do
    %DomainRetake{
      id: schema.id,
      user_id: schema.user_id,
      original_take_id: schema.original_take_id,
      comment: schema.comment,
      inserted_at: schema.inserted_at
    }
  end
end
