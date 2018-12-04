defmodule WalletApp.Wallets do
  import Ecto.Query

  alias WalletApp.Accounts.User
  alias WalletApp.Repo
  alias WalletApp.Wallets.{Wallet, Transaction}

  def create_wallet(%User{} = user, currency) do
    %Wallet{}
    |> Wallet.changeset(%{currency: currency})
    |> Ecto.Changeset.put_change(:user_id, user.id)
    |> Repo.insert()
  end

  def get_user_wallets(%User{} = user) do
    user.id
    |> get_wallets_query()
    |> Repo.all()
  end

  def get_user_wallet(%User{} = user, wallet_uuid) do
    query = from(w in get_wallets_query(user.id), where: w.uuid == ^wallet_uuid)
    Repo.all(query)
  end

  def get_user_wallet_transactions(%User{} = user, wallet_uuid) do
    query = from(
      t in Transaction,
      order_by: [desc: t.inserted_at],
      left_join: w in assoc(t, :wallet),
      left_join: u in assoc(w, :user),
      where: u.id == ^user.id,
      where: w.uuid == ^wallet_uuid,
      select: [t.uuid, t.type, t.description, t.amount, w.currency, t.inserted_at]
    )

    Repo.all(query)
  end

  defp get_wallets_query(user_id) do
    last_tx_query = from(
      t in Transaction,
      order_by: [desc: t.inserted_at],
      limit: 1,
      select: %{wallet_id: t.wallet_id, balance: t.balance}
    )

    from(
      w in Wallet,
      left_join: t2 in subquery(last_tx_query),
      on: t2.wallet_id == w.id,
      where: w.user_id == ^user_id,
      select: [
        w.uuid,
        w.currency,
        fragment("coalesce(?, 0.0) as balance", t2.balance),
        w.inserted_at
      ]
    )
  end
end
