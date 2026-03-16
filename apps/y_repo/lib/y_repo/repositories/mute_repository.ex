defmodule YRepo.Repositories.MuteRepository do
  @behaviour YCore.Social.MuteRepository

  import Ecto.Query
  alias YRepo.Repo
  alias YRepo.Schemas.Mute
  alias YRepo.Schemas.User, as: SchemaUser
  alias YCore.Social.Mute, as: DomainMute
  alias YCore.Accounts.User, as: DomainUser

  @impl true
  def mute(muter_id, muted_id) do
    %Mute{}
    |> Mute.changeset(%{muter_id: muter_id, muted_id: muted_id})
    |> Repo.insert()
    |> case do
      {:ok, schema} -> {:ok, to_domain(schema)}
      {:error, %Ecto.Changeset{errors: errors}} ->
        if has_unique_error?(errors) do
          {:error, :already_muted}
        else
          {:error, errors}
        end
    end
  end

  @impl true
  def unmute(muter_id, muted_id) do
    query = from m in Mute,
      where: m.muter_id == ^muter_id and m.muted_id == ^muted_id

    case Repo.delete_all(query) do
      {0, _} -> {:error, :not_muted}
      {_, _} -> :ok
    end
  end

  @impl true
  def muted?(muter_id, muted_id) do
    from(m in Mute,
      where: m.muter_id == ^muter_id and m.muted_id == ^muted_id
    )
    |> Repo.exists?()
  end

  @impl true
  def list_muted(user_id) do
    from(m in Mute,
      where: m.muter_id == ^user_id,
      join: u in SchemaUser, on: u.id == m.muted_id,
      select: u,
      order_by: [desc: m.inserted_at]
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
    %DomainMute{
      id: schema.id,
      muter_id: schema.muter_id,
      muted_id: schema.muted_id,
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
