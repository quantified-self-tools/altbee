defmodule AltbeeWeb.SettingsLive.GoalGroupComponent do
  use AltbeeWeb, :live_component

  def drag_handle(assigns) do
    ~H"""
    <div data-drag-handle class="mr-3 text-gray-400">
      <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 16 16">
        <path d="M7 2a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm3 0a1 1 0 1 1-2 0 1 1 0 0 1 2 0zM7 5a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm3 0a1 1 0 1 1-2 0 1 1 0 0 1 2 0zM7 8a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm3 0a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm-3 3a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm3 0a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm-3 3a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm3 0a1 1 0 1 1-2 0 1 1 0 0 1 2 0z" />
      </svg>
    </div>
    """
  end

  def error_msg(assigns) do
    ~H"""
    <span class="inline-block ml-3 text-red-700 truncate">
      <%= @error %>
    </span>
    """
  end

  def name(%{editing: true} = assigns) do
    ~H"""
    <input
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

  def unique_id() do
    Ecto.UUID.generate()
  end
end
