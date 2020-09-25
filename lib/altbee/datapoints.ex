defmodule Altbee.Datapoints do
  @beeminder_goals_base_url Application.get_env(:altbee, :goals_base_url)
  @beeminder_user_base_url Application.get_env(:altbee, :user_base_url)

  @spec parse_datapoint(String.t()) ::
          {:ok, number()} | {:error, :empty} | {:error, :number} | {:error, :time}
  def parse_datapoint(value) do
    cond do
      value == "" ->
        {:error, :empty}

      String.contains?(value, ":") ->
        case String.split(value, ":") do
          [hours, minutes] ->
            case {Integer.parse(hours), Integer.parse(minutes)} do
              {{h, ""}, {m, ""}} -> {:ok, h + m / 60}
              {_, _} -> {:error, :time}
            end

          _ ->
            {:error, :time}
        end

      true ->
        case Float.parse(value) do
          {float, ""} -> {:ok, float}
          :error -> {:error, :number}
          {_, _} -> {:error, :number}
        end
    end
  end

  def submit_datapoint!(goal_slug, token, daystamp, value, comment) do
    goal_url = "#{@beeminder_goals_base_url}/#{goal_slug}/datapoints.json?access_token=#{token}"
    headers = [{"Content-Type", "application/json"}]

    request_body = %{daystamp: daystamp, comment: comment, value: value} |> Jason.encode!()

    {:ok, %{body: response, status: 200}} =
      Finch.build(:post, goal_url, headers, request_body)
      |> Finch.request(AltbeeFinch)

    Jason.decode!(response)
  end

  def delete_datapoint!(goal_slug, datapoint_id, token) do
    url = datapoint_url(goal_slug, datapoint_id, token)

    {:ok, %{body: response, status: 200}} =
      Finch.build(:delete, url)
      |> Finch.request(AltbeeFinch)

    Jason.decode!(response)
  end

  def update_datapoint!(goal_slug, datapoint_id, token, value, comment) do
    url = datapoint_url(goal_slug, datapoint_id, token)

    headers = [{"Content-Type", "application/json"}]
    request_body = %{comment: comment, value: value} |> Jason.encode!()

    {:ok, %{body: response, status: 200}} =
      Finch.build(:put, url, headers, request_body)
      |> Finch.request(AltbeeFinch)

    Jason.decode!(response)
  end

  defp datapoint_url(goal_slug, datapoint_id, token) do
    @beeminder_user_base_url <>
      "/goals/#{goal_slug}/datapoints/#{datapoint_id}.json" <>
      "?access_token=#{token}"
  end
end
