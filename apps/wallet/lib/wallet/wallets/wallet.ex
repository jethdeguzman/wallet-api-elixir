defmodule Wallet.Wallets.Wallet do
  use Ecto.Schema
  import Ecto.Changeset

  alias Wallet.Accounts.User
  alias Wallet.Wallets.Transaction

  schema "wallets" do
    field(:uuid, :string)
    field(:currency, :string)
    belongs_to(:user, User)
    has_many(:transactions, Transaction)

    timestamps()
  end

  def changeset(wallet, attrs \\ %{}) do
    attrs = Map.put(attrs, :uuid, Ecto.UUID.generate())

    wallet
    |> cast(attrs, [:uuid, :currency])
    |> validate_required([:uuid, :currency])
    |> validate_length(:currency, min: 3)
    |> validate_format(:currency, ~r/^[A-Z]+$/)
  end
end
