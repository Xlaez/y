defmodule YRepo.Repositories.BookmarkRepository do
  @behaviour YCore.Interactions.BookmarkRepository

  alias YRepo.Repo
  alias YRepo.Schemas.Bookmark
  alias YCore.Interactions.Bookmark, as: DomainBookmark

  def create(params) do
    %Bookmark{}
    |> Bookmark.changeset(params)
    |> Repo.insert()
    |> case do
      {:ok, schema} -> {:ok, to_domain(schema)}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def delete(%DomainBookmark{id: id}) do
    case Repo.get(Bookmark, id) do
      nil -> {:error, :not_found}
      schema ->
        Repo.delete(schema)
        :ok
    end
  end

  defp to_domain(schema) do
    %DomainBookmark{
      id: schema.id,
      user_id: schema.user_id,
      target_type: schema.target_type,
      target_id: schema.target_id,
      inserted_at: schema.inserted_at
    }
  end
end
