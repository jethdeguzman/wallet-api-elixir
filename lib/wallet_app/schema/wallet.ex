defmodule WalletApp.Schema.Wallet do
  use Ecto.Schema

  import Ecto.Changeset
  
  alias WalletApp.Schema.Account

  schema "wallets" do
    field :uuid, :string
    field :currency, :string
    timestamps()
    belongs_to :account, Account
  end

  @required_fields [:uuid, :currency, :account_id]

  def changeset(wallet, params \\ %{}) do
    params = Map.put(params, :uuid, Ecto.UUID.generate())
    wallet
      |> cast(params, @required_fields)
      |> validate_length(:currency, min: 3)
      |> validate_format(:currency, ~r/^[A-Z]+$/)
      |> foreign_key_constraint(:account_id)
  end
end
