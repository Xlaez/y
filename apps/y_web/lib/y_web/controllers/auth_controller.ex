defmodule YWeb.AuthController do
  use YWeb, :controller

  alias YWeb.Plugs.Auth
  alias YCore.Accounts.AuthenticationService

  def create(conn, %{"username" => username, "password" => password}) do
    user_repo = Application.get_env(:y_core, :repositories)[:user]
    
    case AuthenticationService.authenticate(username, password, user_repo) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Welcome back!")
        |> Auth.login_user(user.id)
        |> redirect(to: "/home")

      {:error, :invalid_credentials} ->
        conn
        |> put_flash(:error, "Invalid username or password")
        |> redirect(to: "/login")
    end
  end

  def register_complete(conn, %{"user_id" => user_id, "words" => words}) do
    conn
    |> Auth.login_user(user_id)
    |> redirect(to: ~p"/onboarding/seed-phrase?words=#{words}")
  end

  def delete(conn, _params) do
    conn
    |> Auth.logout_user()
    |> put_flash(:info, "Logged out successfully.")
    |> redirect(to: "/login")
  end
end
