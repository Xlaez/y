defmodule YRepo.Repositories.BlockRepository do
  @behaviour YCore.Social.BlockRepository

  import Ecto.Query
  alias YRepo.Repo
  alias YRepo.Schemas.Block
  alias YRepo.Schemas.User, as: SchemaUser
  alias YCore.Social.Block, as: DomainBlock
  alias YCore.Accounts.User, as: DomainUser

  @impl true
  def block(blocker_id, blocked_id) do
    %Block{}
    |> Block.changeset(%{blocker_id: blocker_id, blocked_id: blocked_id})
    |> Repo.insert()
    |> case do
      {:ok, schema} -> {:ok, to_domain(schema)}
      {:error, %Ecto.Changeset{errors: errors}} ->
        if has_unique_error?(errors) do
          {:error, :already_blocked}
        else
          {:error, errors}
        end
    end
  end

  @impl true
  def unblock(blocker_id, blocked_id) do
    query = from b in Block,
      where: b.blocker_id == ^blocker_id and b.blocked_id == ^blocked_id

    case Repo.delete_all(query) do
      {0, _} -> {:error, :not_blocked}
      {_, _} -> :ok
    end
  end

  @impl true
  def blocked?(blocker_id, blocked_id) do
    from(b in Block,
      where: b.blocker_id == ^blocker_id and b.blocked_id == ^blocked_id
    )
    |> Repo.exists?()
  end

  @impl true
  def list_blocked(user_id) do
    from(b in Block,
      where: b.blocker_id == ^user_id,
      join: u in SchemaUser, on: u.id == b.blocked_id,
      select: u,
      order_by: [desc: b.inserted_at]
    )
    |> Repo.all()
    |> Enum.map(&user_to_domain/1)
  end

  defp has_unique_error?(errors) do
    Enum.any?(errors, fn {_field, {_msg, opts}} ->
      opts[:constraint] == :unique
    end)
  rescue
    _ -> false
  end

  defp to_domain(schema) do
    %DomainBlock{
      id: schema.id,
      blocker_id: schema.blocker_id,
      blocked_id: schema.blocked_id,
      inserted_at: schema.inserted_at
    }
  end

  defp user_to_domain(%SchemaUser{} = schema) do
    %DomainUser{
      id: schema.id,
      username: schema.username,
      password_hash: schema.password_hash,
      seed_phrase_hash: schema.seed_phrase_hash,
      bitmoji_id: schema.bitmoji_id,
      bitmoji_color: schema.bitmoji_color || YRepo.Helpers.Color.from_id(schema.bitmoji_id),
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
