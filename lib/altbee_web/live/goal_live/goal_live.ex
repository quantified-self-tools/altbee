defmodule AltbeeWeb.GoalLive do
  use AltbeeWeb, :live_view

  require Logger

  @goal_poll_interval 400

  alias Altbee.{Datapoints, Goals}

  alias AltbeeWeb.AddDataComponent
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
        |> assign(:slug, slug)
        |> assign(:page_title, "#{slug} · #{user.username}")
        |> assign(:goal, goal)
        |> watch_goal()
      end)

    {:ok, socket}
  end

  def handle_event(
        "update-datapoint",
        %{"value" => value, "comment" => comment, "id" => id},
        socket
      ) do
    send(self(), {:update_datapoint, id, value, comment})

    socket =
      socket
      |> assign(:waiting, true)

    {:noreply, socket}
  end

  def handle_event("delete-datapoint", %{"datapoint-id" => id}, socket) do
    send(self(), {:delete_datapoint, id})

    socket =
      socket
      |> assign(:waiting, true)

    {:noreply, socket}
  end

  def handle_event("refresh", _, socket) do
    send(self(), :refresh)

    socket =
      socket
      |> assign(:waiting, true)

    {:noreply, socket}
  end

  defp waiting?(%Phoenix.LiveView.Socket{} = socket) do
    waiting?(socket.assigns)
  end

  defp waiting?(%{waiting: waiting, goal: goal}) do
    waiting || goal["queued"]
  end

  defp waiting?(_), do: false

  defp enqueue_goal_poll() do
    Process.send_after(self(), :poll_queued_goal, @goal_poll_interval)
  end

  defp watch_goal(socket) do
    if connected?(socket) && waiting?(socket) do
      enqueue_goal_poll()
    end

    socket
  end

  def handle_info({:new_datapoint_entered, _slug}, socket) do
    socket =
      socket
      |> assign(:waiting, true)

    enqueue_goal_poll()

    {:noreply, socket}
  end

  def handle_info({:new_datapoint_submitted, _slug}, socket) do
    {:noreply, socket}
  end

  def handle_info(:poll_queued_goal, socket) do
    send(self(), :refresh)

    if waiting?(socket) do
      enqueue_goal_poll()
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

    enqueue_goal_poll()

    Task.start(fn ->
      Datapoints.delete_datapoint!(goal["slug"], id, user.access_token)
    end)

    {:noreply, socket}
  end

  def handle_info({:update_datapoint, id, value, comment}, socket) do
    %{goal: goal, user: user} = socket.assigns

    enqueue_goal_poll()

    Task.start(fn ->
      Datapoints.update_datapoint!(goal["slug"], id, user.access_token, value, comment)
    end)

    {:noreply, socket}
  end
end
