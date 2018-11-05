defmodule WalletApp.Wallet do
  import WalletApp.Util, only: [get_current_account: 1, get_account_wallets: 2, get_wallet_transactions: 2]

  alias WalletApp.Exception.{ValidationError, NotFound, GetWalletsError, GetTransactionsError}
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

  defp create_wallet_response({:error, _}), do: raise ValidationError
  defp create_wallet_response({:ok, %Wallet{uuid: uuid}}), do: uuid

  def get_wallets(session_token) do
    with(
      %Account{id: account_id} <- get_current_account(session_token),
      wallets <- get_account_wallets(account_id, nil)
    ) do
      wallets
    else
      _ -> raise GetWalletsError
    end
  end

  def get_wallet(session_token, wallet_uuid) do
    with(
      %Account{id: account_id} <- get_current_account(session_token),
      wallets <- get_account_wallets(account_id, wallet_uuid)
    ) do
      if length(wallets) > 0, do: Enum.at(wallets, 0), else: raise NotFound, wallet_uuid
    else
      _ -> raise NotFound, wallet_uuid
    end
  end

  def get_transactions(session_token, wallet_uuid) do
    with(
      %Account{id: account_id} <- get_current_account(session_token),
      transactions <- get_wallet_transactions(account_id, wallet_uuid)
    ) do
      transactions
    else
      _ -> raise GetTransactionsError
    end
  end
end
