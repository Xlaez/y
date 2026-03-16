defmodule YCore.Accounts.RegistrationService do
  @moduledoc """
  Service for registering new users.
  Ensures zero-PII storage and secure hashing of passwords and seed phrases.
  """

  alias YCore.Accounts.User
  alias YCore.Accounts.ValueObjects.Username
  alias YCore.Accounts.ValueObjects.Password
  alias YCore.Crypto.SeedPhrase

  @bitmoji_pool [
    "f47ac10b-58cc-4372-a567-0e02b2c3d471",
    "f47ac10b-58cc-4372-a567-0e02b2c3d472",
    "f47ac10b-58cc-4372-a567-0e02b2c3d473",
    "f47ac10b-58cc-4372-a567-0e02b2c3d474",
    "f47ac10b-58cc-4372-a567-0e02b2c3d475",
    "f47ac10b-58cc-4372-a567-0e02b2c3d476",
    "f47ac10b-58cc-4372-a567-0e02b2c3d477",
    "f47ac10b-58cc-4372-a567-0e02b2c3d478",
    "f47ac10b-58cc-4372-a567-0e02b2c3d479",
    "f47ac10b-58cc-4372-a567-0e02b2c3d480",
    "f47ac10b-58cc-4372-a567-0e02b2c3d481",
    "f47ac10b-58cc-4372-a567-0e02b2c3d482",
    "f47ac10b-58cc-4372-a567-0e02b2c3d483",
    "f47ac10b-58cc-4372-a567-0e02b2c3d484",
    "f47ac10b-58cc-4372-a567-0e02b2c3d485",
    "f47ac10b-58cc-4372-a567-0e02b2c3d486",
    "f47ac10b-58cc-4372-a567-0e02b2c3d487",
    "f47ac10b-58cc-4372-a567-0e02b2c3d488",
    "f47ac10b-58cc-4372-a567-0e02b2c3d489",
    "f47ac10b-58cc-4372-a567-0e02b2c3d490"
  ]

  @spec register(map(), module()) ::
          {:ok, %{user: User.t(), seed_phrase: [String.t()]}} | {:error, term()}
  def register(%{username: username_raw, password: password_raw}, repo) do
    with {:ok, username} <- Username.new(username_raw),
         :ok <- Password.validate(password_raw),
         {:error, :not_found} <- repo.get_by_username(username.value),
         password_hash <- Bcrypt.hash_pwd_salt(password_raw, log_rounds: 12),
         seed_words <- SeedPhrase.generate(),
         seed_phrase_str <- SeedPhrase.to_phrase(seed_words),
         # Argon2id with specific t_cost and m_cost as requested
         seed_phrase_hash <- Argon2.hash_pwd_salt(seed_phrase_str, t_cost: 8, m_cost: 17),
         bitmoji_id <- Enum.random(@bitmoji_pool),
         {:ok, user} <- repo.create(%{
           username: username.value,
           password_hash: password_hash,
           seed_phrase_hash: seed_phrase_hash,
           bitmoji_id: bitmoji_id
         }) do
      {:ok, %{user: user, seed_phrase: seed_words}}
    else
      {:ok, _user} -> {:error, :username_taken}
      error -> error
    end
  end
end
