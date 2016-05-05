defmodule Sips.ListGoal do
  use Sips.Web, :model

  schema "list_goals" do
    belongs_to :goal, Sips.Goal
    belongs_to :list, Sips.List

    timestamps
  end

  @required_fields ~w(goal_id list_id)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:list_id, name: :list_goals_list_id_goal_id_index)
    |> unique_constraint(:goal_id, name: :list_goals_list_id_goal_id_index)
  end
end
