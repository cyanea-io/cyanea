//! Cyanea Native — Thin NIF bridge to Cyanea Labs.
//!
//! This crate exposes Elixir NIFs that delegate to the standalone
//! libraries in `labs/`. No business logic lives here — only type
//! conversions between Rustler NIF types and Cyanea Labs types.

use rustler::NifStruct;

// Import traits needed for FastqRecord field access.
use cyanea_core::{Annotated, Sequence};

rustler::init!("Elixir.Cyanea.Native");

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Convert a `cyanea_core::CyaneaError` into a NIF-friendly `String`.
fn to_nif_error(e: cyanea_core::CyaneaError) -> String {
    e.to_string()
}

// ===========================================================================
// cyanea-core — Hashing & Compression
// ===========================================================================

#[rustler::nif]
fn sha256(data: Vec<u8>) -> String {
    cyanea_core::hash::sha256(&data)
}

#[rustler::nif]
fn sha256_file(path: String) -> Result<String, String> {
    cyanea_core::hash::sha256_file(&path).map_err(to_nif_error)
}

#[rustler::nif]
fn zstd_compress(data: Vec<u8>, level: i32) -> Result<Vec<u8>, String> {
    cyanea_core::compress::zstd_compress(&data, level).map_err(to_nif_error)
}

#[rustler::nif]
fn zstd_decompress(data: Vec<u8>) -> Result<Vec<u8>, String> {
    cyanea_core::compress::zstd_decompress(&data).map_err(to_nif_error)
}

// ===========================================================================
// cyanea-seq — Sequence I/O
// ===========================================================================

// --- Bridge structs --------------------------------------------------------

#[derive(Debug, NifStruct)]
#[module = "Cyanea.Native.FastaStats"]
pub struct FastaStatsNif {
    pub sequence_count: u64,
    pub total_bases: u64,
    pub gc_content: f64,
    pub avg_length: f64,
}

impl From<cyanea_seq::FastaStats> for FastaStatsNif {
    fn from(s: cyanea_seq::FastaStats) -> Self {
        Self {
            sequence_count: s.sequence_count,
            total_bases: s.total_bases,
            gc_content: s.gc_content,
            avg_length: s.avg_length,
        }
    }
}

#[derive(Debug, NifStruct)]
#[module = "Cyanea.Native.FastqRecord"]
pub struct FastqRecordNif {
    pub name: String,
    pub description: String,
    pub sequence: Vec<u8>,
    pub quality: Vec<u8>,
}

impl From<cyanea_seq::FastqRecord> for FastqRecordNif {
    fn from(r: cyanea_seq::FastqRecord) -> Self {
        let name = r.name().to_string();
        let description = r.description().unwrap_or("").to_string();
        let quality = r.quality().as_slice().to_vec();
        let sequence = r.sequence().as_bytes().to_vec();
        Self {
            name,
            description,
            sequence,
            quality,
        }
    }
}

#[derive(Debug, NifStruct)]
#[module = "Cyanea.Native.FastqStats"]
pub struct FastqStatsNif {
    pub sequence_count: u64,
    pub total_bases: u64,
    pub gc_content: f64,
    pub avg_length: f64,
    pub mean_quality: f64,
    pub q20_fraction: f64,
    pub q30_fraction: f64,
}

impl From<cyanea_seq::FastqStats> for FastqStatsNif {
    fn from(s: cyanea_seq::FastqStats) -> Self {
        Self {
            sequence_count: s.sequence_count,
            total_bases: s.total_bases,
            gc_content: s.gc_content,
            avg_length: s.avg_length,
            mean_quality: s.mean_quality,
            q20_fraction: s.q20_fraction,
            q30_fraction: s.q30_fraction,
        }
    }
}

// --- FASTA -----------------------------------------------------------------

#[rustler::nif(schedule = "DirtyCpu")]
fn fasta_stats(path: String) -> Result<FastaStatsNif, String> {
    cyanea_seq::parse_fasta_stats(&path)
        .map(FastaStatsNif::from)
        .map_err(to_nif_error)
}

// --- Sequence validation ---------------------------------------------------

#[rustler::nif]
fn validate_dna(data: Vec<u8>) -> Result<Vec<u8>, String> {
    let seq = cyanea_seq::DnaSequence::new(&data).map_err(to_nif_error)?;
    Ok(seq.into_bytes())
}

#[rustler::nif]
fn validate_rna(data: Vec<u8>) -> Result<Vec<u8>, String> {
    let seq = cyanea_seq::RnaSequence::new(&data).map_err(to_nif_error)?;
    Ok(seq.into_bytes())
}

#[rustler::nif]
fn validate_protein(data: Vec<u8>) -> Result<Vec<u8>, String> {
    let seq = cyanea_seq::ProteinSequence::new(&data).map_err(to_nif_error)?;
    Ok(seq.into_bytes())
}

// --- DNA operations --------------------------------------------------------

#[rustler::nif]
fn dna_reverse_complement(data: Vec<u8>) -> Result<Vec<u8>, String> {
    let seq = cyanea_seq::DnaSequence::new(&data).map_err(to_nif_error)?;
    Ok(seq.reverse_complement().into_bytes())
}

#[rustler::nif]
fn dna_transcribe(data: Vec<u8>) -> Result<Vec<u8>, String> {
    let seq = cyanea_seq::DnaSequence::new(&data).map_err(to_nif_error)?;
    Ok(seq.transcribe().into_bytes())
}

