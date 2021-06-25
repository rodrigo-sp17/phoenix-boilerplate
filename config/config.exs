# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :portal,
  ecto_repos: [Portal.Repo]

# Configures the endpoint
config :portal, PortalWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "NQ4grLij7jlDyqsADrsy6arrq1bOmS/pDa980HDzh2RxkeKXtvi1GWmixaqatOUb",
  render_errors: [view: PortalWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Portal.PubSub,
  live_view: [signing_salt: "O0JDCXlV"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :argon2_elixir,
  t_cost: 8,
  m_cost: 17

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
