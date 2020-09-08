defmodule Altbee.Datapoints do
  @spec parse_datapoint(String.t()) ::
          {:ok, number()} | {:error, :empty} | {:error, :number} | {:error, :time}
  def parse_datapoint(value) do
    cond do
      value == "" ->
        {:error, :empty}

      String.contains?(value, ":") ->
        case String.split(value, ":") do
          [hours, minutes] ->
            case {Integer.parse(hours), Integer.parse(minutes)} do
              {{h, ""}, {m, ""}} -> {:ok, h + m / 60}
              {_, _} -> {:error, :time}
            end

          _ ->
            {:error, :time}
        end

      true ->
        case Float.parse(value) do
          {float, ""} -> {:ok, float}
          :error -> {:error, :number}
          {_, _} -> {:error, :number}
        end
    end
  end
end