#[rustler::nif]
fn dna_gc_content(data: Vec<u8>) -> Result<f64, String> {
    let seq = cyanea_seq::DnaSequence::new(&data).map_err(to_nif_error)?;
    Ok(seq.gc_content())
}

// --- RNA operations --------------------------------------------------------

#[rustler::nif]
fn rna_translate(data: Vec<u8>) -> Result<Vec<u8>, String> {
    let seq = cyanea_seq::RnaSequence::new(&data).map_err(to_nif_error)?;
    seq.translate()
        .map(|p| p.into_bytes())
        .map_err(to_nif_error)
}

// --- K-mers ----------------------------------------------------------------

#[rustler::nif]
fn sequence_kmers(data: Vec<u8>, k: usize) -> Result<Vec<Vec<u8>>, String> {
    let seq = cyanea_seq::DnaSequence::new(&data).map_err(to_nif_error)?;
    let kmers = seq
        .kmers(k)
        .map_err(to_nif_error)?
        .map(|kmer| kmer.to_vec())
        .collect();
    Ok(kmers)
}

// --- FASTQ -----------------------------------------------------------------

#[rustler::nif(schedule = "DirtyCpu")]
fn parse_fastq(path: String) -> Result<Vec<FastqRecordNif>, String> {
    cyanea_seq::parse_fastq_file(&path)
        .map(|records| records.into_iter().map(FastqRecordNif::from).collect())
        .map_err(to_nif_error)
}

#[rustler::nif(schedule = "DirtyCpu")]
fn fastq_stats(path: String) -> Result<FastqStatsNif, String> {
    cyanea_seq::parse_fastq_stats(&path)
        .map(FastqStatsNif::from)
        .map_err(to_nif_error)
}

// --- Protein ---------------------------------------------------------------

#[rustler::nif]
fn protein_molecular_weight(data: Vec<u8>) -> Result<f64, String> {
    let seq = cyanea_seq::ProteinSequence::new(&data).map_err(to_nif_error)?;
    Ok(seq.molecular_weight())
}

// ===========================================================================
// cyanea-io — File Format Parsing
// ===========================================================================

#[derive(Debug, NifStruct)]
#[module = "Cyanea.Native.CsvInfo"]
pub struct CsvInfoNif {
    pub row_count: u64,
    pub column_count: usize,
    pub columns: Vec<String>,
    pub has_headers: bool,
}

impl From<cyanea_io::CsvInfo> for CsvInfoNif {
    fn from(c: cyanea_io::CsvInfo) -> Self {
        Self {
            row_count: c.row_count,
            column_count: c.column_count,
            columns: c.columns,
            has_headers: c.has_headers,
        }
    }
}

#[rustler::nif(schedule = "DirtyCpu")]
fn csv_info(path: String) -> Result<CsvInfoNif, String> {
    cyanea_io::parse_csv_info(&path)
        .map(CsvInfoNif::from)
        .map_err(to_nif_error)
}

#[rustler::nif(schedule = "DirtyCpu")]
fn csv_preview(path: String, limit: usize) -> Result<String, String> {
    cyanea_io::csv_preview(&path, limit).map_err(to_nif_error)
}

// ===========================================================================
// cyanea-align — Sequence Alignment
// ===========================================================================
//
// Planned NIFs:
// - align_pairwise(seq_a, seq_b, opts) — Smith-Waterman / Needleman-Wunsch
// - align_batch(sequences, reference, opts) — batch alignment (DirtyCpu)

// ===========================================================================
// cyanea-omics — Omics Data Structures
// ===========================================================================
//
// Planned NIFs:
// - parse_vcf(path) — VCF variant parsing
// - parse_bed(path) — BED region parsing
// - expression_matrix_info(path) — matrix metadata

// ===========================================================================
// cyanea-stats — Statistical Methods
// ===========================================================================
//
// Planned NIFs:
// - descriptive_stats(data) — mean, median, variance, quantiles
// - test_enrichment(foreground, background) — Fisher's exact / chi-squared

// ===========================================================================
// cyanea-ml — ML Primitives
// ===========================================================================
//
// Planned NIFs:
// - embed_sequences(sequences, model) — sequence embeddings (DirtyCpu)
// - cluster(data, method, k) — k-means / DBSCAN clustering

// ===========================================================================
// cyanea-chem — Chemistry / Small Molecules
// ===========================================================================
//
// Planned NIFs:
// - parse_smiles(smiles) — SMILES string to molecular representation
// - molecular_properties(smiles) — MW, LogP, PSA

// ===========================================================================
// cyanea-struct — 3D Structures
// ===========================================================================
//
// Planned NIFs:
// - parse_pdb(path) — PDB/mmCIF structure parsing (DirtyCpu)
// - calc_rmsd(structure_a, structure_b) — structural superposition

// ===========================================================================
// cyanea-phylo — Phylogenetics
// ===========================================================================
//
// Planned NIFs:
// - parse_newick(newick_string) — Newick tree parsing
// - tree_distance(tree_a, tree_b) — Robinson-Foulds distance

// ===========================================================================
// cyanea-gpu — GPU Compute
// ===========================================================================
//
// Planned NIFs:
// - gpu_available() — check for CUDA/Metal backend
// - gpu_batch_align(sequences, reference) — GPU-accelerated batch alignment
