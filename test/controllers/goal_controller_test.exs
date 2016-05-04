defmodule Sips.GoalControllerTest do
  use Sips.ConnCase

  alias Sips.Goal
  @valid_attrs %{name: "some content"}
  @invalid_attrs %{}

  setup %{conn: conn} do
    user = Repo.insert! %Sips.User{}
    {:ok, jwt, _} = Guardian.encode_and_sign(user, :token)

    conn =
      conn
      |> put_req_header("content-type", "application/vnd.api+json")
      |> put_req_header("authorization", "Bearer #{jwt}")

    {:ok, %{conn: conn, user: user}}
  end

  defp create_test_goals(user) do
    Enum.each ["first goal", "second goal", "third goal"], fn name ->
      Repo.insert! %Goal{owner_id: user.id, name: name}
    end

    other_user = Repo.insert! %Sips.User{}
    Enum.each ["fourth goal", "fifth goal"], fn name ->
      Repo.insert! %Goal{owner_id: other_user.id, name: name}
    end
  end

  test "lists all entries on index", %{conn: conn, user: user} do
    create_test_goals user
    conn = get conn, goal_path(conn, :index)
    assert Enum.count(json_response(conn, 200)["data"]) == 5
  end

  test "lists owned entries on index (owner_id = user id)", %{conn: conn, user: user} do
    create_test_goals user
    conn = get conn, goal_path(conn, :index, user_id: user.id)
    assert Enum.count(json_response(conn, 200)["data"]) == 3
  end

  test "shows chosen resource", %{conn: conn, user: user} do
    goal = Repo.insert! %Goal{owner_id: user.id}
    conn = get conn, goal_path(conn, :show, goal)
    assert json_response(conn, 200)["data"] == %{
      "id" => to_string(goal.id),
      "type" => "goal",
      "attributes" => %{
        "name" => goal.name
      },
      "relationships" => %{
        "owner" => %{
          "links" => %{
            "related" => user_url(conn, :show, user)
          }
        }
      }
    }
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, goal_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, goal_path(conn, :create), data: %{type: "goals", attributes: @valid_attrs, relationships: %{}}
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Goal, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, goal_path(conn, :create), data: %{type: "goals", attributes: @invalid_attrs, relationships: %{}}
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn, user: user} do
    goal = Repo.insert! %Goal{owner_id: user.id, name: "A Goal"}
    conn = put conn, goal_path(conn, :update, goal), data: %{id: goal.id, type: "goals", attributes: @valid_attrs}
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Goal, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, user: user} do
    goal = Repo.insert! %Goal{owner_id: user.id}
    conn = put conn, goal_path(conn, :update, goal), data: %{id: goal.id, type: "goals", attributes: @invalid_attrs}
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn, user: user} do
    goal = Repo.insert! %Goal{owner_id: user.id}
    conn = delete conn, goal_path(conn, :delete, goal)
    assert response(conn, 204)
    refute Repo.get(Goal, goal.id)
  end
end
