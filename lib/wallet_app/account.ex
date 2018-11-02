defmodule WalletApp.Account do
  alias WalletApp.Repo
  alias WalletApp.Schema.Account

  def create_account(username, password) do
    %Account{}
      |> Account.changeset(%{username: username, password: password})
      |> Repo.insert
      |> create_account_response
  end

  defp create_account_response({:error, _}), do: raise "Validation error"
  defp create_account_response({:ok, %Account{uuid: uuid}}), do: uuid
end
