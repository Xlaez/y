defmodule YWeb.SeedPhraseLive do
  use YWeb, :live_view

  def mount(params, _session, socket) do
    words = (params["words"] || "") |> String.split("-", trim: true)
    
    if Enum.count(words) != 12 do
      {:ok, push_navigate(socket, to: ~p"/signup")}
    else
      {:ok, assign(socket, words: words, confirmed: false)}
    end
  end

  def handle_event("toggle_confirm", %{"value" => "on"}, socket) do
    {:noreply, assign(socket, confirmed: true)}
  end

  def handle_event("toggle_confirm", _, socket) do
    {:noreply, assign(socket, confirmed: false)}
  end

  def handle_event("continue", _, socket) do
    {:noreply, push_navigate(socket, to: "/home")}
  end
end
