# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :sips, Sips.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "tbyTDN//nF7vcAJqg6Q0Kfsck0yl80lvIm9qjrlsg62JRw0RsBbn9GlNKDly1l9c",
  render_errors: [accepts: ~w(json)],
  pubsub: [name: Sips.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :format_encoders,
  "json-api": Poison

config :plug, :mimes, %{
    "application/vnd.api+json" => ["json-api"]
  }

config :guardian, Guardian,
  allowed_algos: ["HS512"],
  verify_module: Guardian.JWT,
  issuer: "Sips",
  ttl: {30, :days},
  verify_issuer: true,
  secret_key: System.get_env("GUARDIAN_SECRET") || "yDU3uq8bxJwHz3P785YE/5MTPSVKQYuuH9HWumqgNvp508Ybq5o5p1Rx20coVclD",
  serializer: Sips.GuardianSerializer

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false
