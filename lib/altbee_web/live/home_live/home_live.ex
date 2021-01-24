defmodule AltbeeWeb.HomeLive do
  use AltbeeWeb, :live_view

  alias __MODULE__.GridComponent
  alias Altbee.{Accounts, Goals, Tags}
  import Goals.Color, only: [goal_color: 1]

  def mount(_params, %{"user_id" => user_id}, socket) do
    socket =
      with_user(socket, user_id, fn socket ->
        user = socket.assigns.user

        if connected?(socket) do
          Accounts.refresh_user_async(user)
          Tags.refresh_tags_async(user)
        end

        goals_from_cache = sort_goals(Goals.load_goals_from_cache(user))

        tags_from_cache = Tags.load_tags_from_cache(user)

        socket
        |> assign(:goals, goals_from_cache)
        |> assign(:tags, tags_from_cache)
        |> assign(:filters, [])
        |> assign(:goal_groups, Goals.load_groups(user))
        |> recalculate_filters()
        |> assign(:page_title, "Goals")
      end)

    {:ok, socket}
  end

  defp filter_goals(goals, tags, filters) do
    goals
    |> Enum.filter(fn goal ->
      fields =
        [
          normalize_string(goal["slug"]),
          normalize_string(goal["title"]),
          normalize_string(goal["gunits"]),
          to_string(goal_color(goal["safebuf"]))
        ] ++ Map.get(tags, goal["slug"], [])

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
      |> assign(:filters, filters)
      |> recalculate_filters()

    {:noreply, socket}
  end

  def handle_event("filter-keydown", %{"key" => "Enter"}, socket) do
    case socket.assigns.filtered_goals do
      [goal | _rest] ->
        goal_route = Routes.goal_path(socket, :show, goal["slug"])
        {:noreply, redirect(socket, to: goal_route)}

      [] ->
        {:noreply, socket}
    end
  end

  def handle_event("filter-keydown", _, socket) do
    {:noreply, socket}
  end

  def handle_event("refresh", _, socket) do
    Accounts.refresh_user_async(socket.assigns.user)
    Tags.refresh_tags_async(socket.assigns.user)

    socket =
      socket
      |> assign(:goals, [])
      |> assign(:filters, [])
      |> recalculate_filters()

    {:noreply, socket}
  end

  defp recalculate_filters(%{assigns: %{goals: goals, filters: filters, tags: tags}} = socket) do
    assign(socket, :filtered_goals, filter_goals(goals, tags, filters))
  end

  defp normalize_string(nil), do: ""

  defp normalize_string(string)
       when is_binary(string) do
    string
    |> :string.casefold()
    |> :unicode.characters_to_nfkd_binary()
  end

  def no_goals_shown_message(%{goals: [], user: %{goals: []}} = assigns) do
    live_component(assigns.socket, __MODULE__.EmptyState.NoGoalsAtAllComponent, assigns)
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

  def no_goals_shown_message(%{filtered_goals: []} = assigns) do
    ~L"""
    <div class="flex justify-center">
      <div class="rounded-md bg-blue-200 py-4 sm:py-5 px-6 sm:px-10 mx-4 max-w-max">
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
      |> recalculate_filters()

    {:noreply, socket}
  end

  def handle_info({:tags, tags}, socket) do
    socket =
      socket
      |> assign(:tags, tags)
      |> recalculate_filters()

    {:noreply, socket}
  end

  def handle_info({:user, user}, socket) do
    # Avoid showing cached goals that the user
    # has since deleted or archived.
    goals =
      socket.assigns.goals
      |> Enum.filter(fn goal -> goal["slug"] in user.goals end)

    unless goal_cache_is_up_to_date?(goals, user, socket.assigns.user) do
      Goals.load_goals_async(user)
    end

    socket =
      socket
      |> assign(:user, user)
      |> assign(:goals, goals)
      |> recalculate_filters()

    {:noreply, socket}
  end

  def sort_goals(goals) do
    Enum.sort_by(goals, fn goal ->
      {
        goal["losedate"],
        goal["pledge"],
        goal["slug"]
      }
    end)
  end

  defp goal_cache_is_up_to_date?(goals, new_user, old_user) do
    new_user.beeminder_updated == old_user.beeminder_updated &&
      MapSet.equal?(
        MapSet.new(Enum.map(goals, & &1["slug"])),
        MapSet.new(new_user.goals)
      )
  end

  def sectioned_goals(filtered_goals, goal_groups, tags) do
    groups =
      goal_groups
      |> Enum.map(fn group ->
        group_tags = MapSet.new(group.tags)

        goals =
          filtered_goals
          |> Enum.filter(fn %{"slug" => slug} ->
            tags
            |> Map.get(slug, [])
            |> Enum.any?(fn tag ->
              MapSet.member?(group_tags, tag)
            end)
          end)

        {group.id, group.name, goals}
      end)
      |> Enum.filter(fn
        {_, _, []} -> false
        _ -> true
      end)

    grouped_goal_slugs =
      groups
      |> Enum.flat_map(fn {_, _, goals} -> goals end)
      |> Enum.map(fn goal -> goal["slug"] end)
      |> MapSet.new()

    main_group =
      {:main, "main",
       Enum.filter(filtered_goals, fn goal ->
         goal["roadstatuscolor"] == "red" || !MapSet.member?(grouped_goal_slugs, goal["slug"])
       end)}

    [main_group | groups]
  end
end
