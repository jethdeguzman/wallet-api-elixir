defmodule WalletAppTest do
  use ExUnit.Case

  alias WalletApp.Accounts
  alias WalletApp.Accounts.User

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(WalletApp.Repo)
  end

  test "successful account registration" do
    username = "testuser"
    password = "password"

    assert {:ok, _user} = Accounts.register(username, password)
  end

  test "invalid username registration" do
    username = "!@#$%^"
    password = "password"

    assert {:error, %{errors: [username: _] }} = Accounts.register(username, password)
  end

  test "invalid password registration" do
    username = "testuser"
    password = "pass"

    assert {:error, %{errors: [password: _]}} = Accounts.register(username, password)
  end
end
