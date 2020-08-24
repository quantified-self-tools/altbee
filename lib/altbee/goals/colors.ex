defmodule Altbee.Goals.Color do
  @type goal_color :: :red | :orange | :blue | :green | :gray
  @spec goal_color(integer()) :: goal_color()
  def goal_color(safebuf) do
    cond do
      safebuf < 1 -> :red
      safebuf < 2 -> :orange
      safebuf < 3 -> :blue
      safebuf < 7 -> :green
      true -> :gray
    end
  end

  @spec goal_color_bg_class(goal_color()) :: String.t()
  def goal_color_bg_class(:red), do: "bg-red-500"
  def goal_color_bg_class(:orange), do: "bg-orange-300"
  def goal_color_bg_class(:blue), do: "bg-blue-400"
  def goal_color_bg_class(:green), do: "bg-green-400"
  def goal_color_bg_class(:gray), do: "bg-teal-400"
end
