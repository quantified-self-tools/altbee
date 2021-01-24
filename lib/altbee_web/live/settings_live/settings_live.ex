defmodule AltbeeWeb.SettingsLive do
  use AltbeeWeb, :live_view

  import Ecto.{Changeset, Query}

  alias Altbee.{Accounts, Tags}
  alias Altbee.Goals.GoalGroup
  alias Altbee.Repo

  alias __MODULE__.NoGoalGroupsComponent

  defmodule GoalGroupState do
    defstruct [:group, :editing, :error]

    def new(group) do
      %__MODULE__{
        group: group,
        editing: false,
        error: nil
      }
    end
  end

  def mount(_params, %{"user_id" => user_id}, socket) do
    socket = assign_new(socket, :user, fn -> Accounts.get_user(user_id) end)

    user = socket.assigns.user

    if connected?(socket) do
      Tags.refresh_tags_async(user)
    end

    tags_from_cache = Tags.load_tags_from_cache(user)

    goal_groups =
      from(g in GoalGroup,
        where: g.user_id == ^user.id,
        order_by: [desc: g.order, desc: g.inserted_at]
      )
      |> Repo.all()
      |> Enum.map(fn group ->
        {group.id, GoalGroupState.new(group)}
      end)

    socket =
      socket
      |> assign(:tags, tags_list(tags_from_cache))
      |> assign(:goal_groups, goal_groups)

    {:ok, socket}
  end

  def handle_info({:tags, tags}, socket) do
    socket =
      socket
      |> assign(:tags, tags_list(tags))

    {:noreply, socket}
  end

  def handle_event("new-goal-group", _, socket) do
    goal_groups = socket.assigns.goal_groups

    group = %GoalGroup{
      user_id: socket.assigns.user.id,
      id: Ecto.UUID.generate(),
      order: length(goal_groups),
      tags: nil,
      name: ""
    }

    state =
      group
      |> GoalGroupState.new()
      |> Map.put(:editing, true)

    goal_groups = [{group.id, state} | goal_groups]

    socket =
      socket
      |> assign(:goal_groups, goal_groups)

    {:noreply, socket}
  end

  def handle_event("delete-goal-group", %{"id" => id}, socket) do
    goal_groups =
      Enum.flat_map(socket.assigns.goal_groups, fn
        {^id, %{editing: true, group: group} = state} ->
          case Repo.delete(group, stale_error_field: :stale) do
            {:ok, _} ->
              []

            {:error, ch} ->
              if ch.errors[:stale] do
                []
              else
                error = goal_group_errors(ch)
                [{id, %{state | error: error}}]
              end
          end

        x ->
          [x]
      end)

    socket =
      socket
      |> assign(:goal_groups, goal_groups)

    {:noreply, socket}
  end

  def handle_event("save-goal-group", %{"id" => id} = params, socket) do
    goal_groups =
      socket.assigns.goal_groups
      |> Enum.map(fn
        {^id, %{group: group} = state} ->
          group
          |> GoalGroup.changeset(params)
          |> Repo.insert_or_update()
          |> case do
            {:ok, group} ->
              {id, GoalGroupState.new(group)}

            {:error, err} ->
              {id, %{state | error: goal_group_errors(err)}}
          end

        x ->
          x
      end)

    socket =
      socket
      |> assign(:goal_groups, goal_groups)

    {:noreply, socket}
  end

  def handle_event("edit-goal-group", %{"id" => id}, socket) do
    goal_groups =
      Enum.map(socket.assigns.goal_groups, fn
        {^id, state} -> {id, %{state | editing: true}}
        x -> x
      end)

    socket =
      socket
      |> assign(:goal_groups, goal_groups)

    {:noreply, socket}
  end

  def handle_event("sort", sortedIds, socket) do
    {:ok, _} =
      Repo.transaction(fn ->
        sortedIds
        |> Enum.with_index()
        |> Enum.map(fn {id, ix} ->
          Repo.update_all(from(g in GoalGroup, where: g.id == ^id), set: [order: ix])
        end)
      end)

    goal_groups_map = Map.new(socket.assigns.goal_groups)

    goal_groups =
      sortedIds
      |> Enum.reverse()
      |> Enum.map(fn id -> {id, goal_groups_map[id]} end)

    socket =
      socket
      |> assign(:goal_groups, goal_groups)

    {:noreply, socket}
  end

  defp goal_group_errors(changeset) do
    traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    |> Enum.map(fn {key, value} ->
      "#{key} #{value}"
    end)
    |> Enum.join(", ")
  end

  defp tags_list(tags) do
    tags
    |> Enum.flat_map(fn {_, tags} -> tags end)
    |> Enum.sort()
    |> Enum.uniq()
  end

  defp unique_id() do
    Ecto.UUID.generate()
  end

  def drag_handle() do
    ~E"""
    <div
      data-drag-handle
      class="mr-3 text-gray-400">
      <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 16 16"> <path d="M7 2a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm3 0a1 1 0 1 1-2 0 1 1 0 0 1 2 0zM7 5a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm3 0a1 1 0 1 1-2 0 1 1 0 0 1 2 0zM7 8a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm3 0a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm-3 3a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm3 0a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm-3 3a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm3 0a1 1 0 1 1-2 0 1 1 0 0 1 2 0z"/> </svg>
    </div>
    """
  end
end
