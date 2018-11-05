defmodule WalletApp.Util do
  alias WalletApp.Exception.InvalidSessionToken
  alias WalletApp.Repo
  alias WalletApp.Schema.Account
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

  def get_account_wallets(account_id, wallet_uuid \\ nil) do
    #TODO: This should be refactored to handle other field filters
    {where_clause, params} =
      if is_nil(wallet_uuid) do
        {"where w.account_id = $1", [account_id]}
      else
        {"where w.account_id = $1 and w.uuid = $2", [account_id, wallet_uuid]}
      end

    query = """
      select
        w.uuid,
        w.currency,
        coalesce(t1.balance, 0.0000) as balance,
        w.inserted_at
      from
        wallets w
      left join (
        select
          t.wallet_id,
          t.balance
        from
          transactions t
        order by
          t.wallet_id,
          t.inserted_at desc
        limit 1
      ) t1 on t1.wallet_id = w.id
      #{where_clause}
      order by
        w.inserted_at desc
    """
    %{rows: wallets} = Ecto.Adapters.SQL.query!(Repo, query, params)
    Enum.map wallets, fn [uuid, currency, balance, inserted_at] ->
      %{
        uuid: uuid,
        currency: currency,
        balance: balance,
        inserted_at: inserted_at
      }
    end
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

    Enum.map query |> Repo.all, fn [uuid, type, description, amount, currency, inserted_at] ->
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
