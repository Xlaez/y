defmodule YRepo.Repositories.RetakeRepository do
  @behaviour YCore.Content.RetakeRepository

  import Ecto.Query
  alias YRepo.Repo
  alias YRepo.Schemas.Retake, as: SchemaRetake
  alias YCore.Content.Retake, as: DomainRetake

  @impl true
  def create(attrs) do
    %SchemaRetake{}
    |> SchemaRetake.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, schema} -> {:ok, to_domain(schema)}
      {:error, %{errors: [user_id: {_, [constraint: :unique, constraint_name: "retakes_user_id_original_take_id_index"]}]}} ->
        {:error, :already_retook}
      {:error, changeset} -> {:error, changeset}
    end
  end

  @impl true
  def get_by_id(id) do
    case Repo.get(SchemaRetake, id) do
      nil -> {:error, :not_found}
      schema -> {:ok, to_domain(schema)}
    end
  end

  @impl true
  def delete(id, requesting_user_id) do
    case Repo.get(SchemaRetake, id) do
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
  def get_by_user_and_take(user_id, original_take_id) do
    SchemaRetake
    |> where(user_id: ^user_id, original_take_id: ^original_take_id)
    |> Repo.one()
    |> case do
      nil -> {:error, :not_found}
      schema -> {:ok, to_domain(schema)}
    end
  end

  @impl true
  def already_retook?(user_id, original_take_id) do
    SchemaRetake
    |> where(user_id: ^user_id, original_take_id: ^original_take_id)
    |> Repo.exists?()
  end

  @impl true
  def list_retook_ids(user_id, original_take_ids) do
    SchemaRetake
    |> where(user_id: ^user_id)
    |> where([r], r.original_take_id in ^original_take_ids)
    |> select([r], r.original_take_id)
    |> Repo.all()
  end

  @impl true
  def count_for_take(original_take_id) do
    SchemaRetake
    |> where(original_take_id: ^original_take_id)
    |> Repo.aggregate(:count, :id)
  end

  @impl true
  def list_by_ids(ids) do
    SchemaRetake
    |> where([r], r.id in ^ids)
    |> Repo.all()
    |> Enum.map(&to_domain/1)
  end

  @impl true
  def list_for_users(user_ids, opts) do
    limit = Keyword.get(opts, :limit, 20)
    before = Keyword.get(opts, :before)

    query = if user_ids == :all do
      SchemaRetake
    else
      where(SchemaRetake, [r], r.user_id in ^user_ids)
    end

    query =
      if before do
        where(query, [r], r.inserted_at < ^before)
      else
        query
      end

    query
    |> order_by(desc: :inserted_at)
    |> limit(^limit)
    |> Repo.all()
    |> Enum.map(&to_domain/1)
  end

  defp to_domain(%SchemaRetake{} = schema) do
    %DomainRetake{
      id: schema.id,
      user_id: schema.user_id,
      original_take_id: schema.original_take_id,
      comment: schema.comment,
      inserted_at: schema.inserted_at
    }
  end
end
