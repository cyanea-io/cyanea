defmodule Cyanea.Notebooks.JupyterImport do
  @moduledoc """
  Parses Jupyter notebook (.ipynb) JSON files and converts them to Cyanea notebook format.
  Supports nbformat 4.x.
  """

  @doc """
  Parses an .ipynb JSON string and converts it to Cyanea notebook format.

  Returns `{:ok, %{title: title, content: content, metadata: metadata}}` or `{:error, reason}`.
  """
  def parse(ipynb_json) when is_binary(ipynb_json) do
    with {:ok, data} <- Jason.decode(ipynb_json),
         :ok <- validate_format(data) do
      title = extract_title(data)
      cells = convert_cells(data["cells"] || [])
      metadata = extract_metadata(data)

      {:ok,
       %{
         title: title,
         content: %{"cells" => cells},
         metadata: metadata
       }}
    end
  end

  def parse(_), do: {:error, "Expected a JSON string"}

  defp validate_format(%{"nbformat" => nbformat}) when nbformat >= 4, do: :ok
  defp validate_format(%{"nbformat" => _}), do: {:error, "Only nbformat 4.x is supported"}
  defp validate_format(_), do: {:error, "Invalid Jupyter notebook format: missing nbformat"}

  defp extract_title(data) do
    # Try metadata title first
    title = get_in(data, ["metadata", "title"])

    # Fall back to first markdown heading
    title = title || find_first_heading(data["cells"] || [])

    # Fall back to kernel display name
    title = title || get_in(data, ["metadata", "kernelspec", "display_name"])

    title || "Imported Notebook"
  end

  defp find_first_heading(cells) do
    cells
    |> Enum.find_value(fn
      %{"cell_type" => "markdown", "source" => source} ->
        source
        |> join_source()
        |> String.split("\n")
        |> Enum.find_value(fn line ->
          case Regex.run(~r/^#\s+(.+)$/, String.trim(line)) do
            [_, title] -> String.trim(title)
            _ -> nil
          end
        end)

      _ ->
        nil
    end)
  end

  defp convert_cells(cells) do
    cells
    |> Enum.with_index()
    |> Enum.map(fn {cell, idx} -> convert_cell(cell, idx) end)
  end

  defp convert_cell(%{"cell_type" => "code"} = cell, idx) do
    source = join_source(cell["source"])
    language = get_in(cell, ["metadata", "language"]) || "cyanea"

    %{
      "id" => Ecto.UUID.generate(),
      "type" => "code",
      "source" => source,
      "language" => language,
      "position" => idx
    }
  end

  defp convert_cell(%{"cell_type" => type} = cell, idx) when type in ["markdown", "raw"] do
    source = join_source(cell["source"])

    %{
      "id" => Ecto.UUID.generate(),
      "type" => "markdown",
      "source" => source,
      "position" => idx
    }
  end

  defp convert_cell(_cell, idx) do
    %{
      "id" => Ecto.UUID.generate(),
      "type" => "markdown",
      "source" => "",
      "position" => idx
    }
  end

  defp extract_metadata(data) do
    kernel = get_in(data, ["metadata", "kernelspec"]) || %{}
    language = get_in(data, ["metadata", "language_info", "name"])

    %{
      "imported_from" => "jupyter",
      "nbformat" => data["nbformat"],
      "kernel" => kernel["name"],
      "language" => language
    }
    |> Enum.reject(fn {_, v} -> is_nil(v) end)
    |> Map.new()
  end

  defp join_source(source) when is_list(source), do: Enum.join(source)
  defp join_source(source) when is_binary(source), do: source
  defp join_source(_), do: ""
end
