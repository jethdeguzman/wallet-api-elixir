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

  test "successful login" do
    username = "testuser"
    password = "password"

    Accounts.register(username, password)
    assert {:ok, _session_token} = Accounts.login(username, password)
  end

  test "password not matched login" do
    username = "testuser"
    password = "password"
    wrongpass = "wrongpass"

    Accounts.register(username, password)
    assert {:error, "Invalid login credentials"} = Accounts.login(username, wrongpass)
  end

  test "account does not exist login" do
    username = "testuser"
    password = "password"

    assert {:error, "Invalid login credentials"} = Accounts.login(username, password)
  end
end
