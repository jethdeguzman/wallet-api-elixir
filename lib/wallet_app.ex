defmodule WalletApp do
  alias WalletApp.Account
  alias WalletApp.Auth
  alias WalletApp.Exception
  alias WalletApp.Schema.Account, as: AccountSchema
  alias WalletApp.Schema.Wallet, as: WalletSchema
  alias WalletApp.Wallet

  def register(username, password) do
    account = Account.create_account(username, password)
    register_response(account)
  end

  def login(username, password) do
    with(
      %AccountSchema{uuid: account_uuid, password: hashed_password} <- Account.get_account_by(%{username: username}),
      true <- Auth.password_matched?(hashed_password, password),
      {:ok, session_token} <- Auth.generate_session_token(%{account_uuid: account_uuid})
    ) do
      session_token
    else
      _ -> raise Exception.InvalidLoginCredentialsError
    end
  end

  def create_wallet(session_token, currency) do
    with(
      %AccountSchema{id: account_id} = get_current_account(session_token)
    ) do
      wallet = Wallet.create_wallet(account_id, currency)
      create_wallet_response(wallet)
    end
  end

  def get_wallets(session_token) do
    with(
      %AccountSchema{id: account_id} <- get_current_account(session_token),
      wallets <- Wallet.get_wallets(account_id)
    ) do
      get_wallets_response(wallets)
    else
      _ -> raise Exception.GetWalletsError
    end
  end

  def get_wallet(session_token, wallet_uuid) do
    with(
      %AccountSchema{id: account_id} <- get_current_account(session_token),
      wallets <- Wallet.get_wallet(account_id, wallet_uuid)
    ) do
      if length(wallets) > 0,
        do: wallets |> Enum.at(0) |> get_wallet_response,
        else: raise Exception.NotFound, wallet_uuid
    else
      _ -> raise Exception.NotFound, wallet_uuid
    end
  end

  def get_transactions(session_token, wallet_uuid) do
    with(
      %AccountSchema{id: account_id} <- get_current_account(session_token),
      transactions <- Wallet.get_wallet_transactions(account_id, wallet_uuid)
    ) do
      get_transactions_response(transactions)
    else
      _ -> raise Exception.GetTransactionsError
    end
  end

  defp register_response({:error, _}), do: raise Exception.ValidationError
  defp register_response({:ok, %AccountSchema{uuid: uuid}}), do: uuid

  defp create_wallet_response({:error, _}), do: raise Exception.ValidationError
  defp create_wallet_response({:ok, %WalletSchema{uuid: uuid}}), do: uuid

  defp get_wallets_response(wallets) do
    wallets
      |> Enum.map(
        fn [uuid, currency, balance, inserted_at] ->
          %{
            uuid: uuid,
            currency: currency,
            balance: balance,
            inserted_at: inserted_at
          }
        end
      )
  end

  defp get_wallet_response([uuid, currency, balance, inserted_at]) do
    %{
      uuid: uuid,
      currency: currency,
      balance: balance,
      inserted_at: inserted_at
    }
  end

  defp get_transactions_response(transactions) do
    transactions
      |> Enum.map(
        fn [uuid, type, description, amount, currency, inserted_at] ->
          %{
            uuid: uuid,
            type: type,
            description: description,
            amount: amount,
            currency: currency,
            inserted_at: inserted_at
          }
        end
      )
  end

  defp get_current_account(session_token) do
    try do
      #TODO: validate expiration
      {:ok, %{account_uuid: account_uuid}} = Auth.decode_session_token(session_token)
      Account.get_account_by(%{uuid: account_uuid})
    rescue
      _ -> raise Exception.InvalidSessionToken, session_token
    end
  end
end
