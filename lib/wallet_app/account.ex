defmodule WalletApp.Account do
  import WalletApp.Util, only: [generate_session_token: 1]

  alias WalletApp.Exception.{InvalidLoginCredentialsError, ValidationError}
  alias WalletApp.Repo
  alias WalletApp.Schema.Account

  def create_account(username, password) do
    %Account{}
      |> Account.changeset(%{username: username, password: password})
      |> Repo.insert
      |> create_account_response
  end

  defp create_account_response({:error, _}), do: raise ValidationError
  defp create_account_response({:ok, %Account{uuid: uuid}}), do: uuid

  def login_account(username, password) do
    with(
      %Account{uuid: uuid, password: hashed_password} <- Repo.get_by(Account, username: username),
      true <- Bcrypt.verify_pass(password, hashed_password),
      {:ok, session_token} <- generate_session_token(uuid)
    ) do
      session_token
    else
       _ -> raise InvalidLoginCredentialsError
    end
  end
end
