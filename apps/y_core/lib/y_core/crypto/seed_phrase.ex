defmodule YCore.Crypto.SeedPhrase do
  @moduledoc """
  Logic for generation and validation of 12-word BIP39 seed phrases.
  """

  @wordlist_path Application.app_dir(:y_core, "priv/bip39_english.txt")

  @wordlist File.read!(@wordlist_path)
            |> String.split("\n", trim: true)

  @doc """
  Returns 12 unique words randomly sampled from the BIP39 wordlist.
  Uses :crypto.strong_rand_bytes for randomness.
  """
  def generate() do
    indices = get_random_indices(12, length(@wordlist), MapSet.new())
    Enum.map(indices, &Enum.at(@wordlist, &1))
  end

  defp get_random_indices(0, _limit, acc), do: acc |> MapSet.to_list()

  defp get_random_indices(count, limit, acc) do
    # 2048 words, so we need 11 bits. 2 bytes is enough.
    <<random_val::16>> = :crypto.strong_rand_bytes(2)
    index = rem(random_val, limit)

    if MapSet.member?(acc, index) do
      get_random_indices(count, limit, acc)
    else
      get_random_indices(count - 1, limit, MapSet.put(acc, index))
    end
  end

  @doc """
  Joins the list with single spaces → the canonical phrase string.
  """
  def to_phrase(words) when is_list(words) do
    Enum.join(words, " ")
  end

  @doc """
  Validates exactly 12 words, all words present in the BIP39 wordlist.
  Normalises to lowercase before checking.
  """
  def valid?(phrase) when is_binary(phrase) do
    phrase
    |> String.split(" ", trim: true)
    |> valid?()
  end

  def valid?(words) when is_list(words) do
    length(words) == 12 && Enum.all?(words, &Enum.member?(@wordlist, String.downcase(&1)))
  end

  def valid?(_), do: false
end
