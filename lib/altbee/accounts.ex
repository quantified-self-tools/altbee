defmodule Altbee.Accounts do
  @beeminder_user_data_url Application.get_env(:altbee, :user_data_url)

  import Ecto.Query, warn: false
  alias Altbee.Repo

  alias Altbee.Accounts.User

  def refresh_user_async(%User{} = user) do
    pid = self()

    Task.start_link(fn ->
      user =
        user
        |> beeminder_user_data_changeset!()
        |> Repo.update!(returning: true)

      send(pid, {:user, user})
    end)
  end

  def create_user!(token) do
    %User{}
    |> beeminder_user_data_changeset!(token)
    |> Repo.insert!(
      returning: true,
      on_conflict: {:replace, [:access_token, :timezone, :beeminder_updated, :goals]},
      conflict_target: [:username]
    )
  end

  defp beeminder_user_data_changeset!(%User{} = user, token \\ nil) do
    token = token || user.access_token

    %{
      "username" => username,
      "goals" => goals,
      "timezone" => timezone,
      "updated_at" => updated_at
    } = get_beeminder_user_data!(token)

    user
    |> User.changeset(%{
      username: username,
      access_token: token,
      timezone: timezone,
      beeminder_updated: DateTime.from_unix!(updated_at),
      goals: goals
    })
  end

  def get_beeminder_user_data!(token) do
    {:ok, %{body: response, status: 200}} =
      Finch.build(:get, "#{@beeminder_user_data_url}?access_token=#{token}")
      |> Finch.request(AltbeeFinch)

    Jason.decode!(response)
  end

  def get_user(id) do
    Repo.get(User, id)
  end
end
