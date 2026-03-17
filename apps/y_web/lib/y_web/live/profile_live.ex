defmodule YWeb.ProfileLive do
  use YWeb, :live_view

  @user_repo YRepo.Repositories.UserRepository
  @follow_repo YRepo.Repositories.FollowRepository
  @block_repo YRepo.Repositories.BlockRepository

  alias YRepo.Repositories.{TakeRepository, AgreeRepository, BookmarkRepository, OpinionRepository, RetakeRepository, UserRepository}

  def mount(%{"username" => username}, _session, socket) do
    current_user = socket.assigns.current_user
    viewer_id = if current_user, do: current_user.id, else: nil

    case YCore.Accounts.ProfileService.get_profile(
           username,
           viewer_id,
           @user_repo,
           @follow_repo,
           @block_repo
         ) do
      {:ok, profile} ->
        feed = fetch_user_feed(profile.user.id, viewer_id, :takes)

        {:ok,
         socket
         |> assign(active_tab: :profile)
         |> assign(profile_tab: :takes)
         |> assign(profile: profile)
         |> assign(feed: feed)
         |> assign(show_edit_modal: false)
         |> assign(display_name: Map.get(profile.user, :display_name) || profile.user.username)
         |> allow_upload(:profile_picture,
           accept: ~w(.jpg .jpeg .png),
           max_entries: 1,
           max_file_size: 2_000_000
         ), layout: {YWeb.Layouts, :authenticated}}

      {:error, :not_found} ->
        {:ok, push_navigate(socket, to: "/home")}
    end
  end

  def handle_event("toggle_agree", %{"target_type" => type, "target_id" => id}, socket) do
    user_id = socket.assigns.current_user.id
    target_type = String.to_existing_atom(type)

    case AgreeRepository.toggle(user_id, target_type, id) do
      {:ok, _} -> {:noreply, refresh_user_feed(socket)}
      _ -> {:noreply, socket}
    end
  end

  def handle_event("toggle_bookmark", %{"target_type" => type, "target_id" => id}, socket) do
    user_id = socket.assigns.current_user.id
    target_type = String.to_existing_atom(type)

    case BookmarkRepository.toggle(user_id, target_type, id) do
      {:ok, _} -> {:noreply, refresh_user_feed(socket)}
      _ -> {:noreply, socket}
    end
  end

  def handle_event("navigate_to_take", %{"take_id" => id}, socket) do
    {:noreply, push_navigate(socket, to: ~p"/takes/#{id}")}
  end

  def handle_event("follow", _, socket) do
    if current_user = socket.assigns.current_user do
      case YCore.Social.FollowService.follow(
             current_user.id,
             socket.assigns.profile.user.id,
             @follow_repo
           ) do
        {:ok, _} ->
          {:noreply, update_profile(socket)}

        {:error, _} ->
          {:noreply, put_flash(socket, :error, "Could not follow user")}
      end
    else
      {:noreply, push_navigate(socket, to: "/login")}
    end
  end

  def handle_event("unfollow", _, socket) do
    if current_user = socket.assigns.current_user do
      case YCore.Social.FollowService.unfollow(
             current_user.id,
             socket.assigns.profile.user.id,
             @follow_repo
           ) do
        :ok ->
          {:noreply, update_profile(socket)}

        {:error, _} ->
          {:noreply, put_flash(socket, :error, "Could not unfollow user")}
      end
    else
      {:noreply, push_navigate(socket, to: "/login")}
    end
  end

  def handle_event("open_edit_modal", _, socket) do
    {:noreply, assign(socket, show_edit_modal: true)}
  end

  def handle_event("close_modal", _, socket) do
    {:noreply, assign(socket, show_edit_modal: false)}
  end

  def handle_event("save_profile", %{"display_name" => display_name}, socket) do
    current_user = socket.assigns.current_user

    profile_picture_base64 =
      consume_uploaded_entries(socket, :profile_picture, fn %{path: path}, _entry ->
        ext = Path.extname(path) |> String.trim_leading(".")
        data = File.read!(path) |> Base.encode64()
        {:ok, "data:image/#{ext};base64,#{data}"}
      end)
      |> List.first()

    attrs = %{display_name: display_name}
    attrs = if profile_picture_base64, do: Map.put(attrs, :profile_picture_base64, profile_picture_base64), else: attrs

    case @user_repo.update(current_user, attrs) do
      {:ok, user} ->
        {:noreply,
         socket
         |> assign(current_user: user, show_edit_modal: false)
         |> update_profile()
         |> put_flash(:info, "Profile updated successfully!")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Could not update profile")}
    end
  end

  def handle_event("validate_profile", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("set_tab", %{"tab" => tab}, socket) do
    tab = String.to_existing_atom(tab)
    viewer_id = (socket.assigns[:current_user] && socket.assigns.current_user.id) || nil
    user_id = socket.assigns.profile.user.id
    
    {:noreply, 
      socket 
      |> assign(profile_tab: tab)
      |> assign(feed: fetch_user_feed(user_id, viewer_id, tab))
    }
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :profile_picture, ref)}
  end

  defp fetch_user_feed(user_id, viewer_id, :takes) do
    # Just that user's takes
    takes = TakeRepository.list_for_user(user_id, limit: 50)
    enrich_takes(takes, user_id, viewer_id)
  end

  defp fetch_user_feed(user_id, viewer_id, :replies) do
    # Fetch user's opinions
    opinions = OpinionRepository.list_for_user(user_id, limit: 50)
    
    # We need to build a feed that shows: [Parent Take/Opinion] -> [User Opinion]
    # To keep it simple in the feed, we'll turn each opinion into a block
    Enum.flat_map(opinions, fn op ->
      # Fetch context (parent)
      parent = if op.parent_opinion_id do
        case OpinionRepository.get_by_id(op.parent_opinion_id) do
          {:ok, parent_op} -> 
            enrich_takes([opinion_to_take_adapter(parent_op)], parent_op.user_id, viewer_id) |> List.first()
          _ -> nil
        end
      else
        case TakeRepository.get_by_id(op.take_id) do
          {:ok, parent_take} ->
            enrich_takes([parent_take], parent_take.user_id, viewer_id) |> List.first()
          _ -> nil
        end
      end

      reply = enrich_takes([opinion_to_take_adapter(op)], user_id, viewer_id) |> List.first()
      
      # Mark them so FeedCard can show the connecting line
      if parent do
        [Map.put(parent, :thread_top, true), Map.put(reply, :thread_bottom, true)]
      else
        [reply]
      end
    end)
  end

  defp enrich_takes(takes, _user_id, viewer_id) do
    agreed_ids = if viewer_id, do: AgreeRepository.list_agreed_ids(viewer_id, :take, Enum.map(takes, & &1.id)) |> MapSet.new(), else: MapSet.new()
    bookmarked_ids = if viewer_id, do: BookmarkRepository.list_for_user(viewer_id, target_type: :take) |> Enum.map(& &1.target_id) |> MapSet.new(), else: MapSet.new()
    retook_ids = if viewer_id, do: RetakeRepository.list_retook_ids(viewer_id, Enum.map(takes, & &1.id)) |> MapSet.new(), else: MapSet.new()

    Enum.map(takes, fn take ->
      %{
        type: (if Map.get(take, :is_opinion), do: :opinion, else: :take),
        take: take,
        author: UserRepository.get_by_id!(take.user_id),
        agree_count: AgreeRepository.count(:take, take.id),
        retake_count: RetakeRepository.count_for_take(take.id),
        opinion_count: OpinionRepository.count_for_take(take.id),
        viewer_agreed: MapSet.member?(agreed_ids, take.id),
        viewer_bookmarked: MapSet.member?(bookmarked_ids, take.id),
        viewer_retook: MapSet.member?(retook_ids, take.id)
      }
    end)
  end

  defp opinion_to_take_adapter(op) do
    replying_to_handle = if op.parent_opinion_id do
      case OpinionRepository.get_by_id(op.parent_opinion_id) do
        {:ok, parent_op} -> UserRepository.get_by_id!(parent_op.user_id).username
        _ -> nil
      end
    else
      case TakeRepository.get_by_id(op.take_id) do
        {:ok, parent_take} -> UserRepository.get_by_id!(parent_take.user_id).username
        _ -> nil
      end
    end

    %{
      id: op.id,
      user_id: op.user_id,
      body: op.body,
      inserted_at: op.inserted_at,
      opinion_count: 0, 
      retake_count: 0,
      is_opinion: true,
      replying_to_handle: replying_to_handle
    }
  end

  defp refresh_user_feed(socket) do
    viewer_id = (socket.assigns[:current_user] && socket.assigns.current_user.id) || nil
    assign(socket, feed: fetch_user_feed(socket.assigns.profile.user.id, viewer_id, socket.assigns.profile_tab))
  end

  defp update_profile(socket) do
    username = socket.assigns.profile.user.username
    viewer_id = (socket.assigns[:current_user] && socket.assigns.current_user.id) || nil

    case YCore.Accounts.ProfileService.get_profile(
           username,
           viewer_id,
           @user_repo,
           @follow_repo,
           @block_repo
         ) do
      {:ok, profile} ->
        socket
        |> assign(profile: profile)
        |> assign(display_name: Map.get(profile.user, :display_name) || profile.user.username)

      _ ->
        socket
    end
  end
end
