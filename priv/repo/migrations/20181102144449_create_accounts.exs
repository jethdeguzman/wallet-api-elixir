defmodule WalletApp.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add :uuid, :string
      add :username, :string, unique: true
      add :password, :string
      timestamps()
    end
    create unique_index(:accounts, [:username])
  end
end
