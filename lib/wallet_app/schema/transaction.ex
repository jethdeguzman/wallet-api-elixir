defmodule WalletApp.Schema.Transaction do
  use Ecto.Schema

  alias WalletApp.Schema.Wallet

  schema "transactions" do
    field(:uuid, :string)
    field(:type, :string)
    field(:description, :string)
    field(:amount, :decimal)
    field(:balance, :decimal)
    timestamps()
    belongs_to(:wallet, Wallet)
  end
end
