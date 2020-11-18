defmodule Altbee.Goals do
  @beeminder_goals_base_url Application.compile_env(:altbee, :goals_base_url)

  require Logger
  use Retry.Annotation

  alias Altbee.Accounts.User

  def load_goals_async(%User{goals: goals, access_token: token} = user) do
    pid = self()

    Task.start_link(fn ->
      goals
      |> Task.async_stream(
        fn slug ->
          case fetch_goal(slug, token) do
            {:ok, goal} ->
              put_cache(user, goal)
              send(pid, {:goal, goal})

            {:error, err} ->
              msg = Exception.message(err)

              Logger.error("Failed to fetch goal #{slug} for #{user.username}: #{msg}")
          end
        end,
        max_concurrency: 8,
        timeout: 15_000,
        ordered: false
      )
      |> Stream.run()
    end)
  end

  def load_goal_async(%User{access_token: token} = user, slug) do
    pid = self()

    Task.start_link(fn ->
      case fetch_goal(slug, token) do
        {:ok, goal} ->
          put_cache(user, goal)
          send(pid, {:goal, goal})

        {:error, err} ->
          msg = Exception.message(err)
          Logger.error("Failed to fetch goal #{slug} for #{user.username}: #{msg}")
      end
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

  @retry with: exponential_backoff() |> randomize() |> expiry(10_000)
  def fetch_goal(slug, token) do
    goal_url = "#{@beeminder_goals_base_url}/#{slug}.json?access_token=#{token}"

    Finch.build(:get, goal_url)
    |> Altbee.Finch.request_json()
  end
end
