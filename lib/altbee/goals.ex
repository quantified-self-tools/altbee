defmodule Altbee.Goals do
  alias Altbee.Accounts.User

  def load_goals_async(%User{goals: goals, access_token: token} = user) do
    pid = self()

    Task.start_link(fn ->
      goals
      |> Task.async_stream(
        fn slug ->
          goal = fetch_goal!(slug, token)
          put_cache(user, goal)
          send(pid, {:goal, goal})
        end,
        max_concurrency: 8,
        timeout: 10_000,
        ordered: false
      )
      |> Stream.run()
    end)
  end

  def load_goal_async(%User{access_token: token} = user, slug) do
    pid = self()

    Task.start_link(fn ->
      goal = fetch_goal!(slug, token)
      put_cache(user, goal)
      send(pid, {:goal, goal})
    end)
  end

  def put_cache(%User{username: username}, %{"slug" => slug} = goal) do
    Cachex.put(:goals_cache, "#{username}:#{slug}", goal)
  end

  def load_goals_from_cache(%User{goals: goals} = user) do
    Enum.flat_map(goals, fn slug ->
      goal = load_goal_from_cache(user, slug)

      if is_nil(goal) do
        []
      else
        [goal]
      end
    end)
  end

  def load_goal_from_cache(%User{username: username}, slug) do
    case Cachex.get(:goals_cache, "#{username}:#{slug}") do
      {:ok, nil} -> nil
      {:ok, goal} -> goal
      {:error, _} -> nil
    end
  end

  @beeminder_goals_base_url "https://www.beeminder.com/api/v1/users/me/goals"
  def fetch_goal!(slug, token) do
    goal_url = "#{@beeminder_goals_base_url}/#{slug}.json?access_token=#{token}"

    {:ok, %{body: response, status: 200}} =
      Finch.build(:get, goal_url)
      |> Finch.request(AltbeeFinch)

    Jason.decode!(response)
  end

  def submit_datapoint!(slug, token, daystamp, value, comment) do
    goal_url = "#{@beeminder_goals_base_url}/#{slug}/datapoints.json?access_token=#{token}"
    headers = [{"Content-Type", "application/json"}]

    request_body = %{daystamp: daystamp, comment: comment, value: value} |> Jason.encode!()

    {:ok, %{body: response, status: 200}} =
      Finch.build(:post, goal_url, headers, request_body)
      |> Finch.request(AltbeeFinch)

    Jason.decode!(response)
  end
end
