defmodule AltbeeWeb.HomeLive.GoalDropdownComponent do
  use AltbeeWeb, :live_component

  def menu_link_class do
    "flex items-center px-4 py-2 w-full
    text-sm leading-5 text-gray-700 group
    hover:bg-indigo-500 hover:text-white
    active:bg-indigo-500 active:text-white
    focus:outline-none focus:bg-indigo-500 focus:text-white"
  end

  def beeminder_url(%{user: user, goal: goal}) do
    "https://www.beeminder.com/#{user.username}/#{goal["slug"]}"
  end
end
