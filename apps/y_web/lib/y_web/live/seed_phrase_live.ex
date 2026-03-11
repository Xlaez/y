defmodule YWeb.SeedPhraseLive do
  use YWeb, :live_view

  def mount(_params, _session, socket) do
    words = [
      "abandon", "ability", "able", "about", 
      "above", "absent", "absorb", "abstract", 
      "absurd", "abuse", "access", "accident"
    ]
    {:ok, assign(socket, words: words, confirmed: false)}
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
