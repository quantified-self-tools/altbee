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
    |> cast(attrs, [:tags, :order, :name, :user_id])
    |> validate_required([:tags, :order, :name, :user_id])
    |> update_change(:name, &String.trim/1)
    |> update_change(:tags, &filter_tags/1)
    |> validate_length(:tags, min: 1)
    |> validate_length(:name, max: 80)
  end

  def filter_tags(tags) do
    Enum.filter(tags, fn tag -> tag != "" end)
  end
end
