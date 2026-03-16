defmodule YCore.Accounts.AuthenticationService do
  @moduledoc """
  Service for authenticating users.
  Includes timing attack protection using dummy hashes.
  """

  alias YCore.Accounts.User

  @spec authenticate(String.t(), String.t(), module()) ::
          {:ok, User.t()} | {:error, :invalid_credentials}
  def authenticate(username, password, repo) do
    case repo.get_by_username(username) do
      {:ok, user} ->
        if Bcrypt.verify_pass(password, user.password_hash) do
          {:ok, user}
        else
          {:error, :invalid_credentials}
        end

      {:error, :not_found} ->
        # Timing attack safety: run a dummy bcrypt check
        Bcrypt.no_user_verify()
        {:error, :invalid_credentials}
    end
  end
end
