defmodule WalletApp.Account do
  alias WalletApp.Repo
  alias WalletApp.Accounts.User

  def create_user(username, password) do
    %User{}
    |> User.changeset(%{username: username, password: password})
    |> Repo.insert()
  end

  def get_user_by(%{username: username}), do: Repo.get_by(User, username: username)
  def get_user_by(%{uuid: uuid}), do: Repo.get_by(User, uuid: uuid)
end
