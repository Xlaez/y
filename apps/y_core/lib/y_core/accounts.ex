defmodule YCore.Accounts.Username do
  @moduledoc """
  Value Object for Username: validates 3–30 chars, alphanumeric + underscores only.
  """
  defstruct [:value]

  @type t :: %__MODULE__{value: String.t()}

  def new(value) when is_binary(value) do
    trimmed = String.trim(value)
    if valid?(trimmed) do
      {:ok, %__MODULE__{value: trimmed}}
    else
      {:error, :invalid_username}
    end
  end

  defp valid?(value) do
    String.length(value) in 3..30 and Regex.match?(~r/^[a-zA-Z0-9_]+$/, value)
  end
end

defmodule YCore.Accounts.SeedPhrase do
  @moduledoc """
  Value Object for SeedPhrase: wraps 12-word BIP39 phrase, validates word count.
  """
  defstruct [:hash]

  @type t :: %__MODULE__{hash: String.t()}

  def new(phrase) when is_binary(phrase) do
    words = phrase |> String.trim() |> String.split(~r/\s+/)
    if length(words) == 12 do
      # Hashing is handled at the domain service or repository boundary usually,
      # but here we store the hash as per requirements.
      # The raw phrase is discarded after hashing.
      {:ok, %__MODULE__{hash: hash_phrase(phrase)}}
    else
      {:error, :invalid_seed_phrase}
    end
  end

  defp hash_phrase(phrase) do
    Argon2.hash_pwd_salt(phrase, t_cost: 8, m_cost: 17)
  end
end

defmodule YCore.Accounts.User do
  defstruct [
    :id,
    :username,
    :password_hash,
    :seed_phrase_hash,
    :bitmoji_id,
    :is_locked,
    :inserted_at,
    :updated_at
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          username: String.t(),
          password_hash: String.t(),
          seed_phrase_hash: String.t(),
          bitmoji_id: String.t() | nil,
          is_locked: boolean(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }
end

defmodule YCore.Accounts.UserRepository do
  @callback get_by_id(id :: String.t()) :: {:ok, YCore.Accounts.User.t()} | {:error, :not_found}
  @callback get_by_username(username :: String.t()) :: {:ok, YCore.Accounts.User.t()} | {:error, :not_found}
  @callback create(params :: map()) :: {:ok, YCore.Accounts.User.t()} | {:error, any()}
  @callback update(user :: YCore.Accounts.User.t(), params :: map()) :: {:ok, YCore.Accounts.User.t()} | {:error, any()}
  @callback delete(user :: YCore.Accounts.User.t()) :: :ok | {:error, any()}
end
