defmodule WalletApp.Schema.Account do
  use Ecto.Schema

  import Ecto.Changeset

  schema "accounts" do
    field :uuid, :string, default: Ecto.UUID.generate()
    field :username, :string
    field :password, :string
    timestamps()
  end

  @required_fields [:username, :password]

  def changeset(account, params \\ %{}) do
    account
      |> cast(params, @required_fields)
      |> validate_required(@required_fields)
      |> validate_format(:username, ~r/^[a-zA-Z0-9_]+$/)
      |> validate_length(:password, min: 6)
      |> unsafe_validate_unique([:username], WalletApp.Repo) #unique_constraint is not properly working with sqlite
      |> generate_hash_password
  end

  defp generate_hash_password(changeset) do
    hashed_password = get_change(changeset, :password) |> Bcrypt.hash_pwd_salt
    changeset |> put_change(:password, hashed_password)
  end
end
