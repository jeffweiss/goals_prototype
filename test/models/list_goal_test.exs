defmodule Sips.ListGoalTest do
  use Sips.ModelCase

  alias Sips.ListGoal

  @valid_attrs %{goal_id: 1, list_id: 1}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = ListGoal.changeset(%ListGoal{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = ListGoal.changeset(%ListGoal{}, @invalid_attrs)
    refute changeset.valid?
  end
end
