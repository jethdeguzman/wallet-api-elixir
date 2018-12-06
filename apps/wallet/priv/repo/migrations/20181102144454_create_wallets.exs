defmodule WalletApp.Repo.Migrations.CreateWallets do
  use Ecto.Migration

  def change do
  	create table(:wallets) do
  	  add :uuid, :string
  	  add :currency, :string
  	  add :user_id, references(:users), null: false
  	  timestamps()
  	end
  end
end
