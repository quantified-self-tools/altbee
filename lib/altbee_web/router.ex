defmodule AltbeeWeb.Router do
  use AltbeeWeb, :router

  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {AltbeeWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug AltbeeWeb.Auth
  end

  pipeline :admin do
    if Mix.env() not in [:dev, :test] do
      plug AltbeeWeb.Admin
    end
  end

  scope "/", AltbeeWeb do
    pipe_through [:browser, :auth]

    live_session :default do
      live "/", HomeLive, :index
      live "/goal/:slug", GoalLive, :show
      live "/settings", SettingsLive, :index
    end
  end

  scope "/", AltbeeWeb do
    pipe_through :browser
    get "/login", UserController, :login

    get "/graph-proxy", GraphProxyController, :index
  end

  scope "/api", AltbeeWeb do
    pipe_through :api
    post "/bagg", BaggController, :index
  end

  scope "/" do
    pipe_through [:browser, :auth, :admin]
    live_dashboard "/dashboard", metrics: AltbeeWeb.Telemetry, ecto_repos: [Altbee.Repo]
  end
end
