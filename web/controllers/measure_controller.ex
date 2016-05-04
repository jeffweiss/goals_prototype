defmodule Sips.MeasureController do
  use Sips.Web, :controller

  import Ecto.Query, only: [where: 2, limit: 2, order_by: 2]

  alias Sips.Measure

  def index(conn, %{"goal_id" => goal_id}) do
    measures =
      Measure
      |> where(goal_id: ^goal_id)
      |> order_by([desc: :inserted_at])
      |> limit(100)
      |> Repo.all

    render(conn, "index.json", data: measures)
  end
  def index(conn, _params) do
    measures =
      Measure
      |> order_by([desc: :inserted_at])
      |> limit(100)
      |> Repo.all
    render(conn, "index.json", data: measures)
  end

  def create(conn, %{"goal_id" => goal_id, "data" => %{"type" => "measures", "attributes" => measure_params, "relationships" => _}}) do
    changeset = Measure.changeset(%Measure{goal_id: goal_id |> Integer.parse |> elem(0)}, measure_params)

    case Repo.insert(changeset) do
      {:ok, measure} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", measure_path(conn, :show, measure))
        |> render("show.json", data: measure)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Sips.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    measure = Repo.get!(Measure, id)
    render(conn, "show.json", data: measure)
  end

  def update(conn, %{"id" => id, "data" => %{"id" => _, "type" => "measures", "attributes" => measure_params, "relationships" => _}}) do
    measure = Repo.get!(Measure, id)
    changeset = Measure.changeset(measure, measure_params)

    case Repo.update(changeset) do
      {:ok, measure} ->
        render(conn, "show.json", data: measure)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Sips.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    measure = Repo.get!(Measure, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(measure)

    send_resp(conn, :no_content, "")
  end
end
