defmodule AltbeeWeb.SettingsLive.GoalGroupComponent do
  use AltbeeWeb, :live_component

  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)

    socket =
      if changed?(socket, :editing) do
        num_new_tags =
          if !socket.assigns.group.tags || Enum.empty?(socket.assigns.group.tags), do: 1, else: 0

        socket
        |> assign(:num_new_tags, num_new_tags)
      else
        socket
      end

    {:ok, socket}
  end

  def handle_event("new-tag", _, socket) do
    socket =
      socket
      |> update(:num_new_tags, &(&1 + 1))

    {:noreply, socket}
  end

  def drag_handle(assigns) do
    ~H"""
    <div data-drag-handle class="mr-3 text-gray-400">
      <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 16 16">
        <path d="M7 2a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm3 0a1 1 0 1 1-2 0 1 1 0 0 1 2 0zM7 5a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm3 0a1 1 0 1 1-2 0 1 1 0 0 1 2 0zM7 8a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm3 0a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm-3 3a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm3 0a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm-3 3a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm3 0a1 1 0 1 1-2 0 1 1 0 0 1 2 0z" />
      </svg>
    </div>
    """
  end

  attr :error, :string, required: true

  def error_msg(assigns) do
    ~H"""
    <span class="inline-block ml-3 text-red-700 truncate">
      <%= @error %>
    </span>
    """
  end

  attr :id, :string, required: true
  attr :group_name, :string, required: true
  attr :editing, :boolean, required: true

  def name(%{editing: true} = assigns) do
    ~H"""
    <input
      id={"group-name-input-#{@id}"}
      placeholder="Category name…"
      name="name"
      maxlength="80"
      class="max-w-full rounded"
      x-data={"{
        name: '#{javascript_escape(@group_name)}'
      }"}
      x-model="name"
      x-init={
        if @group_name == "",
          do: "$el.focus(); $el.scrollIntoView({ block: 'center', behavior: 'smooth'})"
      }
      type="text"
    />
    """
  end

  def name(%{editing: false} = assigns) do
    ~H"""
    <span class="inline-block max-w-full font-medium text-indigo-600 truncate">
      <%= @group_name %>
    </span>
    """
  end
end
