defmodule YWeb.TakeLive do
  use YWeb, :live_view
  use YWeb.Live.RecommendationEvents

  alias YCore.Content.OpinionService
  alias YRepo.Repositories.{TakeRepository, OpinionRepository, AgreeRepository, BookmarkRepository, UserRepository, RetakeRepository, NotificationRepository}
  @notification_repo NotificationRepository

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
         |> assign(show_emoji_picker: false)
         |> assign(emoji_search: "")
         |> assign(active_emoji_category: "smileys")
         |> assign(active_skin_tone: "")
         |> assign(replying_to: id)
         |> assign(replying_to_handle: author.username)
         |> assign(retake_modal: nil)
         |> assign(quote_body: "")
         |> assign(quote_show_emoji_picker: false)
         |> assign(quote_emoji_search: "")
         |> assign(quote_active_emoji_category: "smileys")
         |> assign(quote_active_skin_tone: "")
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

    case OpinionService.post(params, OpinionRepository, TakeRepository, UserRepository, @notification_repo) do
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

    case AgreeRepository.toggle(user_id, target_type, id, @notification_repo) do
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

  def handle_event("toggle_emoji_picker", _, socket) do
    {:noreply, assign(socket, show_emoji_picker: !socket.assigns.show_emoji_picker)}
  end

  def handle_event("close_emoji_picker", _, socket) do
    {:noreply, assign(socket, show_emoji_picker: false)}
  end

  def handle_event("set_emoji_category", %{"category" => id}, socket) do
    {:noreply, assign(socket, active_emoji_category: id)}
  end

  def handle_event("emoji_search_change", %{"value" => query}, socket) do
    {:noreply, assign(socket, emoji_search: query)}
  end

  def handle_event("set_skin_tone", %{"tone" => tone}, socket) do
    {:noreply, assign(socket, active_skin_tone: tone)}
  end

  def handle_event("insert_emoji", %{"emoji" => emoji}, socket) do
    body = socket.assigns.reply_body || ""
    if String.length(body) < 250 do
      toned_emoji = YWeb.EmojiData.apply_tone(emoji, socket.assigns.active_skin_tone)
      new_body = body <> toned_emoji
      {:noreply, assign(socket, reply_body: new_body, reply_char_count: String.length(new_body))}
    else
      {:noreply, socket}
    end
  end

  def handle_event("open_retake_modal", %{"take_id" => id}, socket) do
    {:noreply,
      socket
      |> assign(retake_modal: %{take_id: id, type: :menu})
      |> assign(quote_show_emoji_picker: false)
      |> assign(quote_emoji_search: "")
    }
  end

  def handle_event("close_retake_modal", _, socket) do
    {:noreply, assign(socket, retake_modal: nil, quote_body: "")}
  end

  def handle_event("select_quote", _, socket) do
    modal = socket.assigns.retake_modal
    {:noreply, assign(socket, retake_modal: %{modal | type: :quote})}
  end

  def handle_event("validate_quote", %{"body" => body}, socket) do
    {:noreply, assign(socket, quote_body: body)}
  end

  def handle_event("do_retake", %{"take_id" => id}, socket) do
    user_id = socket.assigns.current_user.id
    IO.inspect({:do_retake, user_id, id}, label: "RETAKE_EVENT")

    case YCore.Content.RetakeService.toggle_retake(user_id, id, RetakeRepository, TakeRepository, UserRepository, @notification_repo) do
      {:ok, _} ->
        {:noreply,
         socket
         |> assign(retake_modal: nil)
         |> refresh_take_data()}
      {:error, :cannot_retake_own} ->
        {:noreply,
         socket
         |> assign(retake_modal: nil)
         |> put_flash(:error, "You cannot retake your own take")}
      error ->
        IO.inspect(error, label: "RETAKE_ERROR")
        {:noreply, socket}
    end
  end

  def handle_event("undo_retake", %{"take_id" => id}, socket) do
    user_id = socket.assigns.current_user.id
    IO.inspect({:undo_retake, user_id, id}, label: "RETAKE_EVENT")

    case YCore.Content.RetakeService.toggle_retake(user_id, id, RetakeRepository, TakeRepository, UserRepository, @notification_repo) do
      {:ok, _} ->
        {:noreply,
         socket
         |> assign(retake_modal: nil)
         |> refresh_take_data()}
      error ->
        IO.inspect(error, label: "RETAKE_ERROR")
        {:noreply, socket}
    end
  end

  def handle_event("submit_quote_take", %{"body" => body}, socket) do
    user_id = socket.assigns.current_user.id
    id = socket.assigns.retake_modal.take_id

    case YCore.Content.RetakeService.retake(user_id, id, body, RetakeRepository, TakeRepository, UserRepository, @notification_repo) do
      {:ok, _} ->
        {:noreply,
         socket
         |> assign(retake_modal: nil, quote_body: "")
         |> put_flash(:info, "Your quote was shared!")
         |> refresh_take_data()}
      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Could not quote: #{reason}")}
    end
  end

  # Quote Emoji Handlers
  def handle_event("quote_toggle_emoji_picker", _, socket) do
    {:noreply, assign(socket, quote_show_emoji_picker: !socket.assigns.quote_show_emoji_picker)}
  end

  def handle_event("quote_emoji_search_change", %{"value" => value}, socket) do
    {:noreply, assign(socket, quote_emoji_search: value)}
  end

  def handle_event("quote_set_emoji_category", %{"category" => cat}, socket) do
    {:noreply, assign(socket, quote_active_emoji_category: cat)}
  end

  def handle_event("quote_set_skin_tone", %{"tone" => tone}, socket) do
    {:noreply, assign(socket, quote_active_skin_tone: tone)}
  end

  def handle_event("quote_insert_emoji", %{"emoji" => _emoji}, socket) do
    {:noreply,
      socket
      |> assign(quote_show_emoji_picker: false)
    }
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
    |> assign(retake_count: RetakeRepository.count_for_take(id))
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
          <%!-- Retake for opinions not supported by schema yet --%>
          <.opinion_action
            icon="hero-arrow-path"
            hover_text="group-hover:text-[#30D158]"
            phx_click=""
            phx_value_target_id={@node.opinion.id}
            class="opacity-20 cursor-default"
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
              show_emoji_picker={@show_emoji_picker}
              emoji_search={@emoji_search}
              active_emoji_category={@active_emoji_category}
              active_skin_tone={@active_skin_tone}
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
                show_emoji_picker={@show_emoji_picker}
                emoji_search={@emoji_search}
                active_emoji_category={@active_emoji_category}
                active_skin_tone={@active_skin_tone}
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
      class={["group flex items-center transition-colors", assigns[:class]]}
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

  attr :id, :string, required: true
  attr :current_user, :map, required: true
  attr :reply_body, :string, required: true
  attr :replying_to_handle, :string, default: nil
  attr :show_emoji_picker, :boolean, default: false
  attr :emoji_search, :string, default: ""
  attr :active_emoji_category, :string, default: "smileys"
  attr :active_skin_tone, :string, default: ""

  defp reply_composer(assigns) do
    ~H"""
    <div class="py-4 border-b border-[#1C1C1E] relative">
      <%= if @replying_to_handle do %>
        <div class="flex items-center justify-between mb-3 px-1">
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

            <div class="flex items-center justify-between mt-2 relative">
              <div class="flex items-center gap-1">
                <button
                  type="button"
                  phx-click="toggle_emoji_picker"
                  class={"p-2 rounded-lg transition-colors #{if @show_emoji_picker,
                    do: "text-white bg-[#2A2A2E]", else: "text-[#8E8E93] hover:text-[#E5E5E7] hover:bg-[#1C1C1E]"}"}
                  title="Emoji"
                >
                  <span class="hero-face-smile size-5"></span>
                </button>

                <%= if @show_emoji_picker do %>
                  <div
                    id={"#{@id}-emoji-picker"}
                    phx-hook="EmojiPicker"
                    class="absolute top-[calc(100%+4px)] left-0 w-[340px] max-h-[380px] bg-[#1C1C1E] rounded-2xl shadow-[0_4px_24px_rgba(0,0,0,0.6)] border border-[#2A2A2E] overflow-hidden z-50 flex flex-col"
                  >
                    <!-- Search bar -->
                    <div class="px-3 pt-3 pb-2">
                        <div class="flex items-center gap-2 bg-[#2A2A2E] rounded-xl px-3 py-2">
                            <span class="hero-magnifying-glass size-[14px] text-[#8E8E93]"></span>
                            <input
                            type="text"
                            placeholder="Search emoji..."
                            value={@emoji_search}
                            phx-keyup="emoji_search_change"
                            phx-value-value={@emoji_search}
                            class="bg-transparent outline-none text-[#E5E5E7] text-sm placeholder-[#48484A] w-full"
                            />
                        </div>
                    </div>

                    <!-- Category tabs -->
                    <div class="flex items-center justify-between px-3 pb-2">
                        <div class="flex gap-1 overflow-x-auto scrollbar-none">
                            <%= for cat <- YWeb.EmojiData.categories() do %>
                                <button
                                type="button"
                                phx-click="set_emoji_category"
                                phx-value-category={cat.id}
                                class={"w-8 h-8 rounded-lg flex items-center justify-center text-base flex-shrink-0
                                        transition-colors #{if @active_emoji_category == cat.id,
                                            do: "bg-[#3A3A3C]", else: "hover:bg-[#2A2A2E]"}"}
                                title={cat.label}
                                >
                                <%= cat.icon %>
                                </button>
                            <% end %>
                        </div>

                        <!-- Skin tone selector -->
                        <div class="flex gap-0.5 ml-2 pl-2 border-l border-[#2A2A2E]">
                            <%= for tone <- YWeb.EmojiData.skin_tones() do %>
                                <button
                                    type="button"
                                    phx-click="set_skin_tone"
                                    phx-value-tone={tone.id}
                                    class={"w-6 h-6 rounded-md flex items-center justify-center text-xs transition-transform hover:scale-110
                                            #{if @active_skin_tone == tone.id, do: "bg-[#3A3A3C] ring-1 ring-white/20", else: ""}"}
                                    title={tone.label}
                                >
                                    <%= tone.icon %>
                                </button>
                            <% end %>
                        </div>
                    </div>

                    <!-- Emoji grid -->
                    <div class="overflow-y-auto px-3 pb-3 scrollbar-none" style="max-height: 280px;">
                      <%= if @emoji_search != "" do %>
                        <!-- Search results -->
                        <p class="text-[#8E8E93] text-xs mb-2 uppercase tracking-wider sticky top-0 bg-[#1C1C1E] py-1">Search results</p>
                        <div class="grid grid-cols-8 gap-1">
                          <%= for emoji <- YWeb.EmojiData.search(@emoji_search) do %>
                            <% toned_emoji = YWeb.EmojiData.apply_tone(emoji, @active_skin_tone) %>
                            <button
                              type="button"
                              phx-click="insert_emoji"
                              phx-value-emoji={emoji}
                              class="w-9 h-9 rounded-lg flex items-center justify-center text-xl
                                     hover:bg-[#3A3A3C] transition-colors"
                            >
                              <%= toned_emoji %>
                            </button>
                          <% end %>
                        </div>
                        <%= if YWeb.EmojiData.search(@emoji_search) == [] do %>
                          <p class="text-[#8E8E93] text-sm text-center py-8">No emoji found</p>
                        <% end %>
                      <% else %>
                        <!-- Category view -->
                        <%= for cat <- YWeb.EmojiData.categories() do %>
                          <% active = @active_emoji_category == cat.id %>
                          <%= if active do %>
                            <p class="text-[#8E8E93] text-xs mb-2 uppercase tracking-wider sticky top-0 bg-[#1C1C1E] py-1">
                              <%= cat.label %>
                            </p>
                            <div class="grid grid-cols-8 gap-1">
                              <%= for emoji <- cat.emojis do %>
                                <% toned_emoji = YWeb.EmojiData.apply_tone(emoji, @active_skin_tone) %>
                                <button
                                  type="button"
                                  phx-click="insert_emoji"
                                  phx-value-emoji={emoji}
                                  class="w-9 h-9 rounded-lg flex items-center justify-center text-xl
                                         hover:bg-[#3A3A3C] active:scale-95 transition-all duration-75"
                                >
                                  <%= toned_emoji %>
                                </button>
                              <% end %>
                            </div>
                          <% end %>
                        <% end %>
                      <% end %>
                    </div>
                  </div>
                <% end %>
              </div>

              <div class="flex items-center gap-4">
                <span class="text-[#8E8E93] text-xs"><%= String.length(@reply_body || "") %>/250</span>
                <button
                  type="submit"
                  disabled={String.length(@reply_body || "") == 0 || String.length(@reply_body || "") > 250}
                  class="bg-white text-black text-sm font-semibold rounded-full px-4 py-1.5 disabled:opacity-30 transition-opacity"
                >
                  Reply
                </button>
              </div>
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



end
