defmodule Altbee.Accounts do
  require Logger
  use Retry.Annotation

  import Ecto.Query, warn: false
  alias Altbee.Repo

  alias Altbee.Accounts.User

  @beeminder_user_data_url Application.compile_env(:altbee, :user_data_url)

  def refresh_user_async(%User{} = user) do
    pid = self()

    Task.start_link(fn ->
      user =
        user
        |> beeminder_user_data_changeset()
        |> Repo.update!(returning: true)

      send(pid, {:user, user})
    end)
  end

  def create_user(token) do
    %User{}
    |> beeminder_user_data_changeset(token)
    |> Repo.insert!(
      returning: true,
      on_conflict: {:replace, [:access_token, :timezone, :beeminder_updated, :goals]},
      conflict_target: [:username]
    )
  end

  defp beeminder_user_data_changeset(%User{} = user, token \\ nil) do
    token = token || user.access_token

    case get_beeminder_user_data(token) do
      {:ok,
       %{
         "username" => username,
         "goals" => goals,
         "timezone" => timezone,
         "updated_at" => updated_at
       }} ->
        user
        |> User.changeset(%{
          username: username,
          access_token: token,
          timezone: timezone,
          beeminder_updated: DateTime.from_unix!(updated_at),
          goals: goals
        })

      {:error, err} ->
        msg = Exception.message(err)
        Logger.error("Failed to fetch updated user info for #{user.username}: #{msg}")

        User.changeset(user)
    end
  end

  @retry with: exponential_backoff() |> randomize() |> expiry(10_000)
  def get_beeminder_user_data(token) do
    Finch.build(:get, "#{@beeminder_user_data_url}?access_token=#{token}")
    |> Altbee.Finch.request_json()
  end

  def get_user(id) do
    Repo.get(User, id)
  end

  def toggle_layout_mode(%User{layout_mode: mode} = user) do
    new_mode =
      case mode do
        :compact -> :spacious
        :spacious -> :compact
      end

    user
    |> User.changeset(%{
      layout_mode: new_mode
    })
    |> Repo.update!(returning: true)
  end
end
