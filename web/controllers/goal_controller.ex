defmodule Sips.GoalController do
  use Sips.Web, :controller
  import Ecto.Query, only: [where: 2]

  alias Sips.Goal

  def index(conn, %{"user_id" => user_id}) do
    goals =
      Goal
      |> where(owner_id: ^user_id)
      |> Repo.all

    render(conn, "index.json", data: goals)
  end
  def index(conn, _params) do
    goals = Repo.all(Goal)
    render(conn, "index.json", data: goals)
  end

  def create(conn, %{"data" => %{"type" => "goals", "attributes" => goal_params, "relationships" => _}}) do
    current_user = Guardian.Plug.current_resource(conn)
    changeset = Goal.changeset(%Goal{owner_id: current_user.id}, goal_params)

    case Repo.insert(changeset) do
      {:ok, goal} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", goal_path(conn, :show, goal))
        |> render("show.json", data: goal)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Sips.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    goal = Repo.get!(Goal, id)
    render(conn, "show.json", data: goal)
  end

  def update(conn, %{"id" => id, "data" => %{"id" => _, "type" => "goals", "attributes" => goal_params}}) do
    current_user = Guardian.Plug.current_resource(conn)
    goal =
      Goal
      |> where(owner_id: ^current_user.id, id: ^id)
      |> Repo.one!
    changeset = Goal.changeset(goal, goal_params)

    case Repo.update(changeset) do
      {:ok, goal} ->
        render(conn, "show.json", data: goal)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Sips.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    current_user = Guardian.Plug.current_resource(conn)
    goal =
      Goal
      |> where(owner_id: ^current_user.id, id: ^id)
      |> Repo.one!

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(goal)

    send_resp(conn, :no_content, "")
  end
end
