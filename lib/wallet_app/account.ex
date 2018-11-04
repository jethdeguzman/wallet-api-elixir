defmodule WalletApp.Account do
  alias WalletApp.Repo
  alias WalletApp.Schema.Account

  import Application, only: [get_env: 2]

  @one_hour 60*60
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
    with(
      %Account{uuid: uuid, password: hashed_password} <- Repo.get_by(Account, username: username),
      true <- Bcrypt.verify_pass(password, hashed_password),
      {:ok, session_token} <- generate_session_token(uuid)
    ) do 
      session_token 
    else
       _ -> raise "Invalid login credentials"
    end
  end

  def generate_session_token(account_uuid) do
    %{account_uuid: account_uuid, exp: DateTime.to_unix(DateTime.utc_now()) + @one_hour}
      |> JsonWebToken.sign(@jwt_opts)
      |> (&({:ok, &1})).()
  end
end
