defmodule YWeb.Components.FeedCard do
  use YWeb, :html
  import YWeb.Layouts, only: [bitmoji: 1]

  attr :item, :map, required: true
  attr :current_user, :map, required: true
  attr :show_delete, :boolean, default: false
  attr :chat_click, :string, default: "navigate_to_take"
  attr :chat_value, :string, default: nil
  attr :border, :boolean, default: true

  def feed_card(assigns) do
    ~H"""
    <div 
      id={"card-#{@item.take.id}"}
      phx-click="navigate_to_take" 
      phx-value-take_id={@item.take.id}
      class={[
        "px-4 py-4 hover:bg-y-hover transition-colors duration-100 cursor-pointer group", 
        if(@border && !Map.get(@item, :thread_top), do: "border-b border-y-border")
      ]}
    >
      <%= if @item.type == :retake do %>
        <div class="flex items-center gap-2 mb-2 ml-10 text-y-muted">
          <span class="hero-arrow-path size-4"></span>
          <.link navigate={~p"/#{@item.retaker.username}"} phx-click-stop class="text-xs font-bold hover:underline">
            <%= @item.retaker.username %> retook
          </.link>
        </div>
      <% end %>

      <div class="flex gap-3">
        <div class="flex flex-col items-center shrink-0 relative">
          <%= if Map.get(@item, :thread_bottom) do %>
            <div class="absolute -top-4 w-0.5 h-4 bg-y-border"></div>
          <% end %>
          
          <.link navigate={~p"/#{@item.author.username}"} phx-click-stop class="z-10">
            <.bitmoji user={@item.author} size="md" />
          </.link>

          <%= if Map.get(@item, :thread_top) do %>
            <div class="w-0.5 grow bg-y-border my-1"></div>
          <% end %>
        </div>

        <div class="flex-1 min-w-0">
          <div class="flex items-center justify-between mb-0.5">
            <div class="flex items-center gap-1.5 overflow-hidden">
              <.link 
                navigate={~p"/#{@item.author.username}"} 
                phx-click-stop
                class="flex items-center gap-1.5 overflow-hidden group/author"
              >
                <span class="text-white font-bold text-sm group-hover/author:underline truncate">
                  <%= @item.author.username %>
                </span>
                <span class="text-y-muted text-sm truncate"><%= @item.author.handle %></span>
              </.link>
              <span class="text-y-muted text-sm">·</span>
              <span class="text-y-muted text-sm truncate" title={@item.take.inserted_at}>
                <%= YWeb.Helpers.Time.relative(@item.take.inserted_at) %>
              </span>
            </div>
            
            <%= if @show_delete && @current_user.id == @item.take.user_id do %>
              <button 
                phx-click="delete_take" 
                phx-value-take_id={@item.take.id}
                class="p-2 -mr-2 hover:bg-y-opinion/10 rounded-full transition-colors text-y-muted hover:text-y-opinion"
                title="Delete take"
              >
                <span class="hero-trash size-4"></span>
              </button>
            <% end %>
          </div>
          
          <%= if Map.get(@item, :replying_to_handle) && !Map.get(@item, :thread_bottom) do %>
            <div class="text-y-muted text-[13px] mb-1">
              Replying to <span class="text-y-opinion hover:underline cursor-pointer">@<%= Map.get(@item, :replying_to_handle) %></span>
            </div>
          <% end %>

          <%= if @item.type == :retake do %>
            <%!-- Retaker's comment (quote text) above the embedded card --%>
            <%= if @item.comment do %>
              <p class="text-white text-[15px] leading-relaxed break-words mt-1 mb-3">
                <%= @item.comment %>
              </p>
            <% end %>

            <%!-- Original take as an embedded quoted card --%>
            <div class="border border-y-border rounded-xl p-3 mt-1 hover:bg-white/[0.02] transition-colors">
              <div class="flex items-center gap-2 mb-1.5">
                <.bitmoji user={@item.author} size="xs" />
                <span class="text-white font-bold text-xs"><%= @item.author.username %></span>
                <span class="text-y-muted text-xs"><%= @item.author.handle %></span>
                <span class="text-y-muted text-xs">·</span>
                <span class="text-y-muted text-xs"><%= YWeb.Helpers.Time.relative(@item.take.inserted_at) %></span>
              </div>
              <p class="text-[#D1D1D6] text-[14px] leading-relaxed break-words">
                <%= @item.take.body %>
              </p>
            </div>
          <% else %>
            <p class="text-white text-[15px] leading-relaxed break-words mt-1">
              <%= @item.take.body %>
            </p>
          <% end %>

          <div class="flex items-center justify-between mt-4 max-w-sm">
            <.action_button
              icon="hero-chat-bubble-left"
              count={@item.opinion_count}
              hover_text="group-hover/btn:text-y-opinion"
              hover_bg="group-hover/btn:bg-y-opinion/10"
              phx_click={@chat_click}
              phx_value_take_id={@chat_value || @item.take.id}
            />
            <.action_button
              icon="hero-arrow-path"
              count={@item.retake_count}
              color={if @item.viewer_retook, do: "text-y-retake", else: "text-y-faint"}
              hover_text="group-hover/btn:text-y-retake"
              hover_bg="group-hover/btn:bg-y-retake/10"
              phx_click="open_retake_modal"
              phx_value_take_id={@item.take.id}
            />
            <.action_button
              icon="hero-heart"
              count={@item.agree_count}
              color={if @item.viewer_agreed, do: "text-y-agree", else: "text-y-faint"}
              hover_text="group-hover/btn:text-y-agree"
              hover_bg="group-hover/btn:bg-y-agree/10"
              phx_click="toggle_agree"
              phx_value_target_type="take"
              phx_value_target_id={@item.take.id}
            />
            <.action_button
              icon="hero-bookmark"
              color={if @item.viewer_bookmarked, do: "text-y-bookmark", else: "text-y-faint"}
              hover_text="group-hover/btn:text-y-bookmark"
              hover_bg="group-hover/btn:bg-y-bookmark/10"
              phx_click="toggle_bookmark"
              phx_value_target_type="take"
              phx_value_target_id={@item.take.id}
            />
          </div>
        </div>
      </div>
    </div>
    """
  end

  attr :icon, :string, required: true
  attr :count, :integer, default: nil
  attr :color, :string, default: "text-y-faint"
  attr :hover_text, :string, default: ""
  attr :hover_bg, :string, default: ""
  attr :phx_click, :string, default: nil
  attr :phx_value_take_id, :string, default: nil
  attr :phx_value_target_type, :string, default: nil
  attr :phx_value_target_id, :string, default: nil
  attr :rest, :global

  defp action_button(assigns) do
    ~H"""
    <button 
      phx-click={@phx_click}
      phx-value-take_id={@phx_value_take_id}
      phx-value-target_type={@phx_value_target_type}
      phx-value-target_id={@phx_value_target_id}
      class={["flex items-center gap-1 group/btn transition-colors", @color, @hover_text]}
    >
      <div class={["p-2 rounded-full transition-colors", @hover_bg]}>
        <span class={[@icon, "size-5"]}></span>
      </div>
      <%= if assigns[:count] && @count > 0 do %>
        <span class="text-xs font-medium pr-1"><%= @count %></span>
      <% end %>
    </button>
    """
  end
end
