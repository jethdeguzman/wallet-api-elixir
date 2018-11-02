defmodule WalletApp.Account do
  alias WalletApp.Repo
  alias WalletApp.Schema.Account

  import Application, only: [get_env: 2]

  @jwt_opts %{alg: get_env(:wallet_app, :jwt_alg), key: get_env(:wallet_app, :jwt_key)}
  @jwt_exp DateTime.to_unix(DateTime.utc_now()) + 60*60

  def create_account(username, password) do
    %Account{}
      |> Account.changeset(%{username: username, password: password})
      |> Repo.insert
      |> create_account_response
  end

  defp create_account_response({:error, _}), do: raise "Validation error"
  defp create_account_response({:ok, %Account{uuid: uuid}}), do: uuid

  def login_account(username, password) do
    account = Repo.get_by(Account, username: username)
    
    unless account, do: raise "Account does not exist"
    
    case Bcrypt.verify_pass(password, account.password) do
      true -> generate_session_token(account)
      _ -> raise "Invalid login credentials"
    end
  end

  def generate_session_token(%Account{uuid: account_id}) do
    %{account_id: account_id, exp: @jwt_exp}
      |> JsonWebToken.sign(@jwt_opts)
  end
end
