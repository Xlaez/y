defmodule YCore.Accounts.ValueObjects.Password do
  @moduledoc """
  Value object for Password validation.
  Only provides validation logic; does not store the plaintext password.
  """

  @spec validate(String.t()) :: :ok | {:error, String.t()}
  def validate(password) when is_binary(password) do
    if String.length(password) >= 10 do
      :ok
    else
      {:error, "Password must be at least 10 characters long"}
    end
  end

  def validate(_), do: {:error, "Invalid input type"}
end
