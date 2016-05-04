defmodule Sips.Repo.Migrations.CreateGoal do
  use Ecto.Migration

  def change do
    create table(:goals) do
      add :name, :string
      add :owner_id, references(:users, on_delete: :nothing)

      timestamps
    end
    create index(:goals, [:owner_id])

  end
end
