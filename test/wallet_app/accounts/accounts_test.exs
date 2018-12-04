defmodule WalletApp.AccountsTest do
  use ExUnit.Case

  alias WalletApp.Accounts

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(WalletApp.Repo)
  end

  @valid_username "testuser"
  @valid_password "password"
  @invalid_username "!@#$%^"
  @invalid_password "pass"

  describe "register/2" do
    test "successful account registration" do
      assert {:ok, _user} = Accounts.register(@valid_username, @valid_password)
    end

    test "invalid username registration" do
      assert {:error, %{errors: [username: _] }} = Accounts.register(@invalid_username, @valid_password)
    end

    test "invalid password registration" do
      assert {:error, %{errors: [password: _]}} = Accounts.register(@valid_username, @invalid_password)
    end
  end

  describe "login/2" do
    setup do
      {:ok, user} = Accounts.register(@valid_username, @valid_password)
      {:ok, user: user}
    end

    test "successful login" do
      assert {:ok, _session_token} = Accounts.login(@valid_username, @valid_password)
    end

    test "password not matched login" do
      assert {:error, "Invalid login credentials"} = Accounts.login(@valid_username, @invalid_password)
    end

    test "account does not exist login" do
      assert {:error, "Invalid login credentials"} = Accounts.login(@invalid_username, @invalid_password)
    end
  end
end
