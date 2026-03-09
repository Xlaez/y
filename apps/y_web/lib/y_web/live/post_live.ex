defmodule YWeb.PostLive do
  use YWeb, :live_view

  def mount(%{"id" => _id}, _session, socket) do
    {:ok, assign(socket, take: nil, opinions: [])}
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-2xl mx-auto py-8 px-4">
      <%= if @take do %>
        <div class="p-8 bg-white rounded-2xl shadow-sm border border-gray-100 mb-8">
          <p class="text-2xl"><%= @take.body %></p>
        </div>
      <% else %>
        <div class="text-center py-12">
          <p class="text-gray-500">Take not found or loading...</p>
        </div>
      <% end %>

      <div class="space-y-4">
        <h2 class="text-xl font-bold">Opinions</h2>
        <p class="text-gray-500">No opinions yet.</p>
      </div>
    </div>
    """
  end
end
