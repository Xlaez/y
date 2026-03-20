defmodule YRepo.Repositories.AgreeRepository do
  @behaviour YCore.Interactions.AgreeRepository

  import Ecto.Query
  alias YRepo.Repo
  alias YRepo.Schemas.Agree, as: SchemaAgree

  @impl true
  def toggle(user_id, target_type, target_id, notification_repo) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:existing, fn repo, _ ->
      result = repo.one(from a in SchemaAgree, 
        where: a.user_id == ^user_id and a.target_type == ^target_type and a.target_id == ^target_id)
      {:ok, result}
    end)
    |> Ecto.Multi.run(:action, fn repo, %{existing: existing} ->
      if existing do
        repo.delete!(existing)
        {:ok, :removed}
      else
        %SchemaAgree{}
        |> SchemaAgree.changeset(%{user_id: user_id, target_type: target_type, target_id: target_id})
        |> repo.insert()
        |> case do
          {:ok, _} -> {:ok, :agreed}
          {:error, error} -> {:error, error}
        end
      end
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{action: :agreed}} ->
        Task.start(fn ->
          owner_id = get_target_owner_id(target_type, target_id)
          YCore.Notifications.NotificationService.notify_agreed(user_id, owner_id, target_type, target_id, notification_repo, YRepo.Repositories.UserRepository)
        end)
        {:ok, :agreed}

      {:ok, %{action: action}} ->
        {:ok, action}

      {:error, :action, error, _} ->
        {:error, error}
    end
  end

  defp get_target_owner_id(:take, target_id), do: Repo.get(YRepo.Schemas.Take, target_id).user_id
  defp get_target_owner_id(:retake, target_id), do: Repo.get(YRepo.Schemas.Retake, target_id).user_id
  defp get_target_owner_id(:opinion, target_id), do: Repo.get(YRepo.Schemas.Opinion, target_id).user_id

  @impl true
  def agreed?(user_id, target_type, target_id) do
    SchemaAgree
    |> where(user_id: ^user_id, target_type: ^target_type, target_id: ^target_id)
    |> Repo.exists?()
  end

  @impl true
  def count(target_type, target_id) do
    SchemaAgree
    |> where(target_type: ^target_type, target_id: ^target_id)
    |> Repo.aggregate(:count, :id)
  end

  @impl true
  def list_agreed_ids(user_id, target_type, target_ids) do
    SchemaAgree
    |> where([a], a.user_id == ^user_id and a.target_type == ^target_type and a.target_id in ^target_ids)
    |> select([a], a.target_id)
    |> Repo.all()
    |> Enum.map(&Ecto.UUID.cast!/1)
  end
end
