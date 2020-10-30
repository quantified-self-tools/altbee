defmodule AltbeeWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :altbee

  @session_options [
    store: :cookie,
    key: "_altbee_key",
    signing_salt: "BhplVJTY8L0uxsiInK2BEYLZy0DTHDzjdpqQ7kvejt3roQgpWI",
    encryption_salt: "WWgguwKljSvvmDrLIMuJbXDwsK5IESfrCsOtQiiblJi4TGCGC4",
    same_site: "Lax",
    secure: Mix.env() != :dev,
    max_age: 31 * 24 * 60 * 60
  ]

  socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]

  plug Plug.Static,
    at: "/",
    from: :altbee,
    gzip: true,
    only: ~w(css fonts images js favicon.ico robots.txt manifest.webmanifest)

  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :altbee
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug AltbeeWeb.Router
end
