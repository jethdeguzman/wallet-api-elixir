defmodule WalletApp.AccountsTest do
  use ExUnit.Case

  alias WalletApp.Accounts
  alias Accounts.User

  @valid_username "testuser"
  @valid_password "password"
  @invalid_username "!@#$%^"
  @invalid_password "pass"

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(WalletApp.Repo)
  end

  describe "register/2" do
    test "successful user registration" do
      assert {:ok, user} = Accounts.register(@valid_username, @valid_password)
      assert user = %User{}
    end

    test "invalid username on registration" do
      assert {:error, %{errors: [username: _] }} = Accounts.register(@invalid_username, @valid_password)
    end

    test "invalid password on registration" do
      assert {:error, %{errors: [password: _]}} = Accounts.register(@valid_username, @invalid_password)
    end
  end

  describe "login/2" do
    setup do
      {:ok, user} = Accounts.register(@valid_username, @valid_password)
      %{user: user}
    end

    test "successful login", %{user: user} do
      assert {:ok, session_token} = Accounts.login(@valid_username, @valid_password)

      {:ok, current_user} = Accounts.get_user_by(%{session_token: session_token})
      assert current_user == user
    end

    test "password not matched on login" do
      assert {:error, "Invalid login credentials"} = Accounts.login(@valid_username, @invalid_password)
    end

    test "account does not exist on login" do
      assert {:error, "Invalid login credentials"} = Accounts.login(@invalid_username, @invalid_password)
    end
  end
end
