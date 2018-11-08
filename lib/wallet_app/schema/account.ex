defmodule WalletApp.Schema.Account do
  use Ecto.Schema

  import Ecto.Changeset

  alias WalletApp.Schema.Wallet

  schema "accounts" do
    field :uuid, :string
    field :username, :string
    field :password, :string
    timestamps()
    has_many :wallets, Wallet
  end

  @required_fields [:uuid, :username, :password]

  def changeset(account, params \\ %{}) do
    params = Map.put(params, :uuid, Ecto.UUID.generate())
    account
      |> cast(params, @required_fields)
      |> validate_required(@required_fields)
      |> validate_format(:username, ~r/^[a-zA-Z0-9_-]+$/)
      |> validate_length(:password, min: 6)
      |> unsafe_validate_unique([:username], WalletApp.Repo) #unique_constraint is not properly working with sqlite
      |> generate_hash_password
  end

  defp generate_hash_password(changeset) do
    hashed_password = get_change(changeset, :password) |> Bcrypt.hash_pwd_salt
    changeset |> put_change(:password, hashed_password)
  end
end
