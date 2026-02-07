defmodule Cyanea.Native do
  @moduledoc """
  Rust NIF bindings for high-performance compute via Cyanea Labs.

  This module provides native functions backed by the Rust crates in `labs/`.
  Each section corresponds to a Cyanea Labs crate.

  ## Available (implemented)

  - **Hashing** — SHA256 checksums (cyanea-core)
  - **Compression** — zstd compress/decompress (cyanea-core)
  - **Sequences** — Validation, operations, k-mers, FASTA/FASTQ parsing (cyanea-seq)
  - **CSV** — Column info and preview (cyanea-io)
  - **Alignment** — Pairwise DNA/protein alignment, batch alignment (cyanea-align)
  - **Statistics** — Descriptive stats, correlation, hypothesis testing, p-value correction (cyanea-stats)
  - **Omics** — Variant classification, genomic intervals, expression matrices (cyanea-omics)

  ## Planned

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

  # --- Sequence validation --------------------------------------------------

  @doc "Validate and uppercase a DNA sequence (IUPAC alphabet)"
  def validate_dna(_data), do: :erlang.nif_error(:nif_not_loaded)

  @doc "Validate and uppercase an RNA sequence (IUPAC alphabet)"
  def validate_rna(_data), do: :erlang.nif_error(:nif_not_loaded)

  @doc "Validate and uppercase a protein sequence"
  def validate_protein(_data), do: :erlang.nif_error(:nif_not_loaded)

  # --- DNA operations -------------------------------------------------------

  @doc "Return the reverse complement of a DNA sequence"
  def dna_reverse_complement(_data), do: :erlang.nif_error(:nif_not_loaded)

  @doc "Transcribe DNA to RNA (T → U)"
  def dna_transcribe(_data), do: :erlang.nif_error(:nif_not_loaded)

  @doc "Calculate GC content of a DNA sequence (fraction 0.0–1.0)"
  def dna_gc_content(_data), do: :erlang.nif_error(:nif_not_loaded)

  # --- RNA operations -------------------------------------------------------

  @doc "Translate an RNA sequence to protein (NCBI Table 1)"
  def rna_translate(_data), do: :erlang.nif_error(:nif_not_loaded)

  # --- K-mers ---------------------------------------------------------------

  @doc "Extract k-mers from a DNA sequence as a list of binaries"
  def sequence_kmers(_data, _k), do: :erlang.nif_error(:nif_not_loaded)

  # --- FASTQ ----------------------------------------------------------------

  @doc "Parse a FASTQ file and return all records"
  def parse_fastq(_path), do: :erlang.nif_error(:nif_not_loaded)

  @doc "Get streaming statistics from a FASTQ file"
  def fastq_stats(_path), do: :erlang.nif_error(:nif_not_loaded)

  # --- Protein --------------------------------------------------------------

  @doc "Calculate molecular weight of a protein sequence (Daltons)"
  def protein_molecular_weight(_data), do: :erlang.nif_error(:nif_not_loaded)

  # ===========================================================================
  # cyanea-io — File Format Parsing
  # ===========================================================================

  @doc "Get info about a CSV file (row count, columns)"
  def csv_info(_path), do: :erlang.nif_error(:nif_not_loaded)

  @doc "Get preview of CSV file (first N rows as JSON)"
  def csv_preview(_path, _limit \\ 100), do: :erlang.nif_error(:nif_not_loaded)

  # ===========================================================================
  # cyanea-align — Sequence Alignment
  # ===========================================================================

  @doc "Align two DNA sequences with default scoring (+2/-1/-5/-2). Mode: \"local\", \"global\", or \"semiglobal\""
  def align_dna(_query, _target, _mode), do: :erlang.nif_error(:nif_not_loaded)

  @doc "Align two DNA sequences with custom scoring parameters"
  def align_dna_custom(_query, _target, _mode, _match_score, _mismatch_score, _gap_open, _gap_extend),
    do: :erlang.nif_error(:nif_not_loaded)

  @doc "Align two protein sequences. Matrix: \"blosum62\", \"blosum45\", \"blosum80\", or \"pam250\""
  def align_protein(_query, _target, _mode, _matrix), do: :erlang.nif_error(:nif_not_loaded)

  @doc "Batch-align a list of {query, target} DNA pairs (runs on DirtyCpu scheduler)"
  def align_batch_dna(_pairs, _mode), do: :erlang.nif_error(:nif_not_loaded)

  # ===========================================================================
  # cyanea-stats — Statistical Methods
  # ===========================================================================

  @doc "Compute descriptive statistics (15 fields) for a list of floats"
  def descriptive_stats(_data), do: :erlang.nif_error(:nif_not_loaded)

  @doc "Compute Pearson product-moment correlation coefficient"
  def pearson_correlation(_x, _y), do: :erlang.nif_error(:nif_not_loaded)

  @doc "Compute Spearman rank correlation coefficient"
  def spearman_correlation(_x, _y), do: :erlang.nif_error(:nif_not_loaded)

  @doc "One-sample t-test (test if population mean equals mu)"
  def t_test_one_sample(_data, _mu), do: :erlang.nif_error(:nif_not_loaded)

  @doc "Two-sample t-test. Set equal_var to true for Student's, false for Welch's"
  def t_test_two_sample(_x, _y, _equal_var), do: :erlang.nif_error(:nif_not_loaded)

  @doc "Mann-Whitney U test (non-parametric, two independent samples)"
  def mann_whitney_u(_x, _y), do: :erlang.nif_error(:nif_not_loaded)

  @doc "Bonferroni p-value correction (controls family-wise error rate)"
  def p_adjust_bonferroni(_p_values), do: :erlang.nif_error(:nif_not_loaded)

  @doc "Benjamini-Hochberg p-value correction (controls false discovery rate)"
  def p_adjust_bh(_p_values), do: :erlang.nif_error(:nif_not_loaded)

  # ===========================================================================
  # cyanea-omics — Omics Data Structures
  # ===========================================================================

  @doc "Classify a genomic variant (SNV, insertion, deletion, etc.)"
  def classify_variant(_chrom, _position, _ref_allele, _alt_alleles),
    do: :erlang.nif_error(:nif_not_loaded)

  @doc "Merge overlapping genomic intervals (parallel arrays of chrom, start, end)"
  def merge_genomic_intervals(_chroms, _starts, _ends),
    do: :erlang.nif_error(:nif_not_loaded)

  @doc "Total bases covered on a chromosome (after merging overlaps)"
  def genomic_coverage(_chroms, _starts, _ends, _query_chrom),
    do: :erlang.nif_error(:nif_not_loaded)

  @doc "Compute summary statistics for an expression matrix (2D list of floats)"
  def expression_summary(_data, _feature_names, _sample_names),
    do: :erlang.nif_error(:nif_not_loaded)

  @doc "Log2-transform a matrix: log2(x + pseudocount) for all values"
  def log_transform_matrix(_data, _pseudocount), do: :erlang.nif_error(:nif_not_loaded)

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

# --- cyanea-seq ---

defmodule Cyanea.Native.FastaStats do
  @moduledoc "FASTA file statistics (cyanea-seq)"
  defstruct [:sequence_count, :total_bases, :gc_content, :avg_length]
end

defmodule Cyanea.Native.CsvInfo do
  @moduledoc "CSV file metadata (cyanea-io)"
  defstruct [:row_count, :column_count, :columns, :has_headers]
end

defmodule Cyanea.Native.FastqRecord do
  @moduledoc "FASTQ record (cyanea-seq)"
  defstruct [:name, :description, :sequence, :quality]
end

defmodule Cyanea.Native.FastqStats do
  @moduledoc "FASTQ file statistics (cyanea-seq)"
  defstruct [:sequence_count, :total_bases, :gc_content, :avg_length,
             :mean_quality, :q20_fraction, :q30_fraction]
end

# --- cyanea-align ---

defmodule Cyanea.Native.AlignmentResult do
  @moduledoc "Pairwise alignment result (cyanea-align)"
  defstruct [:score, :aligned_query, :aligned_target,
             :query_start, :query_end, :target_start, :target_end,
             :cigar, :identity, :num_matches, :num_mismatches,
             :num_gaps, :alignment_length]
end

# --- cyanea-stats ---

defmodule Cyanea.Native.DescriptiveStats do
  @moduledoc "Descriptive statistics result (cyanea-stats)"
  defstruct [:count, :mean, :median, :variance, :sample_variance,
             :std_dev, :sample_std_dev, :min, :max, :range,
             :q1, :q3, :iqr, :skewness, :kurtosis]
end

defmodule Cyanea.Native.TestResult do
  @moduledoc "Hypothesis test result (cyanea-stats)"
  defstruct [:statistic, :p_value, :degrees_of_freedom, :method]
end

# --- cyanea-omics ---

defmodule Cyanea.Native.VariantClassification do
  @moduledoc "Variant classification result (cyanea-omics)"
  defstruct [:chrom, :position, :variant_type,
             :is_snv, :is_indel, :is_transition, :is_transversion]
end

defmodule Cyanea.Native.GenomicInterval do
  @moduledoc "Genomic interval (cyanea-omics)"
  defstruct [:chrom, :start, :end, :strand]
end

defmodule Cyanea.Native.ExpressionSummary do
  @moduledoc "Expression matrix summary (cyanea-omics)"
  defstruct [:n_features, :n_samples, :feature_names, :sample_names,
             :feature_means, :sample_means]
end

# --- Planned bridge structs (uncomment as Rust NIFs are implemented) ---

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
