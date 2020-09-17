defmodule AltbeeWeb.HomeLive.GoalDropdownComponent do
  use AltbeeWeb, :live_component

  def menu_link_class do
    "flex items-center px-4 py-2 text-sm leading-5 text-gray-700 hover:underline focus:bg-cool-gray-100 hover:text-gray-800 focus:outline-none focus:text-gray-800 group"
  end

  def beeminder_url(%{user: user, goal: goal}) do
    "https://www.beeminder.com/#{user.username}/#{goal["slug"]}"
  end
end
