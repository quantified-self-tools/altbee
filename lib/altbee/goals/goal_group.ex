defmodule Altbee.Goals.GoalGroup do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @timestamps_opts [type: :utc_datetime_usec]

  schema "goal_groups" do
    field(:order, :integer)
    field(:tags, {:array, :string})
    field(:name, :string)

    belongs_to(:user, Altbee.Accounts.User)

    timestamps()
  end

  @doc false
  def changeset(goal_group, attrs) do
    goal_group
    |> cast(attrs, [:tags, :order, :name])
    |> validate_required([:tags, :order, :name])
  end
end
