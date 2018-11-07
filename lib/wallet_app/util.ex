defmodule WalletApp.Util do
  alias WalletApp.Exception.InvalidSessionToken
  alias WalletApp.Repo
  alias WalletApp.Schema.Account
  alias WalletApp.Schema.Wallet
  alias WalletApp.Schema.Transaction

  import Application, only: [get_env: 2]
  import Ecto.Query, only: [from: 2]

  @one_hour 60*60
  @jwt_opts %{alg: get_env(:wallet_app, :jwt_alg), key: get_env(:wallet_app, :jwt_key)}

  def generate_session_token(account_uuid) do
    %{account_uuid: account_uuid, exp: DateTime.to_unix(DateTime.utc_now()) + @one_hour}
      |> JsonWebToken.sign(@jwt_opts)
      |> (&({:ok, &1})).()
  end

  def get_current_account(session_token) do
    try do
      #TODO: validate expiration
      {:ok, %{account_uuid: account_uuid}} = JsonWebToken.verify(session_token, @jwt_opts)
      Repo.get_by(Account, uuid: account_uuid)
    rescue
      _ -> raise InvalidSessionToken, session_token
    end
  end

  def get_account_wallets(account_id) do
    get_wallets_query(account_id)
      |> Repo.all
      |> get_account_wallets_response
  end

  def get_account_wallets(account_id, wallet_uuid) do
    query = from w in get_wallets_query(account_id), where: w.uuid == ^wallet_uuid
    query
      |> Repo.all
      |> get_account_wallets_response
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

  defp get_account_wallets_response(wallets) do
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

  def get_wallet_transactions(account_id, wallet_uuid) do
    query =
      from t in Transaction,
      order_by: [desc: t.inserted_at],
      left_join: w in assoc(t, :wallet),
      left_join: a in assoc(w, :account),
      where: a.id == ^account_id,
      where: w.uuid == ^wallet_uuid,
      select: [t.uuid, t.type, t.description, t.amount, w.currency, t.inserted_at]

    Enum.map Repo.all(query), fn [uuid, type, description, amount, currency, inserted_at] ->
      %{
        uuid: uuid,
        type: type,
        description: description,
        amount: amount,
        currency: currency,
        inserted_at: inserted_at
      }
    end
  end
end
