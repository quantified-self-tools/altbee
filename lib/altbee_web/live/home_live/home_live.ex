defmodule AltbeeWeb.HomeLive do
  use AltbeeWeb, :live_view

  alias __MODULE__.GoalComponent
  alias Altbee.{Accounts, Goals}

  def mount(_params, %{"user_id" => user_id}, socket) do
    socket =
      socket
      |> assign_new(:user, fn -> Accounts.get_user(user_id) end)

    socket =
      if is_nil(socket.assigns.user) do
        redirect(socket, to: Routes.user_path(socket, :login))
      else
        socket
        |> assign(:page_title, "Goals")
        |> assign_new(:goals, fn -> Goals.fetch_goals!(socket.assigns.user) end)
      end

    {:ok, socket}
  end

  def mount(_params, _session, socket) do
    socket = redirect(socket, to: Routes.user_path(socket, :login))

    {:ok, socket}
  end
end
