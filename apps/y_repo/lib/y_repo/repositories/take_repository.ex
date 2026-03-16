defmodule YRepo.Repositories.TakeRepository do
  @behaviour YCore.Content.TakeRepository

  import Ecto.Query
  alias YRepo.Repo
  alias YRepo.Schemas.Take
  alias YRepo.Schemas.Take
  alias YCore.Content.Take, as: DomainTake

  def get_by_id(id) do
    case Repo.get(Take, id) do
      nil -> {:error, :not_found}
      schema -> {:ok, to_domain(schema)}
    end
  end

  def get_with_user(id) do
    Take
    |> where(id: ^id)
    |> preload(:user)
    |> Repo.one()
    |> case do
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
    user = 
      if Ecto.assoc_loaded?(schema.user) and schema.user != nil do
        # Mapping user schema to domain in a way that respects the UserRepository structure
        # We can't easily call UserRepository.to_domain because it's private.
        # But we can replicate the logic or make it public.
        # For now, let's replicate the basic fields needed for the UI.
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

    %DomainTake{
      id: schema.id,
      user_id: schema.user_id,
      body: schema.body,
      inserted_at: schema.inserted_at
    } 
    |> Map.put(:user, user)
  end
end
