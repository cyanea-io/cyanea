defmodule CyaneaWeb.Markdown do
  @moduledoc """
  Safe Earmark wrapper for rendering Markdown to HTML.
  """

  @doc """
  Converts a Markdown string to safe HTML.

  Returns `{:safe, html}` on success, or `{:safe, escaped}` on parse failure.
  """
  def render(nil), do: {:safe, ""}
  def render(""), do: {:safe, ""}

  def render(markdown) when is_binary(markdown) do
    case Earmark.as_html(markdown, escape: true, smartypants: false) do
      {:ok, html, _warnings} ->
        {:safe, html}

      {:error, _html, _errors} ->
        {:safe, Phoenix.HTML.html_escape(markdown) |> Phoenix.HTML.safe_to_string()}
    end
  end
end
