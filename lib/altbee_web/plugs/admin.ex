defmodule AltbeeWeb.Admin do
  import Plug.Conn
  import Phoenix.Controller

  def init(opts), do: opts

  def call(conn, _opts) do
    admins = Application.fetch_env!(:altbee, :admin_usernames)
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
