defmodule YRepo.DebugSchema do
  alias YRepo.Repo

  def run do
    # Fetch column types for 'users' table from information_schema
    query = """
    SELECT column_name, data_type, udt_name
    FROM information_schema.columns
    WHERE table_name = 'users'
    """
    case Repo.query(query) do
      {:ok, %{rows: rows}} ->
        Enum.each(rows, fn [name, type, udt] ->
          IO.puts("#{name}: #{type} (#{udt})")
        end)
      error ->
        IO.inspect(error)
    end
  end
end
