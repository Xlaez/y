defmodule YCore.Content.OpinionService do
  @moduledoc """
  Service for managing Opinions (replies).
  """
  alias YCore.Content.TakeBody

  @spec post(map(), module(), module()) ::
          {:ok, YCore.Content.Opinion.t()} | {:error, term()}
  def post(params, opinion_repo, take_repo) do
    %{user_id: user_id, take_id: take_id, body: body} = params
    parent_opinion_id = Map.get(params, :parent_opinion_id)

    with :ok <- verify_take_exists(take_id, take_repo),
         {:ok, depth} <- derive_depth(parent_opinion_id, opinion_repo),
         {:ok, trimmed_body} <- TakeBody.new(body) do
      opinion_repo.create(%{
        user_id: user_id,
        take_id: take_id,
        parent_opinion_id: parent_opinion_id,
        body: trimmed_body,
        depth: depth
      })
    end
  end

  defp verify_take_exists(take_id, take_repo) do
    case take_repo.get_by_id(take_id) do
      {:ok, _} -> :ok
      _ -> {:error, :not_found}
    end
  end

  defp derive_depth(nil, _repo), do: {:ok, 0}
  defp derive_depth(parent_id, repo) do
    case repo.get_by_id(parent_id) do
      {:ok, %{depth: depth}} when depth < 4 -> {:ok, depth + 1}
      {:ok, %{depth: _}} -> {:error, :max_depth_exceeded}
      _ -> {:error, :parent_not_found}
    end
  end

  @spec build_tree([YCore.Content.Opinion.t()]) :: [map()]
  def build_tree(opinions) do
    # Group by parent_opinion_id
    opinions_by_parent = Enum.group_by(opinions, & &1.parent_opinion_id)

    # Build forest (root nodes have nil parent)
    root_opinions = Map.get(opinions_by_parent, nil, [])
    |> Enum.sort_by(& &1.inserted_at, {:desc, DateTime})

    Enum.map(root_opinions, fn op -> assemble_node(op, opinions_by_parent) end)
  end

  defp assemble_node(opinion, opinions_by_parent) do
    replies = Map.get(opinions_by_parent, opinion.id, [])
    |> Enum.sort_by(& &1.inserted_at, {:asc, DateTime})
    |> Enum.map(fn reply -> assemble_node(reply, opinions_by_parent) end)

    %{
      opinion: opinion,
      replies: replies
    }
  end
end
