use Mix.Config

config :wallet_app, WalletApp.Repo,
  adapter: Sqlite.Ecto2,
  database: "wallet_test.sqlite3",
  pool: Ecto.Adapters.SQL.Sandbox
