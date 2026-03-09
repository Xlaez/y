defmodule YWeb.FeedLive do
  use YWeb, :live_view

  def mount(_params, _session, socket) do
    # In a real app, we would load the feed from y_core
    {:ok, assign(socket, :takes, [])}
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-2xl mx-auto py-8 px-4">
      <h1 class="text-3xl font-bold mb-8">Your Feed</h1>
      
      <div class="space-y-4">
        <%= if Enum.empty?(@takes) do %>
          <div class="text-center py-12 bg-gray-50 rounded-xl border-2 border-dashed border-gray-200">
            <p class="text-gray-500">No takes yet. Be the first to share one!</p>
          </div>
        <% else %>
          <%= for take <- @takes do %>
            <div class="p-6 bg-white rounded-xl shadow-sm border border-gray-100">
              <p class="text-lg"><%= take.body %></p>
            </div>
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end
end
