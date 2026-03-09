defmodule YWeb.ProfileLive do
  use YWeb, :live_view

  def mount(%{"username" => username}, _session, socket) do
    {:ok, assign(socket, username: username, takes: [])}
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-2xl mx-auto py-8 px-4">
      <div class="flex items-center space-x-4 mb-8">
        <div class="w-20 h-20 bg-gradient-to-br from-indigo-500 to-purple-600 rounded-full flex items-center justify-center text-white text-2xl font-bold">
          <%= String.at(@username, 0) |> String.upcase() %>
        </div>
        <div>
          <h1 class="text-3xl font-bold">@<%= @username %></h1>
          <p class="text-gray-500">Anonymous Content Creator</p>
        </div>
      </div>

      <div class="border-t border-gray-100 pt-8">
        <div class="space-y-4">
          <p class="text-center py-8 text-gray-500">No takes from @<%= @username %> yet.</p>
        </div>
      </div>
    </div>
    """
  end
end
