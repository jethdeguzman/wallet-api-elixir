# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :wallet, Wallet.Repo,
  adapter: Sqlite.Ecto2,
  database: "wallet.sqlite3"

config :wallet, ecto_repos: [Wallet.Repo]

config :wallet, jwt_alg: "HS256", jwt_key: "Bs0PzP3VV5pHtaE4M4nJblvnVphq6oVS"

import_config "#{Mix.env()}.exs"
