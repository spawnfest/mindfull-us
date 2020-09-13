# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :mindfull,
  ecto_repos: [Mindfull.Repo]

# Configures the endpoint
config :mindfull, MindfullWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "s7gzqdVjp+BkEnwa6nzk2MphrKV3uQ6weyKiMTVdnszpuojo+WPujWWMDxDZkDpd",
  render_errors: [view: MindfullWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Mindfull.PubSub,
  live_view: [signing_salt: "QQPXRd8N"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :mindfull, Mindfull.Emails.Mailer, adapter: Bamboo.LocalAdapter
# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
