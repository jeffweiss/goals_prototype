defmodule Sips.Repo.Migrations.CreateListGoal do
  use Ecto.Migration

  def change do
    create table(:list_goals) do
      add :goal_id, references(:goals, on_delete: :nothing)
      add :list_id, references(:lists, on_delete: :nothing)

      timestamps
    end
    create index(:list_goals, [:goal_id])
    create index(:list_goals, [:list_id])

    create index(:list_goals, [:list_id, :goal_id], unique: true)

  end
end
