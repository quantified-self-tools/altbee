defmodule AltbeeWeb.Admin do
  import Plug.Conn
  import Phoenix.Controller

  @admin_usernames Application.compile_env(:altbee, :admin_usernames)

  def init(_opts) do
    %{
      admin_usernames: @admin_usernames
    }
  end

  def call(conn, %{admin_usernames: admins}) do
    username = conn.assigns.user && conn.assigns.user.username

    if username && username in admins do
      conn
    else
      conn
      |> put_status(403)
      |> text("Forbidden")
      |> halt()
    end
  end
end
