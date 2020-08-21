defmodule Altbee.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field(:access_token, :string)
    field(:beeminder_updated, :utc_datetime)
    field(:timezone, :string)
    field(:username, :string)
    field(:goals, {:array, :string})

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :access_token, :timezone, :beeminder_updated, :goals])
    |> validate_required([:username, :access_token, :timezone, :beeminder_updated, :goals])
  end
end
