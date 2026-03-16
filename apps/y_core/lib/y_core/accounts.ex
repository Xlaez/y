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

