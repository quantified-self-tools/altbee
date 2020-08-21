defmodule Altbee.Repo do
  use Ecto.Repo,
    otp_app: :altbee,
    adapter: Ecto.Adapters.Postgres
end
