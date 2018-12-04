defmodule WalletApp.WalletsTest do
  use ExUnit.Case

  alias WalletApp.{Accounts, Wallets}
  alias Accounts.User
  alias Wallets.Wallet

  @valid_currency "PHP"
  @invalid_currency "PH"
  @invalid_user %User{id: 99999}
  @invalid_wallet_uuid "XXXX"

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(WalletApp.Repo)
    {:ok, user} = Accounts.register("testuser", "password")
    %{user: user}
  end

  describe "create_wallet/2" do
    test "successful create wallet", %{user: user} do
      assert {:ok, wallet} = Wallets.create_wallet(user, @valid_currency)
      assert wallet = %Wallet{}
    end

    test "invalid currency", %{user: user} do
      assert {:error, %{errors: [currency: _]}} = Wallets.create_wallet(user, @invalid_currency)
    end

    test "invalid user" do
      assert_raise Sqlite.DbConnection.Error, "NOT NULL constraint failed: wallets.user_id", fn ->
        Wallets.create_wallet(%User{}, @valid_currency)
      end
    end
  end

  describe "get_user_wallets/1" do
    setup %{user: user} = context do
      {:ok, wallet} = Wallets.create_wallet(user, @valid_currency)

      Map.put(context, :wallet, wallet)
    end

    test "successful get wallets", %{user: user, wallet: wallet} do
      wallets = Wallets.get_user_wallets(user)
      assert length(wallets) == 1

      [uuid, currency, balance, inserted_at] = List.first(wallets)
      assert uuid == wallet.uuid
      assert currency == wallet.currency
      assert balance == 0
      assert inserted_at == wallet.inserted_at
    end

    test "invalid user" do
      wallets = Wallets.get_user_wallets(@invalid_user)
      assert length(wallets) == 0
    end
  end

  describe "get_user_wallet/2" do
    setup %{user: user} = context do
      {:ok, wallet} = Wallets.create_wallet(user, @valid_currency)

      Map.put(context, :wallet, wallet)
    end

    test "successful get wallet", %{user: user, wallet: wallet} do
      wallets = Wallets.get_user_wallet(user, wallet.uuid)
      assert length(wallets) == 1
    end

    test "invalid wallet_uuid", %{user: user} do
      wallets = Wallets.get_user_wallet(user, @invalid_wallet_uuid)
      assert length(wallets) == 0
    end

    test "invalid user", %{wallet: wallet} do
      wallets = Wallets.get_user_wallet(@invalid_user, wallet.uuid)
      assert length(wallets) == 0
    end
  end
end
