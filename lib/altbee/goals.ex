defmodule Altbee.Goals do
  alias Altbee.Accounts.User

  def fetch_goals!(%User{goals: goals, access_token: token}) do
    fetch_goals!(goals, token)
  end

  def fetch_goals!(goals, token)
      when is_list(goals) and is_binary(token) do
    goals
    |> Task.async_stream(
      fn goal ->
        %{body: response, status_code: 200} =
          HTTPoison.get!("https://www.beeminder.com/api/v1/users/me/goals/#{goal}.json", [],
            params: %{access_token: token}
          )

        Jason.decode!(response)
      end,
      max_concurrency: 8,
      timeout: 10_000,
      ordered: false
    )
    |> Enum.map(fn {:ok, goal} -> goal end)
    |> Enum.sort_by(fn goal -> goal["losedate"] end)
  end
end
