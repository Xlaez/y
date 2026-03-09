defmodule YWeb.PageController do
  use YWeb, :controller

  def home(conn, _params) do
    # The home page for anonymous users
    conn
    |> assign(:current_user, nil)
    |> render(:home)
  end
end
