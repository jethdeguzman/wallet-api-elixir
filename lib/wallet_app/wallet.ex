defmodule WalletApp.Wallet do
  alias WalletApp.Repo
  alias WalletApp.Schema.Wallet
  alias WalletApp.Schema.Transaction

  import Ecto.Query

  def create_wallet(account_id, currency \\ "PHP") do
    %Wallet{}
      |> Wallet.changeset(%{account_id: account_id, currency: currency})
      |> Repo.insert
  end

  def get_wallets(account_id) do
    account_id
      |> get_wallets_query
      |> Repo.all
  end

  def get_wallet(account_id, wallet_uuid) do
    query = from(w in get_wallets_query(account_id), where: w.uuid == ^wallet_uuid)
    Repo.all(query)
  end

  def get_wallet_transactions(account_id, wallet_uuid) do
    query =
      from t in Transaction,
      order_by: [desc: t.inserted_at],
      left_join: w in assoc(t, :wallet),
      left_join: a in assoc(w, :account),
      where: a.id == ^account_id,
      where: w.uuid == ^wallet_uuid,
      select: [t.uuid, t.type, t.description, t.amount, w.currency, t.inserted_at]

    Repo.all(query)
  end

  defp get_wallets_query(account_id) do
    last_tx_query =
      from t in Transaction,
      order_by: [desc: t.inserted_at],
      limit: 1,
      select: %{wallet_id: t.wallet_id, balance: t.balance}

    from w in Wallet,
      left_join: t2 in subquery(last_tx_query),
      on: t2.wallet_id == w.id,
      where: w.account_id == ^account_id,
      select: [w.uuid, w.currency, fragment("coalesce(?, 0.0) as balance", t2.balance), w.inserted_at]
  end
end
