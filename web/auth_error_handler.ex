defmodule Sips.AuthErrorHandler do
  use Sips.Web, :controller

  def unauthenticated(conn, _params) do
    conn
    |> put_status(401)
    |> render(Sips.ErrorView, "401.json")
  end

  def unauthorized(conn, _params) do
    conn
    |> put_status(402)
    |> render(Sips.ErrorView, "403.json")
  end
end
