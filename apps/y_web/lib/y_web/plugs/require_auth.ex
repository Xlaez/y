defmodule YWeb.Plugs.RequireAuth do
  @moduledoc """
  Ensures that a user is authenticated. Halts and redirects to login otherwise.
  """
  import Plug.Conn
  import Phoenix.Controller

  def init(opts), do: opts

  def call(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access this page.")
      |> redirect(to: "/login")
      |> halt()
    end
  end
end
