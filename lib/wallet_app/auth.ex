defmodule WalletApp.Auth do
  import Application

  @one_hour 60 * 60
  @jwt_opts %{alg: get_env(:wallet_app, :jwt_alg), key: get_env(:wallet_app, :jwt_key)}

  def password_matched?(hashed_password, password) do
    Bcrypt.verify_pass(password, hashed_password)
  end

  def generate_session_token(%{account_uuid: account_uuid}) do
    %{account_uuid: account_uuid, exp: DateTime.to_unix(DateTime.utc_now()) + @one_hour}
    |> JsonWebToken.sign(@jwt_opts)
    |> (&{:ok, &1}).()
  end

  def decode_session_token(session_token) do
    JsonWebToken.verify(session_token, @jwt_opts)
  end
end
