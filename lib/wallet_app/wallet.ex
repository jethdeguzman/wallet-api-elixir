defmodule WalletApp.Wallet do
  import WalletApp.Util, only: [get_current_account: 1, get_account_wallets: 1]
  
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
      %{rows: wallets} <- get_account_wallets(account_id)
    ) do
      Enum.map wallets, fn [uuid, currency, balance, inserted_at] ->
        %{
          uuid: uuid,
          currency: currency,
          balance: balance,
          inserted_at: inserted_at
        }
      end
    else
      _ -> raise "Error fetching wallets for #{:account_id}"
    end
  end
end
