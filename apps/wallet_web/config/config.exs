# Since configuration is shared in umbrella projects, this file
# should only configure the :wallet_web application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

# General application configuration
config :wallet_web,
  generators: [context_app: false]

# Configures the endpoint
config :wallet_web, WalletWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "v3QslB8zPx9WI6m46iL0x0OeF7i29rsKNvVqkVSEvgFnaXAVEwnJ2TntVVyE/47j",
  render_errors: [view: WalletWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: WalletWeb.PubSub, adapter: Phoenix.PubSub.PG2]

config :phoenix, :json_library, Jason
# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
