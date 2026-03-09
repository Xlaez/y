defmodule YWeb.FallbackController do
  use YWeb, :controller

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(html: YWeb.ErrorHTML, json: YWeb.ErrorJSON)
    |> render(:"404")
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:forbidden)
    |> put_view(html: YWeb.ErrorHTML, json: YWeb.ErrorJSON)
    |> render(:"403")
  end
end
