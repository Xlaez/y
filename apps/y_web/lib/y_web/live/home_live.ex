defmodule YWeb.HomeLive do
  use YWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(active_tab: :home)
     |> assign(takes: YWeb.DummyData.takes())
     |> assign(compose_body: "")
     |> assign(who_to_follow: Enum.take(YWeb.DummyData.users(), 3)),
     layout: {YWeb.Layouts, :authenticated}}
  end

  def handle_event("validate_compose", %{"body" => body}, socket) do
    {:noreply, assign(socket, compose_body: body)}
  end

  def handle_event("post_take", _, socket) do
    # Dummy post logic
    {:noreply,
     socket
     |> put_flash(:info, "Your take was shared!")
     |> assign(compose_body: "")}
  end

  def handle_event("toggle_agree", %{"id" => _id}, socket) do
    {:noreply, socket}
  end
end
