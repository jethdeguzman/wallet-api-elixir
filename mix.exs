defmodule WalletApp.MixProject do
  use Mix.Project

  def project do
    [
      app: :wallet_app,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {WalletApp.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:bcrypt_elixir, "~> 1.1.1"},
      {:sqlite_ecto2, "~> 2.2"},
      {:json_web_token, "~> 0.2.1"}
    ]
  end
end
