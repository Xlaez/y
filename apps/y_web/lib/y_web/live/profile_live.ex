defmodule YWeb.ProfileLive do
  use YWeb, :live_view

  @user_repo YRepo.Repositories.UserRepository
  @follow_repo YRepo.Repositories.FollowRepository
  @block_repo YRepo.Repositories.BlockRepository

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
        # For now, we still use dummy takes until they are implemented
        takes = Enum.take(YWeb.DummyData.takes(), 5)

        {:ok,
         socket
         |> assign(active_tab: :profile)
         |> assign(profile: profile)
         |> assign(takes: takes)
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

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :profile_picture, ref)}
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
