defmodule YWorkers.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Oban, Application.fetch_env!(:y_workers, Oban)}
    ]

    opts = [strategy: :one_for_one, name: YWorkers.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
