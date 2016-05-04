defmodule Sips.Repo.Migrations.CreateMeasure do
  use Ecto.Migration

  def change do
    create table(:measures) do
      add :name, :string
      add :value, :string
      add :goal_id, references(:goals, on_delete: :nothing)

      timestamps
    end
    create index(:measures, [:goal_id])

  end
end
