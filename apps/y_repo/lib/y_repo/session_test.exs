defmodule YRepo.SessionTest do
  def run do
    user_id = "user-123"
    {:ok, token} = YRepo.Session.create_session(user_id)
    IO.puts("Created session for #{user_id}, token: #{token}")
    
    {:ok, retrieved_id} = YRepo.Session.get_user_id(token)
    IO.puts("Retrieved user_id: #{retrieved_id}")
    
    if user_id == retrieved_id do
      IO.puts("SUCCESS: Session verified")
    else
      IO.puts("FAILURE: user_id mismatch")
    end
    
    YRepo.Session.delete_session(token)
    IO.puts("Deleted session")
    
    case YRepo.Session.get_user_id(token) do
      {:error, :not_found} -> IO.puts("SUCCESS: Session deleted correctly")
      _ -> IO.puts("FAILURE: Session still exists")
    end
  end
end

YRepo.SessionTest.run()
