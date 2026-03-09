defmodule YWorkers.Workers.NotificationWorker do
  @moduledoc """
  Worker for processing and delivering notifications.
  """
  use Oban.Worker, queue: :notifications

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"notification_id" => _id}}) do
    # Here we would load the notification and perform delivery logic
    # (e.g., push notification, email, or updating local state)
    :ok
  end
end
