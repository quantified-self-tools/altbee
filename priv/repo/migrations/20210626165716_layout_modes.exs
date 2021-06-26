defmodule Altbee.Repo.Migrations.LayoutModes do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:layout_mode, :text, null: false, default: "compact")
    end
  end
end
