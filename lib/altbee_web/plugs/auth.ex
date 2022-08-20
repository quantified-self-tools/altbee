defmodule AltbeeWeb.Auth do
  import Plug.Conn
  import Phoenix.Controller

  alias AltbeeWeb.Router.Helpers, as: Routes
  alias Altbee.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)
    authenticate_user(conn, user_id)
  end

  defp authenticate_user(conn, nil) do
    redirect_to_login_page(conn)
  end

  defp authenticate_user(conn, user_id) do
    case Accounts.get_user(user_id) do
      nil ->
        redirect_to_login_page(conn)

      user ->
        conn
        |> put_session(:user_id, user_id)
        |> assign(:user, user)
    end
  end

  defp redirect_to_login_page(conn) do
    conn
    |> redirect(to: Routes.user_path(conn, :login))
    |> halt()
  end
end
