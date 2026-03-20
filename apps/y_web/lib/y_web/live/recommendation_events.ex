defmodule YWeb.Live.RecommendationEvents do
  @moduledoc """
  Shared event handlers for "Who to Follow" recommendations.
  """

  import Phoenix.Component

  defmacro __using__(_) do
    quote do
      def handle_event("follow_suggested", %{"user_id" => target_id}, socket) do
        current_user = socket.assigns.current_user

        case YCore.Social.FollowService.follow(
               current_user.id,
               target_id,
               YRepo.Repositories.FollowRepository,
               YRepo.Repositories.UserRepository,
               YRepo.Repositories.NotificationRepository
             ) do
          {:ok, _} ->
            # Remove the followed user from who_to_follow assigns
            updated =
              Enum.reject(socket.assigns.who_to_follow, fn item ->
                item.user_id == target_id
              end)

            {:noreply, assign(socket, who_to_follow: updated)}

          {:error, _} ->
            {:noreply, socket}
        end
      end

      def handle_event("show_more_suggestions", _params, socket) do
        {:noreply, assign(socket, show_all_suggestions: true)}
      end

      def handle_event("show_less_suggestions", _params, socket) do
        {:noreply, assign(socket, show_all_suggestions: false)}
      end
    end
  end
end
