defmodule WalletApp.Repo.Migrations.CreateWallets do
  use Ecto.Migration

  def change do
  	create table(:wallets) do
  	  add :uuid, :string
  	  add :currency, :string
  	  add :account_id, references(:accounts)
  	  timestamps()
  	end
  end
end
