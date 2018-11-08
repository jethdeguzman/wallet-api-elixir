defmodule WalletAppTest do
  use ExUnit.Case

  alias WalletApp.Exception

  @password "password"
  @currency "PHP"

  test "successful account registration" do
    assert WalletApp.register(unique_string(), @password)
  end

  test "invalid username registration" do
    username = "!@#$%^"

    assert_raise Exception.ValidationError, "Validation error", fn ->
      WalletApp.register(username, @password)
    end
  end

  test "invalid password registration" do
    password = "pass"

    assert_raise Exception.ValidationError, "Validation error", fn ->
      WalletApp.register(unique_string(), password)
    end
  end

  test "duplicate username registration" do
    username = unique_string()

    WalletApp.register(username, @password)

    assert_raise Exception.ValidationError, "Validation error", fn ->
      WalletApp.register(username, @password)
    end
  end

  test "successful login" do
    username = unique_string()

    WalletApp.register(username, @password)

    assert WalletApp.login(username, @password)
  end

  test "account does not exist on login" do
    username = "does_not_exist"

    assert_raise Exception.InvalidLoginCredentialsError, "Invalid login credentials", fn ->
      WalletApp.login(username, @password)
    end
  end

  test "password not matched on login" do
    username = unique_string()
    password = "invalid_password"

    WalletApp.register(username, @password)

    assert_raise Exception.InvalidLoginCredentialsError, "Invalid login credentials", fn ->
      WalletApp.login(username, password)
    end
  end

  test "succesful create wallet" do
    username = unique_string()

    WalletApp.register(username, @password)

    session_token = WalletApp.login(username, @password)

    assert WalletApp.create_wallet(session_token, @currency)
  end

  test "invalid session token on create wallet" do
    session_token = "invalid_token"

    assert_raise Exception.InvalidSessionToken, "Invalid session token: invalid_token", fn ->
      WalletApp.create_wallet(session_token, @currency)
    end
  end

  test "invalid currency on create wallet" do
    currency = "BT"
    username = unique_string()

    WalletApp.register(username, @password)

    session_token = WalletApp.login(username, @password)

    assert_raise Exception.ValidationError, "Validation error", fn ->
      WalletApp.create_wallet(session_token, currency)
    end
  end

  test "successful get wallets" do
    username = unique_string()

    WalletApp.register(username, @password)

    session_token = WalletApp.login(username, @password)
    wallet_uuid = WalletApp.create_wallet(session_token, @currency)

    assert [%{currency: @currency, uuid: wallet_uuid}] = WalletApp.get_wallets(session_token)
  end

  test "invalid session token on get wallets" do
    session_token = "invalid_token"

    assert_raise Exception.InvalidSessionToken, "Invalid session token: invalid_token", fn ->
      WalletApp.get_wallets(session_token)
    end
  end

  test "successful get wallet" do
    username = unique_string()

    WalletApp.register(username, @password)

    session_token =WalletApp.login(username, @password)
    wallet_uuid = WalletApp.create_wallet(session_token, @currency)

    assert %{currency: @currency, uuid: wallet_uuid} = WalletApp.get_wallet(session_token, wallet_uuid)
  end

  test "not found on get wallet" do
    username = unique_string()
    wallet_uuid = "invalid_uuid"

    WalletApp.register(username, @password)

    session_token =WalletApp.login(username, @password)

    assert_raise Exception.NotFound, "Record not found: invalid_uuid", fn ->
      WalletApp.get_wallet(session_token, wallet_uuid)
    end
  end

  test "get transactions successful" do
    username = unique_string()

    WalletApp.register(username, @password)

    session_token =WalletApp.login(username, @password)
    wallet_uuid = WalletApp.create_wallet(session_token, @currency)

    assert [] = WalletApp.get_transactions(session_token, wallet_uuid)
  end

  defp unique_string, do: Ecto.UUID.generate()
end
