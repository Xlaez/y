defmodule YRepo.Repositories.UserRepository do
  @moduledoc """
  Implementation of YCore.Accounts.UserRepository behaviour using Ecto.
  Handles mapping between Ecto schemas and domain entities.
  """

  @behaviour YCore.Accounts.UserRepository

  import Ecto.Query
  alias YRepo.Repo
  alias YRepo.Schemas.User, as: SchemaUser
  alias YCore.Accounts.User, as: DomainUser

  @impl true
  def get_by_id(id) do
    case Repo.get(SchemaUser, id) do
      nil -> {:error, :not_found}
      user -> {:ok, to_domain(user)}
    end
  end

  def get(id), do: get_by_id(id)

  @impl true
  def get_by_username(username) do
    # Case-insensitive lookup using LOWER() index
    SchemaUser
    |> where([u], fragment("LOWER(?)", u.username) == fragment("LOWER(?)", ^username))
    |> Repo.one()
    |> case do
      nil -> {:error, :not_found}
      user -> {:ok, to_domain(user)}
    end
  end

  @impl true
  def create(attrs) do
    attrs
    |> SchemaUser.creation_changeset()
    |> Repo.insert()
    |> case do
      {:ok, user} -> {:ok, to_domain(user)}
      {:error, changeset} -> {:error, changeset}
    end
  end

  @impl true
  def update(%DomainUser{id: id}, attrs) do
    case Repo.get(SchemaUser, id) do
      nil -> {:error, :not_found}
      schema_user ->
        schema_user
        |> SchemaUser.password_update_changeset(attrs)
        |> Repo.update()
        |> case do
          {:ok, user} -> {:ok, to_domain(user)}
          {:error, changeset} -> {:error, changeset}
        end
    end
  end

  @impl true
  def delete(id) do
    case Repo.get(SchemaUser, id) do
      nil -> {:error, :not_found}
      user ->
        Repo.delete(user)
        :ok
    end
  end

  # Private helper: mapping every YRepo.Schemas.User field to YCore.Accounts.User struct
  defp to_domain(%SchemaUser{} = schema) do
    %DomainUser{
      id: schema.id,
      username: schema.username,
      password_hash: schema.password_hash,
      seed_phrase_hash: schema.seed_phrase_hash,
      bitmoji_id: schema.bitmoji_id,
      bitmoji_color: YRepo.Helpers.Color.from_id(schema.bitmoji_id),
      handle: "@#{schema.username}",
      follower_count: 0,
      following_count: 0,
      take_count: 0,
      is_locked: schema.is_locked,
      inserted_at: schema.inserted_at,
      updated_at: schema.updated_at
    }
  end
end
