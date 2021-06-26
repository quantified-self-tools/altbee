defmodule AltbeeWeb.HomeLive.GridComponent do
  use AltbeeWeb, :live_component

  alias AltbeeWeb.HomeLive.GoalComponent

  def grid(:compact) do
    "grid gap-3 lg:gap-4 grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 2xl:grid-cols-6"
  end

  def grid(:spacious) do
    "grid gap-3 lg:gap-4 grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 2xl:grid-cols-5"
  end
end
