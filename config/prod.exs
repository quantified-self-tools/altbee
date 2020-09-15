use Mix.Config

config :altbee, AltbeeWeb.Endpoint,
  url: [host: "altbee.aeonc.com", port: 443, scheme: "https"],
  cache_static_manifest: "priv/static/cache_manifest.json"

config :logger, level: :info

import_config "prod.secret.exs"
