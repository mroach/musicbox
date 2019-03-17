# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :musicbox, MusicboxWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "246IYA44dA3iQW/vt9C+UVz99VMmG2uuYF2ceJJ9cyfX0+nAttNDwI3wnUt0pRbw",
  render_errors: [view: MusicboxWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Musicbox.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: System.get_env("LIVE_VIEW_SIGNING_SALT")]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Register LiveView.Engine for .leex files
config :phoenix,
  template_engines: [leex: Phoenix.LiveView.Engine]

config :paracusia,
  hostname: System.get_env("MPD_HOST"),
  password: System.get_env("MPD_PASS"),
  port: System.get_env("MPD_PORT") |> String.to_integer,
  retry_after: 100,
  max_retry_attempts: 3

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
