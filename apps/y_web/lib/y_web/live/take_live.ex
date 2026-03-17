defmodule YWeb.TakeLive do
  use YWeb, :live_view

  alias YCore.Content.{TakeService, OpinionService}
  alias YRepo.Repositories.{TakeRepository, OpinionRepository, AgreeRepository, BookmarkRepository, UserRepository, RetakeRepository}

  def mount(%{"id" => id} = _params, _session, socket) do
    user_id = socket.assigns.current_user.id

    case TakeRepository.get_by_id(id) do
      {:ok, take} ->
        author = UserRepository.get_by_id!(take.user_id)
        opinions = OpinionRepository.list_for_take(id)
        opinion_tree = OpinionService.build_tree(opinions)

        agreed? = AgreeRepository.agreed?(user_id, :take, id)
        bookmarked? = BookmarkRepository.bookmarked?(user_id, :take, id)

        {:ok,
         socket
         |> assign(active_tab: :home)
         |> assign(take: take)
         |> assign(author: author)
         |> assign(opinion_tree: opinion_tree)
         |> assign(agree_count: AgreeRepository.count(:take, id))
         |> assign(retake_count: RetakeRepository.count_for_take(id))
         |> assign(viewer_agreed: agreed?)
         |> assign(viewer_bookmarked: bookmarked?)
         |> assign(reply_body: "")
         |> assign(reply_char_count: 0)
         |> assign(replying_to: nil)
         |> assign(error: nil), layout: {YWeb.Layouts, :authenticated}}

      _ ->
        {:ok, push_navigate(socket, to: "/home")}
    end
  end

  def handle_event("validate_reply", %{"body" => body}, socket) do
    {:noreply, assign(socket, reply_body: body, reply_char_count: String.length(body))}
  end

  def handle_event("post_reply", %{"body" => body}, socket) do
    user_id = socket.assigns.current_user.id
    take_id = socket.assigns.take.id
    parent_opinion_id = socket.assigns.replying_to

    params = %{
      user_id: user_id,
      take_id: take_id,
      parent_opinion_id: parent_opinion_id,
      body: body
    }

    case OpinionService.post(params, OpinionRepository, TakeRepository) do
      {:ok, _opinion} ->
        {:noreply,
         socket
         |> refresh_opinions()
         |> assign(reply_body: "", reply_char_count: 0, replying_to: nil)
         |> put_flash(:info, "Your opinion was shared!")}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Could not post reply: #{reason}")}
    end
  end

  def handle_event("toggle_agree", %{"target_type" => type, "target_id" => id}, socket) do
    user_id = socket.assigns.current_user.id
    target_type = String.to_existing_atom(type)

    case AgreeRepository.toggle(user_id, target_type, id) do
      {:ok, _} -> {:noreply, refresh_take_data(socket)}
      _ -> {:noreply, socket}
    end
  end

  def handle_event("toggle_bookmark", %{"target_type" => type, "target_id" => id}, socket) do
    user_id = socket.assigns.current_user.id
    target_type = String.to_existing_atom(type)

    case BookmarkRepository.toggle(user_id, target_type, id) do
      {:ok, _} -> {:noreply, refresh_take_data(socket)}
      _ -> {:noreply, socket}
    end
  end

  def handle_event("set_reply_target", %{"id" => id}, socket) do
    {:noreply, assign(socket, replying_to: id)}
  end
  
  def handle_event("cancel_reply", _, socket) do
    {:noreply, assign(socket, replying_to: nil, reply_body: "", reply_char_count: 0)}
  end

  defp refresh_opinions(socket) do
    opinions = OpinionRepository.list_for_take(socket.assigns.take.id)
    assign(socket, opinion_tree: OpinionService.build_tree(opinions))
  end

  defp refresh_take_data(socket) do
    id = socket.assigns.take.id
    user_id = socket.assigns.current_user.id
    
    socket
    |> assign(agree_count: AgreeRepository.count(:take, id))
    |> assign(viewer_agreed: AgreeRepository.agreed?(user_id, :take, id))
    |> assign(viewer_bookmarked: BookmarkRepository.bookmarked?(user_id, :take, id))
  end

  defp opinion_node(assigns) do
    ~H"""
    <div class="flex flex-col">
      <YWeb.Components.FeedCard.feed_card 
        item={%{type: :opinion, take: @node.opinion, author: UserRepository.get_by_id!(@node.opinion.user_id), opinion_count: Enum.count(@node.replies), agree_count: 0, retake_count: 0, viewer_agreed: false, viewer_bookmarked: false, viewer_retook: false}}
        current_user={@current_user}
      />
      <%= if !Enum.empty?(@node.replies) do %>
        <div class="pl-12 border-l-2 border-y-border ml-6">
          <%= for reply <- @node.replies do %>
            <.opinion_node node={reply} current_user={@current_user} />
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end

  defp action_button_hero(assigns) do
    ~H"""
    <button 
      phx-click={assigns[:phx_click]}
      phx-value-target_type={assigns[:phx_value_target_type]}
      phx-value-target_id={assigns[:phx_value_target_id]}
      class={[
        "flex items-center gap-1.5 p-2.5 rounded-full hover:bg-y-hover transition-colors group",
        if(assigns[:active], do: "text-y-opinion", else: "text-y-faint")
      ]}
    >
      <span class={["size-5 transition-transform group-active:scale-95", @icon]}></span>
      <%= if assigns[:count] && @count > 0 do %>
        <span class="text-sm font-medium"><%= @count %></span>
      <% end %>
    </button>
    """
  end

  defp bitmoji(assigns) do
    YWeb.Layouts.bitmoji(assigns)
  end

  defp opinion_to_take_adapter(opinion) do
    %{
      id: opinion.id,
      user_id: opinion.user_id,
      body: opinion.body,
      inserted_at: opinion.inserted_at,
      type: :opinion
    }
  end
end
