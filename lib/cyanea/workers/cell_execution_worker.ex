defmodule Cyanea.Workers.CellExecutionWorker do
  @moduledoc """
  Oban worker for server-side notebook cell execution.

  Executes Elixir code cells via `Sandbox.eval/2`, persists results to
  `notebook_execution_results`, and broadcasts via PubSub.
  """
  use Oban.Worker,
    queue: :analysis,
    max_attempts: 1

  alias Cyanea.Notebooks
  alias Cyanea.Notebooks.Sandbox

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: %{
          "notebook_id" => notebook_id,
          "cell_id" => cell_id,
          "source" => source,
          "language" => language,
          "user_id" => user_id
        }
      }) do
    {status, output} = execute(language, source)

    Notebooks.upsert_execution_result(%{
      notebook_id: notebook_id,
      cell_id: cell_id,
      status: status,
      output: output,
      user_id: user_id
    })

    Phoenix.PubSub.broadcast(
      Cyanea.PubSub,
      "notebook:#{notebook_id}",
      {:cell_result, %{cell_id: cell_id, output: output, status: status}}
    )

    :ok
  end

  defp execute("elixir", source) do
    start = System.monotonic_time(:millisecond)

    case Sandbox.eval(source) do
      {:ok, result, _bindings} ->
        elapsed = System.monotonic_time(:millisecond) - start

        output = %{
          "type" => "text",
          "data" => inspect(result, pretty: true, limit: 500),
          "timing_ms" => elapsed
        }

        {"completed", output}

      {:error, message} ->
        elapsed = System.monotonic_time(:millisecond) - start

        output = %{
          "type" => "error",
          "data" => message,
          "timing_ms" => elapsed
        }

        {"error", output}
    end
  end

  defp execute(language, _source) do
    output = %{
      "type" => "error",
      "data" => "#{String.capitalize(language)} execution is coming soon.",
      "timing_ms" => 0
    }

    {"error", output}
  end
end
