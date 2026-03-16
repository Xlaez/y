defmodule YRepo.Repositories.RetakeRepository do
  @behaviour YCore.Content.RetakeRepository

  import Ecto.Query
  alias YRepo.Repo
  alias YRepo.Schemas.Retake, as: SchemaRetake
  alias YCore.Content.Retake, as: DomainRetake

  @impl true
  def create(attrs) do
    %SchemaRetake{}
    |> SchemaRetake.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, schema} -> {:ok, to_domain(schema)}
      {:error, %{errors: [user_id: {_, [constraint: :unique, constraint_name: "retakes_user_id_original_take_id_index"]}]}} ->
        {:error, :already_retook}
      {:error, changeset} -> {:error, changeset}
    end
  end

  @impl true
  def get_by_id(id) do
    case Repo.get(SchemaRetake, id) do
      nil -> {:error, :not_found}
      schema -> {:ok, to_domain(schema)}
    end
  end

  @impl true
  def delete(id, requesting_user_id) do
    case Repo.get(SchemaRetake, id) do
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
  def already_retook?(user_id, original_take_id) do
    SchemaRetake
    |> where(user_id: ^user_id, original_take_id: ^original_take_id)
    |> Repo.exists?()
  end

  @impl true
  def count_for_take(original_take_id) do
    SchemaRetake
    |> where(original_take_id: ^original_take_id)
    |> Repo.aggregate(:count, :id)
  end

  defp to_domain(%SchemaRetake{} = schema) do
    %DomainRetake{
      id: schema.id,
      user_id: schema.user_id,
      original_take_id: schema.original_take_id,
      comment: schema.comment,
      inserted_at: schema.inserted_at
    }
  end
end
