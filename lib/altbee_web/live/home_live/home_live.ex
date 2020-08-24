defmodule AltbeeWeb.HomeLive do
  use AltbeeWeb, :live_view

  alias __MODULE__.GoalComponent
  alias Altbee.{Accounts, Goals}
  import Goals.Color, only: [goal_color: 1]

  def mount(_params, %{"user_id" => user_id}, socket) do
    socket =
      socket
      |> assign_new(:user, fn -> Accounts.get_user(user_id) end)

    socket =
      if is_nil(socket.assigns.user) do
        redirect(socket, to: Routes.user_path(socket, :login))
      else
        socket
        |> assign(:page_title, "Goals")
        |> assign_new(:goals, fn -> Goals.fetch_goals!(socket.assigns.user) end)
        |> recalculate_filters([])
      end

    {:ok, socket}
  end

  def mount(_params, _session, socket) do
    socket = redirect(socket, to: Routes.user_path(socket, :login))

    {:ok, socket}
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
end
