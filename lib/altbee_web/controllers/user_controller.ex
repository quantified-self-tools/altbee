defmodule AltbeeWeb.UserController do
  use AltbeeWeb, :controller

  alias Altbee.Accounts

  @beeminder_client_id Application.get_env(:altbee, :beeminder_client_id)
  @beeminder_root "https://www.beeminder.com"

  def login(conn, %{"username" => _username, "access_token" => token}) do
    user = Accounts.create_user(token)

    conn
    |> put_session(:user_id, user.id)
    |> redirect(to: Routes.home_path(conn, :index))
  end

  def login(conn, _params) do
    conn
    |> assign(:page_title, "Sign in")
    |> render("login.html", login_url: login_url(conn))
  end

  defp login_url(conn) do
    "#{@beeminder_root}/apps/authorize?" <>
      "client_id=#{@beeminder_client_id}" <>
      "&redirect_uri=#{Routes.user_url(conn, :login)}" <>
      "&response_type=token"
  end
end
