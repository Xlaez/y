defmodule YRepo.Repositories.UserRepository do
  @behaviour YCore.Accounts.UserRepository

  alias YRepo.Repo
  alias YRepo.Schemas.User
  alias YCore.Accounts.User, as: DomainUser

  def get_by_id(id) do
    case Repo.get(User, id) do
      nil -> {:error, :not_found}
      schema -> {:ok, to_domain(schema)}
    end
  end

  def get_by_username(username) do
    case Repo.get_by(User, username: username) do
      nil -> {:error, :not_found}
      schema -> {:ok, to_domain(schema)}
    end
  end

  def create(params) do
    %User{}
    |> User.changeset(params)
    |> Repo.insert()
    |> case do
      {:ok, schema} -> {:ok, to_domain(schema)}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def update(user, params) do
    Repo.get(User, user.id)
    |> User.changeset(params)
    |> Repo.update()
    |> case do
      {:ok, schema} -> {:ok, to_domain(schema)}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def delete(user) do
    case Repo.get(User, user.id) do
      nil -> {:error, :not_found}
      schema ->
        Repo.delete(schema)
        :ok
    end
  end

  defp to_domain(schema) do
    %DomainUser{
      id: schema.id,
      username: schema.username,
      password_hash: schema.password_hash,
      seed_phrase_hash: schema.seed_phrase_hash,
      bitmoji_id: schema.bitmoji_id,
      is_locked: schema.is_locked,
      inserted_at: schema.inserted_at,
      updated_at: schema.updated_at
    }
  end
end
