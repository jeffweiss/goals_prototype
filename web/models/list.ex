defmodule Sips.List do
  use Sips.Web, :model

  schema "lists" do
    field :name, :string
    belongs_to :owner, Sips.Owner
    has_many :list_goals, Sips.ListGoal

    has_many :goals, through: [:list_goals, :goal]

    timestamps
  end

  @required_fields ~w(name)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
