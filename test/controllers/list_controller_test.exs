defmodule Sips.ListControllerTest do
  use Sips.ConnCase

  alias Sips.List
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

  defp create_test_lists(user) do
    Enum.each ["first list", "second list", "third list"], fn name ->
      Repo.insert! %List{owner_id: user.id, name: name}
    end

    other_user = Repo.insert! %Sips.User{}
    Enum.each ["fourth list", "fifth list"], fn name ->
      Repo.insert! %List{owner_id: other_user.id, name: name}
    end
  end

  test "lists all entries on index", %{conn: conn, user: user} do
    create_test_lists(user)
    conn = get conn, list_path(conn, :index)
    assert Enum.count(json_response(conn, 200)["data"]) == 5
  end

  test "shows chosen resource with no goals", %{conn: conn, user: user} do
    list = Repo.insert! %List{owner_id: user.id}
    conn = get conn, list_path(conn, :show, list)
    assert json_response(conn, 200)["data"] == %{
      "id" => to_string(list.id),
      "type" => "list",
      "attributes" => %{
        "name" => list.name,
      },
      "relationships" => %{
        "owner" => %{
          "links" => %{
            "related" => user_url(conn, :show, user)
          }
        },
        "goals" => %{
          "links" => %{
            "related" => []
          }
        }
      }
    }
  end

  test "shows chosen resource with several goals", %{conn: conn, user: user} do
    list = Repo.insert! %List{owner_id: user.id}
    goal1 = Repo.insert! %Sips.Goal{owner_id: user.id}
    goal2 = Repo.insert! %Sips.Goal{owner_id: user.id}
    Repo.insert! %Sips.ListGoal{goal_id: goal1.id, list_id: list.id}
    Repo.insert! %Sips.ListGoal{goal_id: goal2.id, list_id: list.id}
    conn = get conn, list_path(conn, :show, list)
    assert json_response(conn, 200)["data"] == %{
      "id" => to_string(list.id),
      "type" => "list",
      "attributes" => %{
        "name" => list.name,
      },
      "relationships" => %{
        "owner" => %{
          "links" => %{
            "related" => user_url(conn, :show, user)
          }
        },
        "goals" => %{
          "links" => %{
            "related" => [goal_url(conn, :show, goal1), goal_url(conn, :show, goal2)]
          }
        }
      }
    }
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, list_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, list_path(conn, :create), data: %{type: "lists", attributes: @valid_attrs, relationships: %{}}
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(List, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, list_path(conn, :create), data: %{type: "lists", attributes: @invalid_attrs, relationships: %{}}
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn, user: user} do
    list = Repo.insert! %List{owner_id: user.id, name: "A List"}
    conn = put conn, list_path(conn, :update, list), data: %{id: list.id, type: "lists", "attributes": @valid_attrs}
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(List, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, user: user} do
    list = Repo.insert! %List{owner_id: user.id}
    conn = put conn, list_path(conn, :update, list), data: %{id: list.id, type: "lists", "attributes": @invalid_attrs}
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    list = Repo.insert! %List{}
    conn = delete conn, list_path(conn, :delete, list)
    assert response(conn, 204)
    refute Repo.get(List, list.id)
  end
end
