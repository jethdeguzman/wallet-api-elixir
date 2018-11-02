defmodule WalletApp.Account do
  alias WalletApp.Repo
  alias WalletApp.Schema.Account

  import Application, only: [get_env: 2]

  @jwt_opts %{alg: get_env(:wallet_app, :jwt_alg), key: get_env(:wallet_app, :jwt_key)}

  def create_account(username, password) do
    %Account{}
      |> Account.changeset(%{username: username, password: password})
      |> Repo.insert
      |> create_account_response
  end

  defp create_account_response({:error, _}), do: raise "Validation error"
  defp create_account_response({:ok, %Account{uuid: uuid}}), do: uuid

  def login_account(username, password) do
    Repo.get_by(Account, username: username)
      |> validate_password(password)
      |> generate_session_token
  end

  def generate_session_token(%Account{uuid: account_id}) do
    %{account_id: account_id, exp: DateTime.to_unix(DateTime.utc_now()) + 60*60}
      |> JsonWebToken.sign(@jwt_opts)
  end

  defp validate_password(nil, _), do: raise "Account doess not exist"
  defp validate_password(%Account{password: hashed_password} = account, password) do
    Bcrypt.verify_pass(password, hashed_password)
      |> case do
          false -> raise "Invalid login credentials"
          true -> account
        end
  end
end
