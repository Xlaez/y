defmodule Y.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {DNSCluster, query: Application.get_env(:y, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Y.PubSub}
      # Start a worker by calling: Y.Worker.start_link(arg)
      # {Y.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Y.Supervisor)
  end
end
