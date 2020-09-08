defmodule Altbee.Goals do
  alias Altbee.Accounts.User

  def fetch_goals!(%User{goals: goals, access_token: token}) do
    fetch_goals!(goals, token)
  end

  def fetch_goals!(goals, token)
      when is_list(goals) and is_binary(token) do
    goals
    |> Task.async_stream(
      fn slug ->
        fetch_goal!(slug, token)
      end,
      max_concurrency: 8,
      timeout: 10_000,
      ordered: false
    )
    |> Enum.map(fn {:ok, goal} -> goal end)
    |> Enum.sort_by(fn goal -> goal["losedate"] end)
  end

  def fetch_goal!(slug, token) do
    %{body: response, status_code: 200} =
      HTTPoison.get!("https://www.beeminder.com/api/v1/users/me/goals/#{slug}.json", [],
        params: %{access_token: token}
      )

    Jason.decode!(response)
  end

  def submit_datapoint!(slug, token, daystamp, value, comment) do
    request_body = %{daystamp: daystamp, comment: comment, value: value} |> Jason.encode!()

    %{body: response, status_code: 200} =
      HTTPoison.post!(
        "https://www.beeminder.com/api/v1/users/me/goals/#{slug}/datapoints.json",
        request_body,
        [{"Content-Type", "application/json"}],
        params: %{access_token: token}
      )

    Jason.decode!(response)
  end
end
