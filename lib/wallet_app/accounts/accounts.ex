defmodule WalletApp.Accounts do
  import Application

  alias WalletApp.Repo
  alias WalletApp.Accounts.User

  @one_hour 60 * 60
  @jwt_opts %{alg: get_env(:wallet_app, :jwt_alg), key: get_env(:wallet_app, :jwt_key)}

  def register(username, password) do
    %User{}
    |> User.changeset(%{username: username, password: password})
    |> Repo.insert()
  end

  def login(username, password) do
    with(
      {:ok, %{uuid: uuid, password: hashed_password}} <- get_user_by(%{username: username}),
      true <- Bcrypt.verify_pass(password, hashed_password)
    ) do
      generate_session_token(%{user_uuid: uuid})
    else
      _ -> {:error, "Invalid login credentials"}
    end
  end

  def get_user_by(%{username: username}) do
    case Repo.get_by(User, username: username) do
      %User{} = user -> {:ok, user}
      nil -> {:error, :not_found}
    end
  end

  defp generate_session_token(%{user_uuid: user_uuid}) do
    %{user_uuid: user_uuid, exp: DateTime.to_unix(DateTime.utc_now()) + @one_hour}
    |> JsonWebToken.sign(@jwt_opts)
    |> (&{:ok, &1}).()
  end

end
