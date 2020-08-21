defmodule Altbee.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :username, :text, null: false
      add :access_token, :text, null: false
      add :timezone, :text, null: false
      add :beeminder_updated, :utc_datetime, null: false
      add :goals, {:array, :text}, null: false

      timestamps()
    end

    create unique_index(:users, [:username])
  end
end
