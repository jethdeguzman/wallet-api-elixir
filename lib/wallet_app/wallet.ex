defmodule WalletApp.Wallet do
  alias WalletApp.Exception.{ValidationError, NotFound, GetWalletsError, GetTransactionsError}
  alias WalletApp.Repo
  alias WalletApp.Schema.Account
  alias WalletApp.Schema.Wallet
  alias WalletApp.Util

  def create_wallet(session_token, currency \\ "PHP") do
    %Account{id: account_id} = Util.get_current_account(session_token)
    %Wallet{}
      |> Wallet.changeset(%{account_id: account_id, currency: currency})
      |> Repo.insert
      |> create_wallet_response
  end

  defp create_wallet_response({:error, _}), do: raise ValidationError
  defp create_wallet_response({:ok, %Wallet{uuid: uuid}}), do: uuid

  def get_wallets(session_token) do
    with(
      %Account{id: account_id} <- Util.get_current_account(session_token),
      wallets <- Util.get_account_wallets(account_id)
    ) do
      wallets
    else
      _ -> raise GetWalletsError
    end
  end

  def get_wallet(session_token, wallet_uuid) do
    with(
      %Account{id: account_id} <- Util.get_current_account(session_token),
      wallets <- Util.get_account_wallets(account_id, wallet_uuid)
    ) do
      if length(wallets) > 0, do: Enum.at(wallets, 0), else: raise NotFound, wallet_uuid
    else
      _ -> raise NotFound, wallet_uuid
    end
  end

  def get_transactions(session_token, wallet_uuid) do
    with(
      %Account{id: account_id} <- Util.get_current_account(session_token),
      transactions <- Util.get_wallet_transactions(account_id, wallet_uuid)
    ) do
      transactions
    else
      _ -> raise GetTransactionsError
    end
  end
end
