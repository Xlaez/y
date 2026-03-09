defmodule YWeb.PageController do
  use YWeb, :controller

  def home(conn, _params) do
    # The home page for anonymous users
    render(conn, :home)
  end
end
