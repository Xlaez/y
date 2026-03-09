defmodule YRepo.Repo do
  use Ecto.Repo,
    otp_app: :y_repo,
    adapter: Ecto.Adapters.Postgres
end
