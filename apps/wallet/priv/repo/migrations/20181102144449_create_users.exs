defmodule WalletApp.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :uuid, :string
      add :username, :string, unique: true
      add :password, :string
      timestamps()
    end
    create unique_index(:users, [:username])
  end
end
