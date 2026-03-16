defmodule YWeb.Components.FeedCard do
  use YWeb, :html
  import YWeb.Layouts, only: [bitmoji: 1]

  attr :item, :map, required: true
  attr :current_user, :map, required: true
  attr :show_delete, :boolean, default: false

  def feed_card(assigns) do
    ~H"""
    <div 
      id={"card-#{@item.take.id}"}
      phx-click="navigate_to_take" 
      phx-value-take_id={@item.take.id}
      class="px-4 py-4 hover:bg-y-hover transition-colors duration-100 cursor-pointer group border-b border-y-border"
    >
      <%= if @item.type == :retake do %>
        <div class="flex items-center gap-2 mb-2 ml-10 text-y-muted">
          <span class="hero-arrow-path size-4"></span>
          <span class="text-xs font-bold hover:underline"><%= @item.retaker.username %> retook</span>
        </div>
      <% end %>

      <div class="flex gap-3">
        <.bitmoji user={@item.author} size="md" />

        <div class="flex-1 min-w-0">
          <div class="flex items-center justify-between mb-0.5">
            <div class="flex items-center gap-1.5 overflow-hidden">
              <span class="text-white font-bold text-sm hover:underline truncate">
                <%= @item.author.username %>
              </span>
              <span class="text-y-muted text-sm truncate"><%= @item.author.handle %></span>
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

          <%= if @item.type == :retake && @item.comment do %>
             <p class="text-white text-[15px] leading-relaxed break-words mt-1 mb-3">
              <%= @item.comment %>
            </p>
          <% end %>

          <p class={"text-white text-[15px] leading-relaxed break-words #{if @item.type == :retake, do: "mt-0", else: "mt-1"}"}>
            <%= @item.take.body %>
          </p>

          <div class="flex items-center justify-between mt-4 max-w-sm">
            <.action_button
              icon="hero-chat-bubble-left"
              count={@item.opinion_count}
              hover_text="group-hover/btn:text-y-opinion"
              hover_bg="group-hover/btn:bg-y-opinion/10"
              phx_click="navigate_to_take"
              phx_value_take_id={@item.take.id}
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

  defp action_button(assigns) do
    ~H"""
    <button 
      phx-click={@phx_click}
      phx-value-take_id={assigns[:phx_value_take_id]}
      phx-value-target_type={assigns[:phx_value_target_type]}
      phx-value-target_id={assigns[:phx_value_target_id]}
      class={["flex items-center gap-1 group/btn transition-colors", @color || "text-y-faint", @hover_text]}
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
