defmodule AltbeeWeb.AddDataComponent do
  use AltbeeWeb, :live_component

  alias Altbee.Datapoints
  import Altbee.Datapoints, only: [parse_datapoint: 1]

  @datapoint_number_parse_error_msg "Your datapoint should be a number."
  @datapoint_time_parse_error_msg "Your datapoint should be a number or a time."
  @datapoint_empty_msg "Enter a value for your datapoint."
  @datapoint_too_big_msg "Your datapoint must be less than 3,486,784,401"

  def day_text_from_diff(diff, timezone, deadline) do
    date = date_from_diff(diff, timezone, deadline)

    case diff do
      0 ->
        "Today (#{date})"

      1 ->
        "Yesterday (#{date})"

      _ ->
        day = Timex.day_name(Date.day_of_week(date))
        "#{day} (#{date})"
    end
  end

  defp date_from_diff(diff, timezone, deadline) do
    Timex.now()
    |> Timex.Timezone.convert(timezone)
    |> Timex.shift(days: -diff)
    |> Timex.shift(seconds: -deadline)
    |> Timex.to_date()
  end

  def daystamp_from_diff(diff, timezone, deadline) do
    date_from_diff(diff, timezone, deadline)
    |> Timex.format!("{YYYY}{0M}{0D}")
  end

  def new_data_placeholder(%{"last_datapoint" => %{"value" => last_datapoint_value}}) do
    "e.g. #{display_value(last_datapoint_value)}"
  end

  def new_data_placeholder(_) do
    "e.g. 1"
  end

  def mount(socket) do
    socket =
      socket
      |> assign(:datapoint_parse_error, nil)

    {:ok, socket}
  end

  def handle_event(
        "new-datapoint",
        %{"comment" => comment, "daystamp" => daystamp, "value" => value},
        socket
      ) do
    socket =
      case parse_datapoint(value) do
        {:ok, value} ->
          if value >= 3_486_784_401 do
            assign(socket, :datapoint_parse_error, @datapoint_too_big_msg)
          else
            access_token = socket.assigns.user.access_token
            slug = socket.assigns.goal["slug"]

            send(self(), {:new_datapoint_entered, slug})

            Datapoints.submit_datapoint!(slug, access_token, daystamp, value, comment)

            send(self(), {:new_datapoint_submitted, slug})

            socket
            |> assign(:datapoint_parse_error, nil)
          end

        {:error, :empty} ->
          assign(socket, :datapoint_parse_error, @datapoint_empty_msg)

        {:error, :number} ->
          assign(socket, :datapoint_parse_error, @datapoint_number_parse_error_msg)

        {:error, :time} ->
          assign(socket, :datapoint_parse_error, @datapoint_time_parse_error_msg)
      end

    {:noreply, socket}
  end
end
