defmodule YWeb.Hooks.Recommendations do
  @moduledoc """
  on_mount hook to fetch "Who to Follow" recommendations for authenticated users.
  """
  import Phoenix.Component

  def on_mount(:default, _params, _session, socket) do
    case socket.assigns[:current_user] do
      nil ->
        {:cont, assign(socket, who_to_follow: [])}

      current_user ->
        recommendations =
          YCore.Social.RecommendationService.who_to_follow(
            current_user.id,
            %{
              follow_repo: YRepo.Repositories.FollowRepository,
              block_repo: YRepo.Repositories.BlockRepository,
              user_repo: YRepo.Repositories.UserRepository,
              cache_repo: YRepo.Cache.Recommendations
            }
          )

        {:cont, assign(socket, who_to_follow: recommendations)}
    end
  end
end
