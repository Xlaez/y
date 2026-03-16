defmodule YWeb.TakeLive do
  use YWeb, :live_view


  def mount(%{"id" => id} = _params, _session, socket) do
    take_repo = Application.get_env(:y_core, :repositories)[:take]
    opinion_repo = Application.get_env(:y_core, :repositories)[:opinion]

    case take_repo.get_with_user(id) do
      {:ok, take} ->
        opinions = opinion_repo.list_by_take(id)
        {:ok, assign_take_data(socket, take, opinions), layout: {YWeb.Layouts, :authenticated}}

      _ ->
        # Fallback to DummyData for UI verification
        dummy_take = Enum.find(YWeb.DummyData.takes(), fn t -> t.id == id end)
        if dummy_take do
          {:ok, assign_take_data(socket, dummy_take, []), layout: {YWeb.Layouts, :authenticated}}
        else
          {:ok, push_navigate(socket, to: "/home")}
        end
    end
  end

  defp assign_take_data(socket, take, opinions) do
    socket
    |> assign(active_tab: :home)
    |> assign(take: take)
    |> assign(opinions: opinions)
    |> assign(reply_body: "")
    |> assign(replying_to: nil)
    |> assign(error: nil)
  end

  def handle_event("validate_reply", %{"body" => body}, socket) do
    {:noreply, assign(socket, reply_body: body)}
  end

  def handle_event("post_reply", %{"body" => body}, socket) do
    opinion_repo = Application.get_env(:y_core, :repositories)[:opinion]
    user = socket.assigns.current_user
    take = socket.assigns.take
    parent_opinion_id = socket.assigns.replying_to

    params = %{
      user_id: user.id,
      body: body,
      parent_take_id: if(is_nil(parent_opinion_id), do: take.id),
      parent_opinion_id: parent_opinion_id
    }

    case opinion_repo.create(params) do
      {:ok, _opinion} ->
        # Refresh opinions
        opinions = opinion_repo.list_by_take(take.id)
        {:noreply,
         socket
         |> assign(opinions: opinions)
         |> assign(reply_body: "")
         |> assign(replying_to: nil)
         |> put_flash(:info, "Your opinion was shared!")}

      {:error, _changeset} ->
        {:noreply, assign(socket, error: "Could not post your reply")}
    end
  end

  def handle_event("set_reply_target", %{"id" => id}, socket) do
    {:noreply, assign(socket, replying_to: id)}
  end
  
  def handle_event("cancel_reply", _, socket) do
    {:noreply, assign(socket, replying_to: nil, reply_body: "")}
  end

  defp opinion_to_take_adapter(opinion) do
    %{
      id: opinion.id,
      user: opinion.user,
      body: opinion.body,
      inserted_at: opinion.inserted_at,
      type: :opinion,
      opinion_count: 0,
      retake_count: 0,
      agreed_count: 0,
      parent: nil
    }
  end

  attr :icon, :string, required: true
  attr :count, :integer, default: nil
  attr :label, :string, default: nil

  defp action_button_hero(assigns) do
    ~H"""
    <button class="flex items-center gap-1.5 p-2.5 rounded-full hover:bg-y-hover transition-colors text-y-faint group">
      <span class={["size-5 transition-transform group-active:scale-95", @icon]}></span>
      <%= if @count do %>
        <span class="text-sm font-medium"><%= @count %></span>
      <% end %>
    </button>
    """
  end
end
