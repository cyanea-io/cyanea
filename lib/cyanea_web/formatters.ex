defmodule CyaneaWeb.Formatters do
  @moduledoc """
  Shared formatting helpers for the Cyanea platform.

  Provides human-friendly formatting for file sizes, dates, timestamps,
  and license codes. Used by components and LiveViews alike.
  """

  @doc """
  Formats a byte count as a human-readable file size.

  ## Examples

      iex> CyaneaWeb.Formatters.format_size(512)
      "512 B"

      iex> CyaneaWeb.Formatters.format_size(1_536)
      "1.5 KB"

      iex> CyaneaWeb.Formatters.format_size(2_621_440)
      "2.5 MB"
  """
  def format_size(bytes) when is_number(bytes) and bytes < 1024,
    do: "#{bytes} B"

  def format_size(bytes) when is_number(bytes) and bytes < 1_048_576,
    do: "#{Float.round(bytes / 1024, 1)} KB"

  def format_size(bytes) when is_number(bytes) and bytes < 1_073_741_824,
    do: "#{Float.round(bytes / 1_048_576, 1)} MB"

  def format_size(bytes) when is_number(bytes),
    do: "#{Float.round(bytes / 1_073_741_824, 1)} GB"

  def format_size(_), do: "—"

  @doc """
  Formats a datetime as a relative time string (e.g., "2h ago").

  ## Examples

      iex> CyaneaWeb.Formatters.format_relative(DateTime.utc_now())
      "just now"
  """
  def format_relative(nil), do: ""

  def format_relative(%DateTime{} = datetime) do
    diff = DateTime.diff(DateTime.utc_now(), datetime, :second)

    cond do
      diff < 0 -> "just now"
      diff < 60 -> "just now"
      diff < 3600 -> "#{div(diff, 60)}m ago"
      diff < 86400 -> "#{div(diff, 3600)}h ago"
      diff < 604_800 -> "#{div(diff, 86400)}d ago"
      true -> format_date(datetime)
    end
  end

  def format_relative(%NaiveDateTime{} = datetime) do
    datetime
    |> DateTime.from_naive!("Etc/UTC")
    |> format_relative()
  end

  @doc """
  Formats a datetime as a calendar date (e.g., "Feb 7, 2026").

  ## Examples

      iex> CyaneaWeb.Formatters.format_date(~U[2026-02-07 12:00:00Z])
      "Feb 7, 2026"
  """
  def format_date(nil), do: ""

  def format_date(%DateTime{} = datetime) do
    Calendar.strftime(datetime, "%b %-d, %Y")
  end

  def format_date(%NaiveDateTime{} = datetime) do
    Calendar.strftime(datetime, "%b %-d, %Y")
  end

  def format_date(%Date{} = date) do
    Calendar.strftime(date, "%b %-d, %Y")
  end

  @doc """
  Maps a license SPDX code to a human-readable display name.

  ## Examples

      iex> CyaneaWeb.Formatters.license_display("mit")
      "MIT License"

      iex> CyaneaWeb.Formatters.license_display("cc-by-4.0")
      "CC BY 4.0"
  """
  def license_display(nil), do: nil

  def license_display(code) when is_binary(code) do
    code
    |> String.downcase()
    |> do_license_display()
  end

  defp do_license_display("mit"), do: "MIT License"
  defp do_license_display("apache-2.0"), do: "Apache 2.0"
  defp do_license_display("gpl-3.0"), do: "GPL 3.0"
  defp do_license_display("gpl-2.0"), do: "GPL 2.0"
  defp do_license_display("bsd-2-clause"), do: "BSD 2-Clause"
  defp do_license_display("bsd-3-clause"), do: "BSD 3-Clause"
  defp do_license_display("cc-by-4.0"), do: "CC BY 4.0"
  defp do_license_display("cc-by-sa-4.0"), do: "CC BY-SA 4.0"
  defp do_license_display("cc-by-nc-4.0"), do: "CC BY-NC 4.0"
  defp do_license_display("cc0-1.0"), do: "CC0 1.0"
  defp do_license_display("unlicense"), do: "Unlicense"
  defp do_license_display("mpl-2.0"), do: "MPL 2.0"
  defp do_license_display("lgpl-3.0"), do: "LGPL 3.0"
  defp do_license_display("agpl-3.0"), do: "AGPL 3.0"
  defp do_license_display(code), do: String.upcase(code)
end
