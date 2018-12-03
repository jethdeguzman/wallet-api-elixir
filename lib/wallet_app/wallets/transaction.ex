defmodule WalletApp.Wallets.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  alias WalletApp.Wallets.Wallet

  schema "transactions" do
    field(:uuid, :string)
    field(:type, :string)
    field(:description, :string)
    field(:amount, :decimal)
    field(:balance, :decimal)
    belongs_to(:wallet, Wallet)

    timestamps()
  end

  def changeset(transaction, attrs \\ %{}) do
    attrs = Map.put(attrs, :uuid, Ecto.UUID.generate())

    transaction
    |> cast(attrs, [:uuid, :type, :description, :amount, :balance, :wallet_id])
    |> validate_required([:type, :description, :amount, :balance, :wallet_id])
  end
end
