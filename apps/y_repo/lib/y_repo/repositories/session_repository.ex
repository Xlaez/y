defmodule YRepo.Repositories.SessionRepository do
  @behaviour YCore.Accounts.SessionRepository

  alias YRepo.Session

  @impl true
  def delete_all_for_user(user_id) do
    Session.delete_all_for_user(user_id)
  end
end
