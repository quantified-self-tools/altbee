defmodule Altbee.BeeminderError do
  defexception [:response]

  @impl true
  def message(%__MODULE__{response: response}) do
    body = inspect(response.body)
    "Beeminder API request got status code #{response.status}. Response body: #{body}"
  end
end
