defmodule Sips.ListController do
  use Sips.Web, :controller
  import Ecto.Query, only: [from: 2, where: 2, preload: 2]

  alias Sips.List

  def index(conn, _params) do
    lists = Repo.all(List)
    render(conn, "index.json", data: lists)
  end

  def create(conn, %{"data" => %{"type" => "lists", "attributes" => list_params, "relationships" => _}}) do
    current_user = Guardian.Plug.current_resource(conn)
    changeset = List.changeset(%List{owner_id: current_user.id}, list_params)

    case Repo.insert(changeset) do
      {:ok, list} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", list_path(conn, :show, list))
        |> render("show.json", data: list)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Sips.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    list = Repo.get!(from(List, preload: :goals), id)
    render(conn, "show.json", data: list)
  end

  def update(conn, %{"id" => id, "data" => %{"id" => _, "type" => "lists", "attributes" => list_params}}) do
    current_user = Guardian.Plug.current_resource(conn)
    list =
      List
      |> where(owner_id: ^current_user.id, id: ^id)
      |> preload(:goals)
      |> Repo.one!
    changeset = List.changeset(list, list_params)

    case Repo.update(changeset) do
      {:ok, list} ->
        render(conn, "show.json", data: list)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Sips.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    list = Repo.get!(List, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(list)

    send_resp(conn, :no_content, "")
  end
end
