defmodule WalletApp.Wallets.Wallet do
  use Ecto.Schema
  import Ecto.Changeset

  alias WalletApp.Accounts.User
  alias WalletApp.Wallets.Transaction

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
    |> cast(attrs, [:uuid, :currency, :user_id])
    |> validate_required([:uuid, :currency, :user_id])
    |> validate_length(:currency, min: 3)
    |> validate_format(:currency, ~r/^[A-Z]+$/)
    |> foreign_key_constraint(:user_id)
  end
end
