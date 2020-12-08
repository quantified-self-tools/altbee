defmodule AltbeeWeb.GoalLive do
  use AltbeeWeb, :live_view

  require Logger

  @goal_poll_interval 400
  @datapoint_number_parse_error_msg "Your datapoint should be a number."
  @datapoint_time_parse_error_msg "Your datapoint should be a number or a time."
  @datapoint_empty_msg "Enter a value for your datapoint."
  @datapoint_too_big_msg "Your datapoint must be less than 3,486,784,401"

  alias Altbee.{Datapoints, Goals}
  import Altbee.Datapoints, only: [parse_datapoint: 1]

  alias __MODULE__.DatapointsComponent

  def mount(%{"slug" => slug}, %{"user_id" => user_id}, socket) do
    socket =
      socket
      |> with_user(user_id, fn socket ->
        user = socket.assigns.user

        if connected?(socket) do
          Goals.load_goal_async(user, slug)
        end

        goal = Goals.load_goal_from_cache(user, slug)

        socket
        |> assign(:waiting, false)
        |> assign(:datapoint_parse_error, nil)
        |> assign(:slug, slug)
        |> assign(:page_title, "#{slug} · #{user.username}")
        |> assign(:goal, goal)
        |> watch_goal()
      end)

    {:ok, socket}
  end

  def new_data_placeholder(%{"last_datapoint" => %{"value" => last_datapoint_value}}) do
    "e.g. #{display_value(last_datapoint_value)}"
  end

  def new_data_placeholder(_) do
    "e.g. 1"
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
            slug = socket.assigns.slug

            enqueue_goal_poll(socket)

            Datapoints.submit_datapoint!(slug, access_token, daystamp, value, comment)

            socket
            |> assign(:datapoint_parse_error, nil)
            |> assign(:waiting, true)
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

  def handle_event("new-datapoint-change", %{"value" => value}, socket) do
    socket =
      if socket.assigns.datapoint_parse_error do
        case parse_datapoint(value) do
          {:ok, _} -> assign(socket, :datapoint_parse_error, nil)
          {:error, _} -> socket
        end
      else
        socket
      end

    {:noreply, socket}
  end

  def handle_event(
        "update-datapoint",
        %{"value" => value, "comment" => comment, "id" => id},
        socket
      ) do
    send(socket.root_pid, {:update_datapoint, id, value, comment})

    socket =
      socket
      |> assign(:waiting, true)

    {:noreply, socket}
  end

  def handle_event("delete-datapoint", %{"datapoint-id" => id}, socket) do
    send(socket.root_pid, {:delete_datapoint, id})

    socket =
      socket
      |> assign(:waiting, true)

    {:noreply, socket}
  end

  def handle_event("refresh", _, socket) do
    send(socket.root_pid, :refresh)

    socket =
      socket
      |> assign(:waiting, true)

    {:noreply, socket}
  end

  def daystamp_from_diff(diff, timezone, deadline) do
    date_from_diff(diff, timezone, deadline)
    |> Timex.format!("{YYYY}{0M}{0D}")
  end

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

  defp waiting?(%Phoenix.LiveView.Socket{} = socket) do
    waiting?(socket.assigns)
  end

  defp waiting?(%{waiting: waiting, goal: goal}) do
    waiting || goal["queued"]
  end

  defp waiting?(_), do: false

  defp enqueue_goal_poll(socket) do
    Process.send_after(socket.root_pid, :poll_queued_goal, @goal_poll_interval)
  end

  defp watch_goal(socket) do
    if connected?(socket) && waiting?(socket) do
      enqueue_goal_poll(socket)
    end

    socket
  end

  def handle_info(:poll_queued_goal, socket) do
    send(socket.root_pid, :refresh)

    if waiting?(socket) do
      enqueue_goal_poll(socket)
    end

    {:noreply, socket}
  end

  def handle_info(:refresh, socket) do
    %{goal: goal, user: user} = socket.assigns

    case Goals.fetch_goal(goal["slug"], user.access_token) do
      {:ok, new_goal} ->
        Goals.put_cache(user, new_goal)

        socket =
          socket
          |> assign(:goal, new_goal)
          |> assign(:waiting, false)

        {:noreply, socket}

      {:error, err} ->
        msg = Exception.message(err)
        Logger.error("Error refreshing #{goal["slug"]} for #{user.username}: #{msg}")

        socket =
          socket
          |> put_flash(:error, "An error occurred while trying to refresh your goal")
          |> assign(:waiting, false)

        {:noreply, socket}
    end
  end

  def handle_info({:goal, goal}, socket) do
    socket =
      socket
      |> assign(:goal, goal)

    {:noreply, socket}
  end

  def handle_info({:delete_datapoint, id}, socket) do
    %{goal: goal, user: user} = socket.assigns

    enqueue_goal_poll(socket)

    Task.start(fn ->
      Datapoints.delete_datapoint!(goal["slug"], id, user.access_token)
    end)

    {:noreply, socket}
  end

  def handle_info({:update_datapoint, id, value, comment}, socket) do
    %{goal: goal, user: user} = socket.assigns

    enqueue_goal_poll(socket)

    Task.start(fn ->
      Datapoints.update_datapoint!(goal["slug"], id, user.access_token, value, comment)
    end)

    {:noreply, socket}
  end
end
