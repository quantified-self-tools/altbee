defmodule AltbeeWeb.LiveHelpers do
  import Phoenix.LiveView
  import Phoenix.Component

  alias AltbeeWeb.Router.Helpers, as: Routes

  alias Altbee.Accounts

  def redirect_to_login_page(socket) do
    redirect(socket, to: Routes.user_path(socket, :login))
  end

  def assign_user(socket, user_id) do
    assign_new(socket, :user, fn -> Accounts.get_user(user_id) end)
  end

  def with_user(socket, user_id, callback)
      when is_function(callback, 1) do
    socket = assign_user(socket, user_id)

    if is_nil(socket.assigns.user) do
      redirect_to_login_page(socket)
    else
      callback.(socket)
    end
  end

  def display_value(value) do
    floored = floor(value)

    if floored == value do
      floored
    else
      value
    end
    |> to_string
  end

  def display_daystamp(daystamp) do
    [
      String.slice(daystamp, 0, 4),
      String.slice(daystamp, 4, 2),
      String.slice(daystamp, 6, 2)
    ]
    |> Enum.join("-")
  end
end
