defmodule YWeb.Plugs.LoadUser do
  @moduledoc """
  Loads the current user from the session and assigns it to the connection.
  """
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)

    if user_id do
      # Dependency injection for repo lookup
      repo = Application.get_env(:y_core, :repositories)[:user]

      case repo.get_by_id(user_id) do
        {:ok, user} -> assign(conn, :current_user, user)
        _ -> assign(conn, :current_user, nil)
      end
    else
      assign(conn, :current_user, nil)
    end
  end
end
