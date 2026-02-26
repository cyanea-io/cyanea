defmodule Cyanea.Workers.EmailWorker do
  @moduledoc """
  Oban worker for delivering emails asynchronously.

  Accepts a serialized Swoosh.Email struct and delivers it via the configured
  mailer adapter. Retries up to 3 times on failure.
  """
  use Oban.Worker, queue: :default, max_attempts: 3

  require Logger

  alias Cyanea.Mailer

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"to" => to, "subject" => subject, "text_body" => text_body} = args}) do
    {from_name, from_address} = Application.get_env(:cyanea, :mailer_from, {"Cyanea", "noreply@cyanea.dev"})

    email =
      Swoosh.Email.new()
      |> Swoosh.Email.from({args["from_name"] || from_name, args["from_address"] || from_address})
      |> Swoosh.Email.to(to)
      |> Swoosh.Email.subject(subject)
      |> Swoosh.Email.text_body(text_body)

    case Mailer.deliver(email) do
      {:ok, _metadata} ->
        Logger.info("Email delivered to #{to}: #{subject}")
        :ok

      {:error, reason} ->
        Logger.warning("Email delivery failed to #{to}: #{inspect(reason)}")
        {:error, reason}
    end
  end

  @doc """
  Enqueues a Swoosh.Email for async delivery via Oban.
  """
  def enqueue(%Swoosh.Email{} = email) do
    %{to: [{_name, to_address} | _]} = email
    {from_name, from_address} = email.from

    %{
      "to" => to_address,
      "subject" => email.subject,
      "text_body" => email.text_body,
      "from_name" => from_name,
      "from_address" => from_address
    }
    |> __MODULE__.new()
    |> Oban.insert()
  end
end
