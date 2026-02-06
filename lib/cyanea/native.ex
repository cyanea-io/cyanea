defmodule Cyanea.Native do
  @moduledoc """
  Rust NIF bindings for high-performance compute via Cyanea Labs.

  This module provides native functions backed by the Rust crates in `labs/`.
  Each section corresponds to a Cyanea Labs crate.

  ## Available (implemented)

  - **Hashing** — SHA256 checksums (cyanea-core)
  - **Compression** — zstd compress/decompress (cyanea-core)
  - **FASTA/FASTQ** — Sequence file statistics (cyanea-seq)
  - **CSV** — Column info and preview (cyanea-io)

  ## Planned

  - **Alignment** — Pairwise and batch sequence alignment (cyanea-align)
  - **Omics** — VCF, BED, expression matrices (cyanea-omics)
  - **Statistics** — Descriptive stats, hypothesis testing (cyanea-stats)
  - **ML** — Embeddings, clustering (cyanea-ml)
  - **Chemistry** — SMILES parsing, molecular properties (cyanea-chem)
  - **Structures** — PDB/mmCIF parsing, RMSD (cyanea-struct)
  - **Phylogenetics** — Newick parsing, tree distances (cyanea-phylo)
  - **GPU** — Backend detection, GPU-accelerated compute (cyanea-gpu)
  """

  use Rustler,
    otp_app: :cyanea,
    crate: "cyanea_native",
    skip_compilation?: true

  # ===========================================================================
  # cyanea-core — Hashing & Compression
  # ===========================================================================

  @doc "Calculate SHA256 hash of binary data"
  def sha256(_data), do: :erlang.nif_error(:nif_not_loaded)

  @doc "Calculate SHA256 hash of a file"
  def sha256_file(_path), do: :erlang.nif_error(:nif_not_loaded)

  @doc "Compress data using zstd (level 1-22, default 3)"
  def zstd_compress(_data, _level \\ 3), do: :erlang.nif_error(:nif_not_loaded)

  @doc "Decompress zstd data"
  def zstd_decompress(_data), do: :erlang.nif_error(:nif_not_loaded)

  # ===========================================================================
  # cyanea-seq — Sequence I/O
  # ===========================================================================

  @doc "Get statistics from a FASTA/FASTQ file"
  def fasta_stats(_path), do: :erlang.nif_error(:nif_not_loaded)

  # ===========================================================================
  # cyanea-io — File Format Parsing
  # ===========================================================================

  @doc "Get info about a CSV file (row count, columns)"
  def csv_info(_path), do: :erlang.nif_error(:nif_not_loaded)

  @doc "Get preview of CSV file (first N rows as JSON)"
  def csv_preview(_path, _limit \\ 100), do: :erlang.nif_error(:nif_not_loaded)

  # ===========================================================================
  # cyanea-align — Sequence Alignment (planned)
  # ===========================================================================

  # def align_pairwise(_seq_a, _seq_b, _opts \\ %{}),
  #   do: :erlang.nif_error(:nif_not_loaded)

  # def align_batch(_sequences, _reference, _opts \\ %{}),
  #   do: :erlang.nif_error(:nif_not_loaded)

  # ===========================================================================
  # cyanea-omics — Omics Data Structures (planned)
  # ===========================================================================

  # def parse_vcf(_path), do: :erlang.nif_error(:nif_not_loaded)
  # def parse_bed(_path), do: :erlang.nif_error(:nif_not_loaded)
  # def expression_matrix_info(_path), do: :erlang.nif_error(:nif_not_loaded)

  # ===========================================================================
  # cyanea-stats — Statistical Methods (planned)
  # ===========================================================================

  # def descriptive_stats(_data), do: :erlang.nif_error(:nif_not_loaded)
  # def test_enrichment(_foreground, _background),
  #   do: :erlang.nif_error(:nif_not_loaded)

  # ===========================================================================
  # cyanea-ml — ML Primitives (planned)
  # ===========================================================================

  # def embed_sequences(_sequences, _model), do: :erlang.nif_error(:nif_not_loaded)
  # def cluster(_data, _method, _k), do: :erlang.nif_error(:nif_not_loaded)

  # ===========================================================================
  # cyanea-chem — Chemistry / Small Molecules (planned)
  # ===========================================================================

  # def parse_smiles(_smiles), do: :erlang.nif_error(:nif_not_loaded)
  # def molecular_properties(_smiles), do: :erlang.nif_error(:nif_not_loaded)

  # ===========================================================================
  # cyanea-struct — 3D Structures (planned)
  # ===========================================================================

  # def parse_pdb(_path), do: :erlang.nif_error(:nif_not_loaded)
  # def calc_rmsd(_structure_a, _structure_b),
  #   do: :erlang.nif_error(:nif_not_loaded)

  # ===========================================================================
  # cyanea-phylo — Phylogenetics (planned)
  # ===========================================================================

  # def parse_newick(_newick_string), do: :erlang.nif_error(:nif_not_loaded)
  # def tree_distance(_tree_a, _tree_b), do: :erlang.nif_error(:nif_not_loaded)

  # ===========================================================================
  # cyanea-gpu — GPU Compute (planned)
  # ===========================================================================

  # def gpu_available(), do: :erlang.nif_error(:nif_not_loaded)
  # def gpu_batch_align(_sequences, _reference),
  #   do: :erlang.nif_error(:nif_not_loaded)
end

# ===========================================================================
# Bridge structs — match Rust NifStruct modules
# ===========================================================================

defmodule Cyanea.Native.FastaStats do
  @moduledoc "FASTA file statistics (cyanea-seq)"
  defstruct [:sequence_count, :total_bases, :gc_content, :avg_length]
end

defmodule Cyanea.Native.CsvInfo do
  @moduledoc "CSV file metadata (cyanea-io)"
  defstruct [:row_count, :column_count, :columns, :has_headers]
end

# Planned bridge structs — uncomment as Rust NIFs are implemented:

# defmodule Cyanea.Native.AlignmentResult do
#   @moduledoc "Pairwise alignment result (cyanea-align)"
#   defstruct [:score, :aligned_a, :aligned_b, :cigar]
# end

# defmodule Cyanea.Native.VcfRecord do
#   @moduledoc "VCF variant record (cyanea-omics)"
#   defstruct [:chrom, :pos, :ref, :alt, :qual, :filter, :info]
# end

# defmodule Cyanea.Native.DescriptiveStats do
#   @moduledoc "Descriptive statistics result (cyanea-stats)"
#   defstruct [:mean, :median, :variance, :min, :max, :q1, :q3]
# end

# defmodule Cyanea.Native.MolecularProperties do
#   @moduledoc "Molecular properties (cyanea-chem)"
#   defstruct [:molecular_weight, :logp, :polar_surface_area, :formula]
# end

# defmodule Cyanea.Native.StructureInfo do
#   @moduledoc "Macromolecular structure metadata (cyanea-struct)"
#   defstruct [:num_atoms, :num_residues, :num_chains, :resolution]
# end

# defmodule Cyanea.Native.PhyloTree do
#   @moduledoc "Phylogenetic tree (cyanea-phylo)"
#   defstruct [:num_leaves, :num_internal, :is_rooted, :newick]
# end
