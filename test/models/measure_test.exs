defmodule Sips.MeasureTest do
  use Sips.ModelCase

  alias Sips.Measure

  @valid_attrs %{name: "some content", value: "some content", goal_id: 1}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Measure.changeset(%Measure{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Measure.changeset(%Measure{}, @invalid_attrs)
    refute changeset.valid?
  end
end
