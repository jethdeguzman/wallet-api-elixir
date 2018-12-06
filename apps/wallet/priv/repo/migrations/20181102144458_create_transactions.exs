defmodule Wallet.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add(:uuid, :string)
      add(:type, :string)
      add(:description, :string)
      add(:amount, :decimal)
      add(:balance, :decimal)
      add(:wallet_id, references(:wallets), null: false)
      timestamps()
    end
  end
end
