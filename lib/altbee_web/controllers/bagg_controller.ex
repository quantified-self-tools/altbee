defmodule AltbeeWeb.BaggController do
  use AltbeeWeb, :controller

  def index(conn, params) do
    case Bagg.aggregate_goal(params) do
      {:ok, data} ->
        result =
          params
          |> Map.put(
            "agg_data",
            Enum.map(data, fn datapoint ->
              %{
                value: datapoint.value,
                hashtags: Enum.to_list(datapoint.hashtags),
                daystamp: Timex.format!(datapoint.date, "{YYYY}{0M}{0D}")
              }
            end)
          )

        conn
        |> json(result)

      {:error, {:invalid_aggday, aggday}} ->
        conn
        |> put_status(400)
        |> json(%{error: "Invalid aggday value: \"#{aggday}\" isn't currently supported."})

      {:error, :no_datapoints} ->
        conn
        |> put_status(400)
        |> json(%{
          error: """
          It doesn't seem like that goal has any datapoints.

          Perhaps you fetched the goal from the Beeminder API without `datapoints=true`?
          See http://api.beeminder.com/#getgoal for the details about that API.
          """
        })
    end
  end
end
