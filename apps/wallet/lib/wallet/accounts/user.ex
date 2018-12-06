defmodule Wallet.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Wallet.Repo, as: WalletRepo
  alias Wallet.Wallets.Wallet

  schema "users" do
    field(:uuid, :string)
    field(:username, :string)
    field(:password, :string)
    has_many(:wallets, Wallet)
    timestamps()
  end

  def changeset(user, attrs \\ %{}) do
    attrs = Map.put(attrs, :uuid, Ecto.UUID.generate())

    user
    |> cast(attrs, [:uuid, :username, :password])
    |> validate_required([:username, :password])
    |> validate_format(:username, ~r/^[a-zA-Z0-9_-]+$/)
    |> validate_length(:password, min: 6)
    # unique_constraint is not properly working with sqlite
    |> unsafe_validate_unique([:username], WalletRepo)
    |> generate_hash_password
  end

  defp generate_hash_password(changeset) do
    hashed_password = get_change(changeset, :password) |> Bcrypt.hash_pwd_salt()
    changeset |> put_change(:password, hashed_password)
  end
end
