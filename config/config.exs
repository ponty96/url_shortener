# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :url_shortener,
  ecto_repos: [UrlShortener.Repo]

# Configures the endpoint
config :url_shortener, UrlShortenerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Kx3gwwSLxz9Cab7qylEfQNrR1KkcHjoKX7wlRp4kMBuzrYvf+p9iw8eIupZzkeQM",
  render_errors: [view: UrlShortenerWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: UrlShortener.PubSub,
  live_view: [signing_salt: "+OalrXOs"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
