defmodule YCore.Accounts.ValueObjects.Username do
  @moduledoc """
  Value object for Usernames.
  Ensures consistent validation and normalization across the system.
  """

  defstruct [:value]

  @type t :: %__MODULE__{value: String.t()}

  @spec new(String.t()) :: {:ok, t()} | {:error, String.t()}
  def new(value) when is_binary(value) do
    value = String.downcase(value)

    cond do
      not valid_length?(value) ->
        {:error, "Username must be between 3 and 30 characters"}

      not valid_format?(value) ->
        {:error, "Username can only contain alphanumeric characters and underscores"}

      starts_with_underscore?(value) ->
        {:error, "Username cannot start with an underscore"}

      true ->
        {:ok, %__MODULE__{value: value}}
    end
  end

  def new(_), do: {:error, "Invalid input type"}

  defp valid_length?(value) do
    len = String.length(value)
    len >= 3 and len <= 30
  end

  defp valid_format?(value) do
    String.match?(value, ~r/^[a-z0-9_]+$/)
  end

  defp starts_with_underscore?(value) do
    String.starts_with?(value, "_")
  end
end
