defmodule YWeb.HomeLive do
  use YWeb, :live_view
  use YWeb.Live.RecommendationEvents

  alias YCore.Content.TakeService
  alias YCore.Content.FeedService
  alias YRepo.Repositories.{TakeRepository, FollowRepository, AgreeRepository, BookmarkRepository, UserRepository, OpinionRepository, RetakeRepository, NotificationRepository}
  @notification_repo NotificationRepository

  def mount(_params, _session, socket) do
    if connected?(socket) do
      # Subscribe to updates could go here in a real app
    end

    current_user = socket.assigns.current_user
    feed = fetch_feed(current_user.id)

    {:ok,
     socket
     |> assign(active_tab: :home)
     |> assign(feed: feed)
     |> assign(compose_body: "")
     |> assign(compose_char_count: 0)
     |> assign(show_emoji_picker: false)
     |> assign(emoji_search: "")
     |> assign(active_emoji_category: "smileys")
     |> assign(active_skin_tone: "")
     |> assign(retake_modal: nil)
     |> assign(quote_body: "")
     |> assign(quote_show_emoji_picker: false)
     |> assign(quote_emoji_search: "")
     |> assign(quote_active_emoji_category: "smileys")
     |> assign(quote_active_skin_tone: "")
     |> assign(who_to_follow: socket.assigns[:who_to_follow] || []),
     layout: {YWeb.Layouts, :authenticated}}
  end

  def handle_event("validate_compose", %{"body" => body}, socket) do
    {:noreply, assign(socket, compose_body: body, compose_char_count: String.length(body))}
  end

  def handle_event("post_take", %{"body" => body}, socket) do
    user_id = socket.assigns.current_user.id

    case TakeService.post(user_id, body, TakeRepository) do
      {:ok, _take} ->
        {:noreply,
         socket
         |> put_flash(:info, "Your take was shared!")
         |> assign(compose_body: "", compose_char_count: 0)
         |> refresh_feed()}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Could not share take: #{reason}")}
    end
  end

  def handle_event("toggle_agree", %{"target_type" => type, "target_id" => id}, socket) do
    user_id = socket.assigns.current_user.id
    target_type = String.to_existing_atom(type)

    case AgreeRepository.toggle(user_id, target_type, id, @notification_repo) do
      {:ok, _} -> {:noreply, refresh_feed(socket)}
      _ -> {:noreply, socket}
    end
  end

  def handle_event("toggle_bookmark", %{"target_type" => type, "target_id" => id}, socket) do
    user_id = socket.assigns.current_user.id
    target_type = String.to_existing_atom(type)

    case BookmarkRepository.toggle(user_id, target_type, id) do
      {:ok, _} -> {:noreply, refresh_feed(socket)}
      _ -> {:noreply, socket}
    end
  end

  def handle_event("navigate_to_take", %{"take_id" => id}, socket) do
    {:noreply, push_navigate(socket, to: ~p"/takes/#{id}")}
  end

  def handle_event("toggle_emoji_picker", _, socket) do
    {:noreply, assign(socket, show_emoji_picker: !socket.assigns.show_emoji_picker)}
  end

  def handle_event("close_emoji_picker", _, socket) do
    {:noreply, assign(socket, show_emoji_picker: false)}
  end

  def handle_event("set_emoji_category", %{"category" => id}, socket) do
    {:noreply, assign(socket, active_emoji_category: id)}
  end

  def handle_event("emoji_search_change", %{"value" => query}, socket) do
    {:noreply, assign(socket, emoji_search: query)}
  end

  def handle_event("set_skin_tone", %{"tone" => tone}, socket) do
    {:noreply, assign(socket, active_skin_tone: tone)}
  end

  def handle_event("insert_emoji", %{"emoji" => emoji}, socket) do
    body = socket.assigns.compose_body || ""
    if String.length(body) < 250 do
      toned_emoji = YWeb.EmojiData.apply_tone(emoji, socket.assigns.active_skin_tone)
      new_body = body <> toned_emoji
      {:noreply, assign(socket, compose_body: new_body, compose_char_count: String.length(new_body))}
    else
      {:noreply, socket}
    end
  end

  def handle_event("open_retake_modal", %{"take_id" => id}, socket) do
    {:noreply, 
      socket
      |> assign(retake_modal: %{take_id: id, type: :menu})
      |> assign(quote_show_emoji_picker: false)
      |> assign(quote_emoji_search: "")
    }
  end

  def handle_event("close_retake_modal", _, socket) do
    {:noreply, assign(socket, retake_modal: nil, quote_body: "")}
  end

  def handle_event("select_quote", _, socket) do
    modal = socket.assigns.retake_modal
    {:noreply, assign(socket, retake_modal: %{modal | type: :quote})}
  end

  def handle_event("validate_quote", %{"body" => body}, socket) do
    {:noreply, assign(socket, quote_body: body)}
  end

  def handle_event("do_retake", %{"take_id" => id}, socket) do
    user_id = socket.assigns.current_user.id
    IO.inspect({:do_retake, user_id, id}, label: "RETAKE_EVENT")
    
    case YCore.Content.RetakeService.toggle_retake(user_id, id, RetakeRepository, TakeRepository, UserRepository, @notification_repo) do
      {:ok, _} -> 
        {:noreply, 
         socket 
         |> assign(retake_modal: nil)
         |> refresh_feed()}
      {:error, :cannot_retake_own} ->
        {:noreply, 
         socket
         |> assign(retake_modal: nil)
         |> put_flash(:error, "You cannot retake your own take")}
      error -> 
        IO.inspect(error, label: "RETAKE_ERROR")
        {:noreply, socket}
    end
  end

  def handle_event("undo_retake", %{"take_id" => id}, socket) do
    user_id = socket.assigns.current_user.id
    IO.inspect({:undo_retake, user_id, id}, label: "RETAKE_EVENT")
    
    case YCore.Content.RetakeService.toggle_retake(user_id, id, RetakeRepository, TakeRepository, UserRepository, @notification_repo) do
      {:ok, _} -> 
        {:noreply, 
         socket 
         |> assign(retake_modal: nil)
         |> refresh_feed()}
      error -> 
        IO.inspect(error, label: "RETAKE_ERROR")
        {:noreply, socket}
    end
  end

  def handle_event("submit_quote_take", %{"body" => body}, socket) do
    user_id = socket.assigns.current_user.id
    id = socket.assigns.retake_modal.take_id
    
    case YCore.Content.RetakeService.retake(user_id, id, body, RetakeRepository, TakeRepository, UserRepository, @notification_repo) do
      {:ok, _} -> 
        {:noreply, 
         socket 
         |> assign(retake_modal: nil, quote_body: "")
         |> put_flash(:info, "Your quote was shared!")
         |> refresh_feed()}
      {:error, reason} -> 
        {:noreply, put_flash(socket, :error, "Could not quote: #{reason}")}
    end
  end

  # Quote Emoji Handlers
  def handle_event("quote_toggle_emoji_picker", _, socket) do
    {:noreply, assign(socket, quote_show_emoji_picker: !socket.assigns.quote_show_emoji_picker)}
  end

  def handle_event("quote_emoji_search_change", %{"value" => value}, socket) do
    {:noreply, assign(socket, quote_emoji_search: value)}
  end

  def handle_event("quote_set_emoji_category", %{"category" => cat}, socket) do
    {:noreply, assign(socket, quote_active_emoji_category: cat)}
  end

  def handle_event("quote_set_skin_tone", %{"tone" => tone}, socket) do
    {:noreply, assign(socket, quote_active_skin_tone: tone)}
  end

  def handle_event("quote_insert_emoji", %{"emoji" => emoji}, socket) do
    {:noreply, 
      socket 
      |> assign(quote_body: socket.assigns.quote_body <> emoji)
      |> assign(quote_show_emoji_picker: false)
    }
  end

  defp fetch_feed(user_id) do
    repos = %{
      take_repo: TakeRepository,
      follow_repo: FollowRepository,
      agree_repo: AgreeRepository,
      bookmark_repo: BookmarkRepository,
      user_repo: UserRepository,
      opinion_repo: OpinionRepository,
      retake_repo: RetakeRepository
    }
    FeedService.build_feed(user_id, [limit: 20], repos)
  end

  defp refresh_feed(socket) do
    assign(socket, feed: fetch_feed(socket.assigns.current_user.id))
  end
end
