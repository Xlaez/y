defmodule YRepo.Repositories.AgreeRepository do
  @behaviour YCore.Interactions.AgreeRepository

  import Ecto.Query
  alias YRepo.Repo
  alias YRepo.Schemas.Agree, as: SchemaAgree

  @impl true
  def toggle(user_id, target_type, target_id) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:existing, fn repo, _ ->
      result = repo.one(from a in SchemaAgree, 
        where: a.user_id == ^user_id and a.target_type == ^target_type and a.target_id == ^target_id)
      {:ok, result}
    end)
    |> Ecto.Multi.run(:action, fn repo, %{existing: existing} ->
      if existing do
        repo.delete!(existing)
        {:ok, :removed}
      else
        %SchemaAgree{}
        |> SchemaAgree.changeset(%{user_id: user_id, target_type: target_type, target_id: target_id})
        |> repo.insert()
        |> case do
          {:ok, _} -> {:ok, :agreed}
          {:error, error} -> {:error, error}
        end
      end
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{action: action}} -> {:ok, action}
      {:error, :action, error, _} -> {:error, error}
    end
  end

  @impl true
  def agreed?(user_id, target_type, target_id) do
    SchemaAgree
    |> where(user_id: ^user_id, target_type: ^target_type, target_id: ^target_id)
    |> Repo.exists?()
  end

  @impl true
  def count(target_type, target_id) do
    SchemaAgree
    |> where(target_type: ^target_type, target_id: ^target_id)
    |> Repo.aggregate(:count, :id)
  end

  @impl true
  def list_agreed_ids(user_id, target_type, target_ids) do
    SchemaAgree
    |> where([a], a.user_id == ^user_id and a.target_type == ^target_type and a.target_id in ^target_ids)
    |> select([a], a.target_id)
    |> Repo.all()
    |> Enum.map(&Ecto.UUID.cast!/1)
  end
end
