# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

admins =
  System.get_env("ALTBEE_ADMIN_USERNAMES", "")
  |> String.split(",")
  |> Enum.map(&String.trim/1)
  |> Enum.filter(&(&1 !== ""))
  |> MapSet.new()

config :altbee,
  ecto_repos: [Altbee.Repo],
  generators: [binary_id: true],
  beeminder_client_id:
    System.get_env("BEEMINDER_CLIENT_ID") ||
      raise("""
      environment variable BEEMINDER_CLIENT_ID is missing
      """),
  admin_usernames: admins

config :altbee,
  goals_base_url: "https://www.beeminder.com/api/v1/users/me/goals",
  user_data_url: "https://www.beeminder.com/api/v1/users/me.json",
  user_base_url: "https://www.beeminder.com/api/v1/users/me"

# Configures the endpoint
config :altbee, AltbeeWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "+9nj22814t5KEIS0PYPr76DLYiOTPunCoSFzVq49it46XT6cCSn/c0LWCsDubTok",
  render_errors: [view: AltbeeWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Altbee.PubSub,
  live_view: [signing_salt: "uBmvBpE2"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
