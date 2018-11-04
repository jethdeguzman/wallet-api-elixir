defmodule WalletApp.Util do
  alias WalletApp.Repo
  alias WalletApp.Schema.Account

  import Application, only: [get_env: 2]

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
      _ -> raise "Invalid session token"
    end
  end

  def get_account_wallets(account_id) do
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
      where
        w.account_id = $1
      order by 
        w.inserted_at desc
    """
    Ecto.Adapters.SQL.query!(Repo, query, [account_id])
  end
end
