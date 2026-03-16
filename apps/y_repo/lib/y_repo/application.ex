defmodule YRepo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    redis_config = Application.get_env(:y_repo, :redis)
    redis_url = redis_config[:url] || "redis://localhost:6379/0"

    children = [
      YRepo.Repo,
      {Redix, {redis_url, [name: :redix]}}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: YRepo.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
