defmodule YCore.Accounts.PasswordResetService do
  @moduledoc """
  Service for resetting user passwords using their recovery seed phrase.
  """

  alias YCore.Accounts.User
  alias YCore.Accounts.ValueObjects.Password

  @spec reset(String.t(), String.t(), String.t(), module()) ::
          {:ok, User.t()} | {:error, :invalid_credentials}
  def reset(username, seed_phrase, new_password, repo) do
    case repo.get_by_username(username) do
      {:ok, user} ->
        if Argon2.verify_pass(seed_phrase, user.seed_phrase_hash) do
          with :ok <- Password.validate(new_password),
               new_password_hash <- Bcrypt.hash_pwd_salt(new_password, log_rounds: 12),
               {:ok, updated_user} <- repo.update(user, %{password_hash: new_password_hash}) do
            {:ok, updated_user}
          else
            error -> error
          end
        else
          {:error, :invalid_credentials}
        end

      {:error, :not_found} ->
        # Timing attack safety: run a dummy Argon2 verify
        Argon2.no_user_verify()
        {:error, :invalid_credentials}
    end
  end
end
