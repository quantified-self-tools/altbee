import Config

host =
  System.get_env("ALTBEE_HOST") ||
    raise """
    environment variable ALTBEE_HOST is missing.
    for example: altbee.aeonc.com
    """

config :altbee, AltbeeWeb.Endpoint,
  url: [host: host, port: 443, scheme: "https"],
  cache_static_manifest: "priv/static/cache_manifest.json"

config :logger, level: :info

import_config "prod.secret.exs"
