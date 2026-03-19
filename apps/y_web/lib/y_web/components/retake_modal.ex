defmodule YWeb.Components.RetakeModal do
  use YWeb, :html
  import YWeb.Layouts, only: [bitmoji: 1]

  attr :modal, :map, required: true # %{take_id: id, type: :menu | :quote}
  attr :take, :map, required: true
  attr :current_user, :map, required: true
  attr :quote_body, :string, default: ""
  attr :viewer_retook, :boolean, default: false

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
          <div class="flex flex-col max-h-[90vh]">
            <div class="flex items-center justify-between p-4 bg-black/80 sticky top-0 z-10">
              <button phx-click="close_retake_modal" class="text-white hover:bg-white/10 p-2 rounded-full transition-colors">
                <span class="hero-x-mark size-5"></span>
              </button>
              <button 
                phx-click="submit_quote_take"
                phx-value-take_id={@modal.take_id}
                disabled={String.length(@quote_body || "") == 0 || String.length(@quote_body || "") > 250}
                class="bg-white text-black text-sm font-bold rounded-full px-4 py-1.5 disabled:opacity-50 transition-opacity"
              >
                Retake
              </button>
            </div>

            <div class="p-4 overflow-y-auto scrollbar-none">
              <div class="flex gap-3">
                <.bitmoji user={@current_user} size="md" class="shrink-0" />
                <div class="flex-1 min-w-0">
                  <textarea
                    id="quote-textarea"
                    phx-hook="TextAreaAutosize"
                    phx-change="validate_quote"
                    name="body"
                    placeholder="Add a comment"
                    autofocus
                    class="w-full bg-transparent border-none text-white text-xl resize-none focus:ring-0 focus:outline-none p-0 placeholder-[#71767B] min-h-[100px]"
                  ><%= @quote_body %></textarea>

                  <!-- Original Take Preview -->
                  <div class="mt-3 border border-[#2F3336] rounded-2xl p-3 bg-black">
                    <div class="flex items-center gap-2 mb-1">
                      <.bitmoji user={@take.author} size="xs" />
                      <span class="text-white font-bold text-sm truncate"><%= @take.author.username %></span>
                      <span class="text-[#71767B] text-sm truncate"><%= @take.author.handle %></span>
                    </div>
                    <p class="text-white text-sm leading-relaxed line-clamp-4">
                      <%= @take.body %>
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
