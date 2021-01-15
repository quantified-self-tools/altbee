defmodule Altbee.Repo.Migrations.CreateGoalGroups do
  use Ecto.Migration

  def change do
    create table(:goal_groups, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :tags, {:array, :text}, null: false
      add :order, :integer, null: false
      add :name, :text, null: false

      add :user_id, references(:users, type: :binary_id), null: false

      timestamps()
    end

    create index(:goal_groups, [:user_id])
  end
end
