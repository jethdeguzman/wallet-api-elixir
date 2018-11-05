defmodule WalletApp.Wallet do
  import WalletApp.Util, only: [get_current_account: 1, get_account_wallets: 2, get_wallet_transactions: 2]

  alias WalletApp.Repo
  alias WalletApp.Schema.Account
  alias WalletApp.Schema.Wallet

  def create_wallet(session_token, currency \\ "PHP") do
    %Account{id: account_id} = get_current_account(session_token)
    %Wallet{}
      |> Wallet.changeset(%{account_id: account_id, currency: currency})
      |> Repo.insert
      |> create_wallet_response
  end

  defp create_wallet_response({:error, _}), do: raise "Validation error"
  defp create_wallet_response({:ok, %Wallet{uuid: uuid}}), do: uuid

  def get_wallets(session_token) do
    with(
      %Account{id: account_id} <- get_current_account(session_token),
      wallets <- get_account_wallets(account_id, nil)
    ) do
      wallets
    else
      _ -> raise "Error fetching wallets for account #{:account_id}"
    end
  end

  def get_wallet(session_token, wallet_uuid) do
    with(
      %Account{id: account_id} <- get_current_account(session_token),
      wallets <- get_account_wallets(account_id, wallet_uuid)
    ) do
      if length(wallets) > 0, do: Enum.at(wallets, 0), else: raise "Wallet #{wallet_uuid} not found"
    else
      _ -> raise "Error fetching wallet #{:wallet_id}"
    end
  end

  def get_transactions(session_token, wallet_uuid) do
    with(
      %Account{id: account_id} <- get_current_account(session_token),
      transactions <- get_wallet_transactions(account_id, wallet_uuid)
    ) do
      transactions
    else
      _ -> raise "Error fetching transactions for wallet #{:wallet_uuid}"
    end
  end
end
