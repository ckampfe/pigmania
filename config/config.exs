# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :pigmania,
  ecto_repos: [Pigmania.Repo]

# Configures the endpoint
config :pigmania, PigmaniaWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "54xaKU7/LhsIGYFy2X0vExRj2FMvi57W8X2pElT+EZA5LyNI3M+Mos/PD22ZDeXK",
  render_errors: [view: PigmaniaWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Pigmania.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: "fIw0FsNefogfvFbn+/AtLa9Gkd1FkB4k"
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
