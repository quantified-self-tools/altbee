defmodule Altbee.Accounts do
  import Ecto.Query, warn: false
  alias Altbee.Repo

  alias Altbee.Accounts.User

  def create_user!(username, token) do
    %{"goals" => goals, "timezone" => timezone, "updated_at" => updated_at} =
      get_beeminder_user_data!(token)

    %User{}
    |> User.changeset(%{
      username: username,
      access_token: token,
      timezone: timezone,
      beeminder_updated: DateTime.from_unix!(updated_at),
      goals: goals
    })
    |> Repo.insert!(
      returning: true,
      on_conflict: {:replace, [:access_token, :timezone, :beeminder_updated, :goals]},
      conflict_target: [:username]
    )
  end

  def get_beeminder_user_data!(token) do
    %{body: response, status_code: 200} =
      HTTPoison.get!("https://www.beeminder.com/api/v1/users/me.json", [],
        params: [access_token: token]
      )

    Jason.decode!(response)
  end

  def get_user(id) do
    Repo.get(User, id)
  end
end
