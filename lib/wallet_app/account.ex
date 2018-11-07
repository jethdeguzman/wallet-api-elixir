defmodule WalletApp.Account do
  alias WalletApp.Repo
  alias WalletApp.Schema.Account

  def create_account(username, password) do
    %Account{}
      |> Account.changeset(%{username: username, password: password})
      |> Repo.insert
  end

  def get_account_by(%{username: username}), do: Repo.get_by(Account, username: username)
  def get_account_by(%{uuid: uuid}), do: Repo.get_by(Account, uuid: uuid)
end
