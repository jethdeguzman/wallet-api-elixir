defmodule WalletApp.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
  	create table(:transactions) do
  	  add :uuid, :string
  	  add :type, :string
  	  add :descirption, :string
  	  add :amount, :decimal
  	  add :balance, :decimal
  	  add :wallet_id, references(:wallets)
  	  timestamps()
  	end
  end
end
