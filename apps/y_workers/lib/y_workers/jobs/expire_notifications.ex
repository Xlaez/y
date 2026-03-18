defmodule YWorkers.Jobs.ExpireNotifications do
  use Oban.Worker, queue: :default, max_attempts: 3

  @impl Oban.Worker
  def perform(_job) do
    YRepo.Repositories.NotificationRepository.delete_expired()
    :ok
  end
end
