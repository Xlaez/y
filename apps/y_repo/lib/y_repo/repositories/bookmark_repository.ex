defmodule YRepo.Repositories.BookmarkRepository do
  @behaviour YCore.Interactions.BookmarkRepository

  import Ecto.Query
  alias YRepo.Repo
  alias YRepo.Schemas.Bookmark, as: SchemaBookmark

  @impl true
  def toggle(user_id, target_type, target_id) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:existing, fn repo, _ ->
      result = repo.one(from b in SchemaBookmark, 
        where: b.user_id == ^user_id and b.target_type == ^target_type and b.target_id == ^target_id)
      {:ok, result}
    end)
    |> Ecto.Multi.run(:action, fn repo, %{existing: existing} ->
      if existing do
        repo.delete!(existing)
        {:ok, :removed}
      else
        %SchemaBookmark{}
        |> SchemaBookmark.changeset(%{user_id: user_id, target_type: target_type, target_id: target_id})
        |> repo.insert()
        |> case do
          {:ok, _} -> {:ok, :saved}
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
  def bookmarked?(user_id, target_type, target_id) do
    SchemaBookmark
    |> where(user_id: ^user_id, target_type: ^target_type, target_id: ^target_id)
    |> Repo.exists?()
  end

  @impl true
  def list_for_user(user_id, opts) do
    target_type = Keyword.get(opts, :target_type)

    query = from b in SchemaBookmark,
      where: b.user_id == ^user_id,
      order_by: [desc: b.inserted_at]

    query = if target_type, do: where(query, target_type: ^target_type), else: query

    Repo.all(query)
  end
end
