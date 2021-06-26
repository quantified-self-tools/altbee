defmodule AltbeeWeb.HomeLive.GoalComponent do
  use AltbeeWeb, :live_component

  alias AltbeeWeb.HomeLive.{GoalDropdownComponent, GoalGraphComponent}

  def todayta(%{"todayta" => false}), do: nil

  def todayta(%{"todayta" => true}) do
    ~E"""
    <svg class="inline-block w-4 h-4 mb-1 ml-1 text-gray-400 opacity-50" fill="none" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" viewBox="0 0 24 24" stroke="currentColor"><path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
    """
  end
end
