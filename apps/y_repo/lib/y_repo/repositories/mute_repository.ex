defmodule YRepo.Repositories.MuteRepository do
  @behaviour YCore.Social.MuteRepository

  alias YRepo.Repo
  alias YRepo.Schemas.Mute
  alias YCore.Social.Mute, as: DomainMute

  def create(params) do
    %Mute{}
    |> Mute.changeset(params)
    |> Repo.insert()
    |> case do
      {:ok, schema} -> {:ok, to_domain(schema)}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def delete(%DomainMute{id: id}) do
    case Repo.get(Mute, id) do
      nil -> {:error, :not_found}
      schema ->
        Repo.delete(schema)
        :ok
    end
  end

  defp to_domain(schema) do
    %DomainMute{
      id: schema.id,
      muter_id: schema.muter_id,
      muted_id: schema.muted_id,
      inserted_at: schema.inserted_at
    }
  end
end
