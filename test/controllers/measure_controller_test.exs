defmodule Sips.MeasureControllerTest do
  use Sips.ConnCase

  alias Sips.Measure
  @valid_attrs %{name: "some content", value: "some content"}
  @invalid_attrs %{}

  setup %{conn: conn} do
    user = Repo.insert! %Sips.User{}
    goal = Repo.insert! %Sips.Goal{owner_id: user.id}
    {:ok, jwt, _} = Guardian.encode_and_sign(user, :token)

    conn =
      conn
      |> put_req_header("content-type", "application/vnd.api+json")
      |> put_req_header("authorization", "Bearer #{jwt}")

    {:ok, %{conn: conn, user: user, goal: goal}}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, measure_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn, goal: goal} do
    measure = Repo.insert! %Measure{goal_id: goal.id}
    conn = get conn, measure_path(conn, :show, measure)
    assert json_response(conn, 200)["data"] == %{
      "id" => to_string(measure.id),
      "type" => "measure",
      "attributes" => %{
        "name" => measure.name,
        "inserted-at" => Ecto.DateTime.to_iso8601(measure.inserted_at),
        "value" => measure.value
      },
      "relationships" => %{
        "goal" => %{
          "links" => %{
            "related" => goal_url(conn, :show, goal)
          }
        }
      }
    }
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, measure_path(conn, :show, -1)
    end
  end

  test "creates and renders resource through measure namespace when data is valid", %{conn: conn, goal: goal} do
    conn = post conn, measure_path(conn, :create), data: %{type: "measures", attributes: Map.put(@valid_attrs, :goal_id, goal.id), relationships: %{}}
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Measure, @valid_attrs)
  end

  test "creates and renders resource through goal namespace when data is valid", %{conn: conn, goal: goal} do
    conn = post conn, goal_measures_path(conn, :create, goal), data: %{type: "measures", attributes: @valid_attrs, relationships: %{}}
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Measure, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn, goal: goal} do
    conn = post conn, goal_measures_path(conn, :create, goal), data: %{type: "measures", attributes: @invalid_attrs, relationships: %{}}
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn, goal: goal} do
    measure = Repo.insert! %Measure{goal_id: goal.id}
    conn = put conn, measure_path(conn, :update, measure), data: %{id: measure.id, type: "measures", attributes: @valid_attrs, relationships: %{}}
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Measure, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    measure = Repo.insert! %Measure{}
    conn = put conn, measure_path(conn, :update, measure), data: %{id: measure.id, type: "measures", attributes: @invalid_attrs, relationships: %{}}
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    measure = Repo.insert! %Measure{}
    conn = delete conn, measure_path(conn, :delete, measure)
    assert response(conn, 204)
    refute Repo.get(Measure, measure.id)
  end
end
