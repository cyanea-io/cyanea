defmodule Cyanea.Notebooks.Sandbox do
  @moduledoc """
  Sandboxed Elixir code evaluator for notebook cells.

  Validates code via AST inspection to block dangerous operations
  (file I/O, system calls, process manipulation), then evaluates
  with a 30-second timeout.
  """

  @blocked_module_names MapSet.new(~w(
    System File IO Port Node Process Code Module
    Application DynamicSupervisor GenServer Agent
  ))

  @blocked_erlang_modules MapSet.new(~w(os erlang ets dets net inet gen_tcp gen_udp)a)

  @timeout_ms 30_000

  @doc """
  Evaluates Elixir code in a sandboxed environment.

  Returns `{:ok, result, new_bindings}` on success, or `{:error, reason}` on failure.
  """
  def eval(code, bindings \\ []) do
    with :ok <- validate_code(code) do
      run_with_timeout(code, bindings)
    end
  end

  defp validate_code(code) do
    case Code.string_to_quoted(code) do
      {:ok, ast} ->
        check_ast(ast)

      {:error, {meta, message, token}} ->
        line = if is_list(meta), do: Keyword.get(meta, :line, 1), else: 1
        {:error, "Syntax error on line #{line}: #{message}#{token}"}
    end
  end

  defp check_ast(ast) do
    {_, result} =
      Macro.prewalk(ast, :ok, fn
        node, {:error, _} = err ->
          {node, err}

        # Match module references like System, File, IO, etc.
        # In the AST: {:__aliases__, meta, [:System]} or {:__aliases__, meta, [:IO]}
        {:__aliases__, _meta, parts} = node, :ok ->
          # Check if any prefix of the parts matches a blocked module
          name = parts |> Enum.map(&to_string/1) |> Enum.join(".")

          if blocked_module_name?(name) do
            {node, {:error, "Access to #{name} is not allowed"}}
          else
            {node, :ok}
          end

        # Block :erlang.xxx / :os.xxx calls (atoms as module)
        {{:., _meta, [module, _func]}, _, _} = node, :ok when is_atom(module) ->
          if module in @blocked_erlang_modules do
            {node, {:error, "Access to :#{module} is not allowed"}}
          else
            {node, :ok}
          end

        node, acc ->
          {node, acc}
      end)

    result
  end

  defp blocked_module_name?(name) do
    # Check the module name or its first segment (e.g., "Task.Supervisor" checks "Task")
    name in @blocked_module_names or
      (String.contains?(name, ".") and
         name |> String.split(".") |> hd() |> then(&(&1 in @blocked_module_names)))
  end

  defp run_with_timeout(code, bindings) do
    task =
      Task.async(fn ->
        try do
          {result, new_bindings} = Code.eval_string(code, bindings)
          {:ok, result, new_bindings}
        rescue
          e -> {:error, Exception.format(:error, e)}
        catch
          kind, reason -> {:error, "#{kind}: #{inspect(reason)}"}
        end
      end)

    case Task.yield(task, @timeout_ms) || Task.shutdown(task, :brutal_kill) do
      {:ok, result} -> result
      nil -> {:error, "Execution timed out (#{div(@timeout_ms, 1000)} seconds)"}
    end
  end
end
