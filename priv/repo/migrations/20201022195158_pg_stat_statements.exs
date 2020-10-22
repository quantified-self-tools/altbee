defmodule Altbee.Repo.Migrations.PgStatStatements do
  use Ecto.Migration

  def change do
    execute(
      """
      CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
      """,
      """
      DROP EXTENSION IF EXISTS pg_stat_statements;
      """
    )
  end
end
