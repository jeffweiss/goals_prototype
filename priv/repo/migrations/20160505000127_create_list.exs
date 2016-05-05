defmodule Sips.Repo.Migrations.CreateList do
  use Ecto.Migration

  def change do
    create table(:lists) do
      add :name, :string
      add :owner_id, references(:users, on_delete: :nothing)

      timestamps
    end
    create index(:lists, [:owner_id])

  end
end
