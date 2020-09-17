defmodule AltbeeWeb.HomeLive do
  use AltbeeWeb, :live_view

  alias __MODULE__.GoalComponent
  alias Altbee.Goals
  import Goals.Color, only: [goal_color: 1]

  def mount(_params, %{"user_id" => user_id}, socket) do
    socket =
      with_user(socket, user_id, fn socket ->
        user = socket.assigns.user

        if connected?(socket) do
          Goals.load_goals_async(user)
        end

        goals_from_cache = sort_goals(Goals.load_goals_from_cache(user))

        socket
        |> assign(:goals, goals_from_cache)
        |> recalculate_filters([])
        |> assign(:page_title, "Goals")
      end)

    {:ok, socket}
  end

  def mount(_params, _session, socket) do
    {:ok, redirect_to_login_page(socket)}
  end

  defp filter_goals(goals, filters) do
    goals
    |> Enum.filter(fn goal ->
      fields = [
        normalize_string(goal["slug"]),
        normalize_string(goal["title"]),
        normalize_string(goal["gunints"]),
        to_string(goal_color(goal["safebuf"]))
      ]

      filters
      |> Enum.all?(fn filter ->
        fields
        |> Enum.any?(fn field ->
          String.contains?(field, filter)
        end)
      end)
    end)
  end

  def handle_event("filter-changed", %{"filter" => filter}, socket) do
    filters =
      filter
      |> String.split()
      |> Enum.map(&normalize_string/1)

    socket =
      socket
      |> recalculate_filters(filters)

    {:noreply, socket}
  end

  defp recalculate_filters(%{assigns: %{goals: goals}} = socket, filters) do
    assign(socket, :filtered_goals, filter_goals(goals, filters))
  end

  defp normalize_string(nil), do: ""

  defp normalize_string(string)
       when is_binary(string) do
    string
    |> :string.casefold()
    |> :unicode.characters_to_nfkd_binary()
  end

  def no_goals_shown_message(%{goals: []} = assigns) do
    ~L"""
    <div class="w-full flex justify-around mt-16">
      <div class="sk-chase">
        <div class="sk-chase-dot"></div>
        <div class="sk-chase-dot"></div>
        <div class="sk-chase-dot"></div>
        <div class="sk-chase-dot"></div>
        <div class="sk-chase-dot"></div>
        <div class="sk-chase-dot"></div>
      </div>
    </div>
    """
  end

  def no_goals_shown_message(%{goals: [], user: %{goals: []}} = assigns) do
    live_component(assigns.socket, __MODULE__.EmptyState.NoGoalsAtAllComponent, assigns)
  end

  def no_goals_shown_message(%{filtered_goals: []} = assigns) do
    ~L"""
    <div class="flex justify-center">
      <div class="rounded-md bg-blue-200 py-4 sm:py-5 px-6 sm:px-10 mx-4 max-w-max-content">
        <p class="leading-5 text-blue-700">
          You don't have any goals that match this filter.
        </p>
      </div>
    </div>
    """
  end

  def no_goals_shown_message(_assigns), do: nil

  def handle_info({:goal, goal}, socket) do
    goals =
      socket.assigns.goals
      |> Enum.filter(&(&1["slug"] !== goal["slug"]))
      |> (&[goal | &1]).()
      |> sort_goals()

    socket =
      socket
      |> assign(:goals, goals)
      |> recalculate_filters([])

    {:noreply, socket}
  end

  def sort_goals(goals) do
    Enum.sort_by(goals, fn goal -> {goal["losedate"], goal["slug"]} end)
  end
end
