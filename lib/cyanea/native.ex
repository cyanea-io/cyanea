defmodule Cyanea.Native do
  @moduledoc """
  Rust NIF bindings for high-performance file processing.

  This module provides native functions for:
  - SHA256 checksums
  - zstd compression
  - FASTA/FASTQ parsing
  - CSV parsing
  """

  use Rustler,
    otp_app: :cyanea,
    crate: "cyanea_native"

  # Hashing
  @doc "Calculate SHA256 hash of binary data"
  def sha256(_data), do: :erlang.nif_error(:nif_not_loaded)

  @doc "Calculate SHA256 hash of a file"
  def sha256_file(_path), do: :erlang.nif_error(:nif_not_loaded)

  # Compression
  @doc "Compress data using zstd (level 1-22, default 3)"
  def zstd_compress(_data, _level \\ 3), do: :erlang.nif_error(:nif_not_loaded)

  @doc "Decompress zstd data"
  def zstd_decompress(_data), do: :erlang.nif_error(:nif_not_loaded)

  # FASTA/FASTQ parsing
  @doc "Get statistics from a FASTA/FASTQ file"
  def fasta_stats(_path), do: :erlang.nif_error(:nif_not_loaded)

  # CSV parsing
  @doc "Get info about a CSV file (row count, columns)"
  def csv_info(_path), do: :erlang.nif_error(:nif_not_loaded)

  @doc "Get preview of CSV file (first N rows as JSON)"
  def csv_preview(_path, _limit \\ 100), do: :erlang.nif_error(:nif_not_loaded)
end

defmodule Cyanea.Native.FastaStats do
  @moduledoc "FASTA file statistics"
  defstruct [:sequence_count, :total_bases, :gc_content, :avg_length]
end

defmodule Cyanea.Native.CsvInfo do
  @moduledoc "CSV file metadata"
  defstruct [:row_count, :column_count, :columns, :has_headers]
end
