# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :altbee,
  ecto_repos: [Altbee.Repo],
  generators: [binary_id: true]

admins =
  System.get_env("ALTBEE_ADMIN_USERNAMES", "")
  |> String.split(",")
  |> Enum.map(&String.trim/1)
  |> Enum.filter(&(&1 !== ""))
  |> MapSet.new()

config :altbee,
  beeminder_client_id: System.get_env("BEEMINDER_CLIENT_ID"),
  admin_usernames: admins

# Configures the endpoint
config :altbee, AltbeeWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: AltbeeWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Altbee.PubSub,
  live_view: [signing_salt: "pzlNYucz"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :altbee, Altbee.Mailer, adapter: Swoosh.Adapters.Local

config :altbee,
  goals_base_url: "https://www.beeminder.com/api/v1/users/me/goals",
  user_data_url: "https://www.beeminder.com/api/v1/users/me.json",
  user_base_url: "https://www.beeminder.com/api/v1/users/me",
  root_url: "https://www.beeminder.com"

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.41",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ],
  sw: [
    args: ~w(js/sw.js --bundle --target=es2017 --outdir=../priv/static/),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :tailwind,
  version: "3.1.6",
  default: [
    args: ~w(
    --config=tailwind.config.js
    --input=css/app.css
    --output=../priv/static/assets/app.css
  ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :floki, :html_parser, Floki.HTMLParser.Html5ever
config :html5ever, Html5ever, build_from_source: true

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
