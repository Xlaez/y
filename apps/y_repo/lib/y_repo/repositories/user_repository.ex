defmodule YRepo.Repositories.UserRepository do
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

  def get_by_id!(id) do
    case get_by_id(id) do
      {:ok, user} -> user
      {:error, :not_found} -> raise "User with id #{id} not found"
    end
  end

  def get(id), do: get_by_id(id)

  @impl true
  def get_by_username(username) do
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
      nil ->
        {:error, :not_found}

      schema_user ->
        changeset = cond do
          Map.has_key?(attrs, :password_hash) ->
            SchemaUser.password_update_changeset(schema_user, attrs)
          Map.has_key?(attrs, :bitmoji_color) ->
            SchemaUser.bitmoji_color_changeset(schema_user, attrs)
          Map.has_key?(attrs, :is_locked) ->
            SchemaUser.lock_changeset(schema_user, attrs)
          Map.has_key?(attrs, :display_name) or Map.has_key?(attrs, :profile_picture_base64) ->
            SchemaUser.update_profile_changeset(schema_user, attrs)
          true ->
            SchemaUser.update_changeset(schema_user, attrs)
        end

        changeset
        |> Repo.update()
        |> case do
          {:ok, user} -> {:ok, to_domain(user)}
          {:error, changeset} -> {:error, changeset}
        end
    end
  end

  @impl true
  def list_by_ids(ids) do
    SchemaUser
    |> where([u], u.id in ^ids)
    |> Repo.all()
    |> Enum.map(&to_domain/1)
  end

  @impl true
  def search(query, opts \\ []) do
    limit = Keyword.get(opts, :limit, 20)
    
    query
    |> YRepo.Queries.ExploreQuery.search_users(limit)
    |> Repo.all()
    |> Enum.map(&to_domain/1)
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

  def to_domain(%SchemaUser{} = schema) do
    %DomainUser{
      id: schema.id,
      username: schema.username,
      password_hash: schema.password_hash,
      seed_phrase_hash: schema.seed_phrase_hash,
      bitmoji_id: schema.bitmoji_id,
      bitmoji_color: schema.bitmoji_color || YRepo.Helpers.Color.from_id(schema.bitmoji_id),
      display_name: schema.display_name,
      profile_picture_base64: schema.profile_picture_base64,
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
