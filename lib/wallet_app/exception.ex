defmodule WalletApp.Exception.InvalidLoginCredentialsError do
  defexception message: "Invalid login credentials"
end

defmodule WalletApp.Exception.ValidationError do
  defexception message: "Validation error"
end

defmodule WalletApp.Exception.InvalidSessionToken do
  defexception [:message]

  @impl true
  def exception(session_token) do
    msg = "Invalid session token: #{session_token}"
    %WalletApp.Exception.InvalidSessionToken{message: msg}
  end
end


defmodule WalletApp.Exception.NotFound do
  defexception [:message]

  @impl true
  def exception(uuid) do
    msg = "Record not found: #{uuid}"
    %WalletApp.Exception.NotFound{message: msg}
  end
end

defmodule WalletApp.Exception.GetWalletsError do
  defexception message: "Error fetching wallets"
end

defmodule WalletApp.Exception.GetTransactionsError do
  defexception message: "Error fetching transactions"
end
