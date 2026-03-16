defmodule YCore.Accounts.SessionRepository do
  @moduledoc """
  Core behaviour for Session management.
  Decouples the domain logic from specific session store implementations (like Redis).
  """

  @callback delete_all_for_user(String.t()) :: :ok | {:error, term()}
end
