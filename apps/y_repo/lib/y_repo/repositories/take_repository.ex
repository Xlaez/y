defmodule YRepo.Repositories.TakeRepository do
  @behaviour YCore.Content.TakeRepository

  import Ecto.Query
  alias YRepo.Repo
  alias YRepo.Schemas.Take, as: SchemaTake
  alias YCore.Content.Take, as: DomainTake
  alias YRepo.Queries.FeedQuery

  @impl true
  def create(attrs) do
    %SchemaTake{}
    |> SchemaTake.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, schema} -> {:ok, to_domain(schema)}
      {:error, changeset} -> {:error, changeset}
    end
  end

  @impl true
  def get_by_id(id) do
    case Repo.get(SchemaTake, id) do
      nil -> {:error, :not_found}
      schema -> {:ok, to_domain(schema)}
    end
  end

  @impl true
  def delete(id, requesting_user_id) do
    case Repo.get(SchemaTake, id) do
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
  def list_for_feed(user_ids, opts) do
    user_ids
    |> FeedQuery.scored_feed(opts)
    |> Repo.all()
    |> Enum.map(&to_domain/1)
  end

  @impl true
  def list_for_user(user_id, opts) do
    limit = Keyword.get(opts, :limit, 20)
    
    SchemaTake
    |> where(user_id: ^user_id)
    |> order_by(desc: :inserted_at)
    |> limit(^limit)
    |> Repo.all()
    |> Enum.map(&to_domain/1)
  end

  @impl true
  def count_for_user(user_id) do
    SchemaTake
    |> where(user_id: ^user_id)
    |> Repo.aggregate(:count, :id)
  end

  @impl true
  def search(query, opts \\ []) do
    limit = Keyword.get(opts, :limit, 20)
    
    query
    |> YRepo.Queries.ExploreQuery.search_takes(limit)
    |> Repo.all()
    |> Enum.map(fn schema ->
      domain = to_domain(schema)
      if Ecto.assoc_loaded?(schema.user) do
        author = YRepo.Repositories.UserRepository.to_domain(schema.user)
        %{domain | author: author}
      else
        domain
      end
    end)
  end

  def list_by_ids(ids) do
    SchemaTake
    |> where([t], t.id in ^ids)
    |> Repo.all()
    |> Enum.map(&to_domain/1)
  end

  @impl true
  def increment_opinion_count(id) do
    SchemaTake
    |> where(id: ^id)
    |> Repo.update_all(inc: [opinion_count: 1])
    :ok
  end

  @impl true
  def increment_retake_count(id) do
    SchemaTake
    |> where(id: ^id)
    |> Repo.update_all(inc: [retake_count: 1])
    :ok
  end

  defp to_domain(%SchemaTake{} = schema) do
    %DomainTake{
      id: schema.id,
      user_id: schema.user_id,
      body: schema.body,
      inserted_at: schema.inserted_at,
      opinion_count: schema.opinion_count,
      retake_count: schema.retake_count
    }
  end
end
