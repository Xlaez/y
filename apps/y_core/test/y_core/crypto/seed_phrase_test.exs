defmodule YCore.Crypto.SeedPhraseTest do
  use ExUnit.Case, async: true
  alias YCore.Crypto.SeedPhrase

  describe "generate/0" do
    test "returns exactly 12 strings" do
      words = SeedPhrase.generate()
      assert is_list(words)
      assert length(words) == 12
      assert Enum.all?(words, &is_binary/1)
    end

    test "returns only words from BIP39 wordlist" do
      wordlist_path = Application.app_dir(:y_core, "priv/bip39_english.txt")
      wordlist = File.read!(wordlist_path) |> String.split("\n", trim: true)
      
      words = SeedPhrase.generate()
      assert Enum.all?(words, fn word -> word in wordlist end)
    end

    test "returns unique words" do
      words = SeedPhrase.generate()
      assert length(Enum.uniq(words)) == 12
    end
  end

  describe "to_phrase/1" do
    test "joins words with spaces" do
      words = ["abandon", "ability", "able", "about", "above", "absent", "absorb", "abstract", "absurd", "abuse", "access", "accident"]
      expected = "abandon ability able about above absent absorb abstract absurd abuse access accident"
      assert SeedPhrase.to_phrase(words) == expected
    end
  end

  describe "valid?/1" do
    test "returns true for valid 12-word phrase" do
      phrase = "abandon ability able about above absent absorb abstract absurd abuse access accident"
      assert SeedPhrase.valid?(phrase)
    end

    test "returns true for valid 12-word list" do
      words = ["abandon", "ability", "able", "about", "above", "absent", "absorb", "abstract", "absurd", "abuse", "access", "accident"]
      assert SeedPhrase.valid?(words)
    end

    test "returns false for 11 words" do
      phrase = "abandon ability able about above absent absorb abstract absurd abuse access"
      refute SeedPhrase.valid?(phrase)
    end

    test "returns false for words not in wordlist" do
      phrase = "abandon ability able about above absent absorb abstract absurd abuse access invalidword"
      refute SeedPhrase.valid?(phrase)
    end

    test "is case-insensitive" do
      phrase = "Abandon ABILITY able about above absent absorb abstract absurd abuse access accident"
      assert SeedPhrase.valid?(phrase)
    end
  end
end
