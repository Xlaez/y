defmodule YWeb.TakeLive do
  use YWeb, :live_view

  alias YCore.Content.OpinionService
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
         |> assign(replying_to: id)
         |> assign(replying_to_handle: author.username)
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
      parent_opinion_id: if(parent_opinion_id == take_id, do: nil, else: parent_opinion_id),
      body: body
    }

    case OpinionService.post(params, OpinionRepository, TakeRepository) do
      {:ok, _opinion} ->
        {:noreply,
         socket
         |> refresh_opinions()
         |> assign(reply_body: "", reply_char_count: 0)
         |> assign(replying_to: take_id, replying_to_handle: socket.assigns.author.username)
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

  def handle_event("set_reply_target", params, socket) do
    id = params["id"] || params["take_id"]
    # If it's an opinion, fetch the user. If it's the take, use author.
    handle = if id == socket.assigns.take.id do
      socket.assigns.author.handle
    else
      # Simple for now: could be optimized
      YRepo.Repo.get!(YRepo.Schemas.User, YRepo.Repo.get!(YRepo.Schemas.Opinion, id).user_id).username
    end

    {:noreply, assign(socket, replying_to: id, replying_to_handle: handle)}
  end
  
  def handle_event("cancel_reply", _, socket) do
    {:noreply, assign(socket, replying_to: socket.assigns.take.id, replying_to_handle: socket.assigns.author.username)}
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
    # Fetch author once to avoid multiple lookups
    assigns = assign(assigns, :author, UserRepository.get_by_id!(assigns.node.opinion.user_id))
    
    ~H"""
    <div class={["relative flex gap-3", @node.opinion.depth == 0 && "pt-4 border-t border-[#1C1C1E] mt-4"]}>
      <div class="flex flex-col items-center shrink-0">
        <.link navigate={~p"/#{@author.username}"} phx-click-stop class="z-10">
          <YWeb.Layouts.bitmoji user={@author} size="sm" class="md:size-8 size-7" />
        </.link>
        
        <%= if @node.replies != [] do %>
          <div class="w-[1px] grow bg-[#2A2A2E] my-1"></div>
        <% end %>
      </div>

      <div class="flex-1 min-w-0">
        <div class="flex items-center gap-1.5 mb-0.5 overflow-hidden">
          <.link 
            navigate={~p"/#{@author.username}"} 
            phx-click-stop
            class="flex items-center gap-1.5 overflow-hidden group/author"
          >
            <span class="text-[#E5E5E7] font-bold text-sm group-hover/author:underline truncate">
              <%= @author.username %>
            </span>
            <span class="text-[#8E8E93] text-sm truncate"><%= @author.handle %></span>
          </.link>
          <span class="text-[#8E8E93] text-sm">·</span>
          <span class="text-[#8E8E93] text-sm truncate" title={@node.opinion.inserted_at}>
            <%= YWeb.Helpers.Time.relative(@node.opinion.inserted_at) %>
          </span>
        </div>

        <p class="text-[#E5E5E7] text-[15px] leading-relaxed break-words">
          <%= @node.opinion.body %>
        </p>

        <div class="flex items-center gap-5 mt-2 mb-4">
          <.opinion_action 
            icon="hero-chat-bubble-left" 
            count={Enum.count(@node.replies)} 
            hover_text="group-hover:text-[#0A84FF]" 
            phx_click="set_reply_target"
            phx_value_id={@node.opinion.id}
          />
          <.opinion_action 
            icon="hero-arrow-path" 
            hover_text="group-hover:text-[#30D158]" 
            phx_click="toggle_retake"
            phx_value_target_id={@node.opinion.id}
          />
          <.opinion_action 
            icon="hero-heart" 
            count={0} 
            active={false}
            hover_text="group-hover:text-[#FF375F]" 
            active_color="text-[#FF375F]"
            phx_click="toggle_agree"
            phx_value_target_type="opinion"
            phx_value_target_id={@node.opinion.id}
          />
          <.opinion_action 
            icon="hero-bookmark" 
            hover_text="group-hover:text-[#FFD60A]" 
            active_color="text-[#FFD60A]"
            phx_click="toggle_bookmark"
            phx_value_target_type="opinion"
            phx_value_target_id={@node.opinion.id}
          />
        </div>

        <%= if @replying_to == @node.opinion.id do %>
          <div class="mt-4 mb-4">
            <.reply_composer 
              id={"reply-composer-#{@node.opinion.id}"} 
              current_user={@current_user} 
              reply_body={@reply_body} 
              replying_to_handle={@replying_to_handle} 
            />
          </div>
        <% end %>

        <%= if !Enum.empty?(@node.replies) do %>
          <div class="space-y-4">
            <%= for reply <- @node.replies do %>
              <.opinion_node 
                node={reply} 
                current_user={@current_user} 
                replying_to={@replying_to} 
                replying_to_handle={@replying_to_handle} 
                reply_body={@reply_body} 
              />
            <% end %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  defp opinion_action(assigns) do
    ~H"""
    <button 
      class="group flex items-center transition-colors"
      phx-click={@phx_click}
      phx-value-id={assigns[:phx_value_id]}
      phx-value-target_type={assigns[:phx_value_target_type]}
      phx-value-target_id={assigns[:phx_value_target_id]}
    >
      <span class={[
        "size-4 text-[#48484A] transition-colors",
        @icon,
        @hover_text,
        assigns[:active] && (@active_color || "text-white")
      ]}></span>
      <%= if assigns[:count] && @count > 0 do %>
        <span class={["text-xs ml-1 text-[#8E8E93] transition-colors", @hover_text]}>
          <%= @count %>
        </span>
      <% end %>
    </button>
    """
  end

  defp reply_composer(assigns) do
    ~H"""
    <div class="py-4 border-b border-[#1C1C1E]">
      <%= if @replying_to_handle do %>
        <div class="flex items-center justify-between mb-3">
          <span class="text-[#0A84FF] text-sm">Replying to @<%= @replying_to_handle %></span>
          <button phx-click="cancel_reply" class="text-[#8E8E93] text-sm hover:underline">Cancel</button>
        </div>
      <% end %>
      
      <div class="flex gap-3">
        <YWeb.Layouts.bitmoji user={@current_user} size="sm" class="size-9 shrink-0" />
        <div class="flex-1 min-w-0">
          <form phx-change="validate_reply" phx-submit="post_reply">
            <textarea
              name="body"
              placeholder="Post your opinion"
              rows="3"
              class="bg-transparent outline-none border-none resize-none text-[#E5E5E7] text-[15px] placeholder-[#3A3A3C] w-full p-0"
            ><%= @reply_body %></textarea>
            
            <div class="flex items-center justify-end gap-4 mt-2">
              <span class="text-[#8E8E93] text-xs"><%= String.length(@reply_body || "") %>/250</span>
              <button 
                type="submit"
                disabled={String.length(@reply_body || "") == 0 || String.length(@reply_body || "") > 250}
                class="bg-white text-black text-sm font-semibold rounded-full px-4 py-1.5 disabled:opacity-30 transition-opacity"
              >
                Reply
              </button>
            </div>
          </form>
        </div>
      </div>
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
        "flex items-center gap-2 p-2 rounded-full hover:bg-white/5 transition-colors group",
        if(assigns[:active], do: @active_text || "text-white", else: "text-[#8E8E93]")
      ]}
    >
      <div class={["p-2 rounded-full transition-colors", @hover_bg]}>
        <span class={["size-5 transition-transform group-active:scale-95", @icon, @hover_text]}></span>
      </div>
      <%= if assigns[:count] && @count > 0 do %>
        <span class={["text-[13px] font-medium ml-[-4px]", @hover_text]}>
          <%= @count %> <span class="text-[#48484A] ml-0.5"><%= @label %></span>
        </span>
      <% else %>
         <span class={["text-[13px] font-medium ml-[-4px]", @hover_text]}>
          <%= @label %>
        </span>
      <% end %>
    </button>
    """
  end

  defp bitmoji(assigns) do
    YWeb.Layouts.bitmoji(assigns)
  end


end
