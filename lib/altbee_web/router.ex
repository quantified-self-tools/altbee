defmodule AltbeeWeb.Router do
  use AltbeeWeb, :router

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

  scope "/", AltbeeWeb do
    pipe_through :browser

    live "/", HomeLive, :index
    live "/goal/:slug", GoalLive, :show
    get "/login", UserController, :login
  end

  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: AltbeeWeb.Telemetry
    end
  end
end
