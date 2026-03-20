defmodule YCore.Accounts.UserRepository do
  @moduledoc """
  Core behaviour for User persistence. 
  Follows the repository pattern to decouple domain logic from Ecto and Postgres.
  """

  alias YCore.Accounts.User

  @callback get_by_id(String.t()) :: {:ok, User.t()} | {:error, :not_found}
  @callback get_by_id!(String.t()) :: User.t()
  @callback get_by_username(String.t()) :: {:ok, User.t()} | {:error, :not_found}
  @callback create(map()) :: {:ok, User.t()} | {:error, term()}
  @callback update(User.t(), map()) :: {:ok, User.t()} | {:error, term()}
  @callback delete(String.t()) :: :ok | {:error, term()}
  @callback list_by_ids([String.t()]) :: [User.t()]
  @callback search(String.t(), keyword()) :: [User.t()]
end
