defmodule Sips.UserController do
  use Sips.Web, :controller

  alias Sips.User
  plug Guardian.Plug.EnsureAuthenticated, handler: Sips.AuthErrorHandler

  def index(conn, _params) do
    users = Repo.all(User)
    render(conn, "index.json", data: users)
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    render(conn, "show.json", data: user)
  end

  def current(conn, _) do
    user =
      conn
      |> Guardian.Plug.current_resource

    conn
    |> render(Sips.UserView, "show.json", data: user)
  end
end
