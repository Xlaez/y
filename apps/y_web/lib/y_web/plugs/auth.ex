defmodule YWeb.Plugs.Auth do
  import Plug.Conn
  import Phoenix.Controller

  alias YRepo.Session

  @session_cookie "_y_session"
  @cookie_options [http_only: true, secure: true, same_site: "Lax", max_age: 30 * 24 * 60 * 60]

  def init(opts), do: opts

  def call(conn, _opts) do
    user_token = conn.req_cookies[@session_cookie]
    
    conn = if user_token do
      case Session.get_user_id(user_token) do
        {:ok, user_id} ->
          user_repo = Application.get_env(:y_core, :repositories)[:user]
          case user_repo.get_by_id(user_id) do
            {:ok, user} ->
              conn
              |> assign(:current_user, user)
              |> put_session(:user_token, user_token) # For LiveView access
            _ ->
              conn
              |> assign(:current_user, nil)
              |> put_session(:user_token, nil)
          end
        _ ->
          conn
          |> assign(:current_user, nil)
          |> put_session(:user_token, nil)
      end
    else
      conn
      |> assign(:current_user, nil)
      |> put_session(:user_token, nil)
    end
    
    conn
  end

  def login_user(conn, user_id) do
    case Session.create_session(user_id) do
      {:ok, token} ->
        conn
        |> put_resp_cookie(@session_cookie, token, @cookie_options)
        |> assign(:current_user, %{id: user_id}) # Temporary assign for the current request
      {:error, _} ->
        conn
    end
  end

  def logout_user(conn) do
    user_token = conn.req_cookies[@session_cookie]
    if user_token, do: Session.delete_session(user_token)
    
    conn
    |> configure_session(drop: true)
    |> delete_resp_cookie(@session_cookie)
    |> assign(:current_user, nil)
  end

  def require_authenticated_user(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, "You must log in to access this page.")
      |> redirect(to: "/login")
      |> halt()
    end
  end

  def redirect_if_user_is_authenticated(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
      |> redirect(to: "/")
      |> halt()
    else
      conn
    end
  end

  def on_mount(:mount_current_user, _params, session, socket) do
    user_token = session["user_token"]
    
    socket = if user_token do
      case Session.get_user_id(user_token) do
        {:ok, user_id} ->
          user_repo = Application.get_env(:y_core, :repositories)[:user]
          case user_repo.get_by_id(user_id) do
            {:ok, user} -> Phoenix.Component.assign(socket, :current_user, user)
            _ -> Phoenix.Component.assign(socket, :current_user, nil)
          end
        _ -> Phoenix.Component.assign(socket, :current_user, nil)
      end
    else
      Phoenix.Component.assign(socket, :current_user, nil)
    end
    
    {:cont, socket}
  end

  def on_mount(:ensure_authenticated, _params, _session, socket) do
    if socket.assigns[:current_user] do
      {:cont, socket}
    else
      {:halt, Phoenix.LiveView.redirect(socket, to: "/login")}
    end
  end

  def on_mount(:redirect_if_authenticated, _params, _session, socket) do
    if socket.assigns[:current_user] do
      {:halt, Phoenix.LiveView.redirect(socket, to: "/home")}
    else
      {:cont, socket}
    end
  end
end
