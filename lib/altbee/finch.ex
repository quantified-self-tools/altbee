defmodule Altbee.Finch do
  alias Altbee.BeeminderError

  def request_json(finch_request) do
    finch_request
    |> Finch.request(AltbeeFinch)
    |> case do
      {:ok, %{body: body, status: 200}} -> Jason.decode(body)
      {:ok, response} -> {:error, %BeeminderError{response: response}}
      {:error, _err} = error -> error
    end
  end
end
