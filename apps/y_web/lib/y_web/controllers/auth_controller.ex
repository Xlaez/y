defmodule YWeb.AuthController do
  use YWeb, :controller

  def new(conn, _params) do
    render(conn, :new)
  end

  def create(conn, %{"username" => _username, "password" => _password}) do
    # Placeholder for authentication logic
    conn
    |> put_flash(:info, "Welcome back!")
    |> redirect(to: "/feed")
  end

  def delete(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end
end
