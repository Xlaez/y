defmodule YWeb.Components.RetakeModal do
  use YWeb, :html
  import YWeb.Layouts, only: [bitmoji: 1]

  attr :modal, :map, required: true # %{take_id: id, type: :menu | :quote}
  attr :take, :map, required: true
  attr :current_user, :map, required: true
  attr :quote_body, :string, default: ""
  attr :viewer_retook, :boolean, default: false
  
  attr :quote_show_emoji_picker, :boolean, default: false
  attr :quote_emoji_search, :string, default: ""
  attr :quote_active_emoji_category, :string, default: "smileys"
  attr :quote_active_skin_tone, :string, default: ""

  def retake_modal(assigns) do
    ~H"""
    <div 
      id="retake-modal-overlay"
      class="fixed inset-0 z-[60] flex items-center justify-center p-4 sm:p-6"
    >
      <!-- Backdrop -->
      <div 
        class="absolute inset-0 bg-[#5B7083]/40 backdrop-blur-sm"
        phx-click="close_retake_modal"
      ></div>

      <!-- Modal Content -->
      <div class="relative w-full max-w-sm bg-black rounded-2xl overflow-hidden shadow-[0_8px_28px_rgba(255,255,255,0.1)] border border-[#2F3336]">
        <%= if @modal.type == :menu do %>
          <div class="p-1">
            <button 
              phx-click={if @viewer_retook, do: "undo_retake", else: "do_retake"}
              phx-value-take_id={@modal.take_id}
              class="w-full flex items-center gap-3 px-4 py-3 text-[#E5E5E7] hover:bg-[#1C1C1E] transition-colors rounded-xl group"
            >
              <span class={["hero-arrow-path size-5", if(@viewer_retook, do: "text-y-retake", else: "text-[#8E8E93] group-hover:text-y-retake")]}></span>
              <span class="font-bold text-base">
                <%= if @viewer_retook, do: "Undo Retake", else: "Retake" %>
              </span>
            </button>
            
            <button 
              phx-click="select_quote"
              class="w-full flex items-center gap-3 px-4 py-3 text-[#E5E5E7] hover:bg-[#1C1C1E] transition-colors rounded-xl group"
            >
              <span class="hero-pencil-square size-5 text-[#8E8E93] group-hover:text-y-retake"></span>
              <span class="font-bold text-base">Quote Take</span>
            </button>
          </div>
        <% else %>
          <div class="flex flex-col max-h-[90vh] bg-black">
            <div class="px-4 py-2 border-b border-[#2F3336] flex items-center justify-between sticky top-0 bg-black z-20">
              <button phx-click="close_retake_modal" class="text-white hover:bg-white/10 p-2 rounded-full transition-colors">
                <span class="hero-x-mark size-5"></span>
              </button>
            </div>

            <div class="overflow-y-auto scrollbar-none">
              <YWeb.Layouts.take_composer
                id="quote-composer"
                current_user={@current_user}
                placeholder="Add a comment"
                submit_event="submit_quote_take"
                change_event="validate_quote"
                value={@quote_body}
                submit_label="Retake"
                show_emoji_picker={assigns[:quote_show_emoji_picker] || false}
                emoji_search={assigns[:quote_emoji_search] || ""}
                active_emoji_category={assigns[:quote_active_emoji_category] || "smileys"}
                active_skin_tone={assigns[:quote_active_skin_tone] || ""}
                on_toggle_emoji="quote_toggle_emoji_picker"
                on_emoji_search="quote_emoji_search_change"
                on_set_category="quote_set_emoji_category"
                on_set_tone="quote_set_skin_tone"
                on_insert_emoji="quote_insert_emoji"
                class="px-4 py-4"
              >
                <:footer>
                  <!-- Original Take Preview -->
                  <div class="mt-3 border border-[#2F3336] rounded-2xl p-3 bg-black">
                    <div class="flex items-center gap-2 mb-1">
                      <YWeb.Layouts.bitmoji user={@take.author} size="xs" />
                      <span class="text-white font-bold text-sm truncate"><%= @take.author.username %></span>
                      <span class="text-[#71767B] text-sm truncate"><%= @take.author.handle %></span>
                    </div>
                    <p class="text-white text-sm leading-relaxed line-clamp-4">
                      <%= @take.body %>
                    </p>
                  </div>
                </:footer>
              </YWeb.Layouts.take_composer>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
