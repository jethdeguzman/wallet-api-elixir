use Mix.Config

config :wallet, Wallet.Repo,
  adapter: Sqlite.Ecto2,
  database: "wallet_test.sqlite3",
  pool: Ecto.Adapters.SQL.Sandbox
