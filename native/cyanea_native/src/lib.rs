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

// --- Bridge structs --------------------------------------------------------

#[derive(Debug, NifStruct)]
#[module = "Cyanea.Native.AlignmentResult"]
pub struct AlignmentResultNif {
    pub score: i32,
    pub aligned_query: Vec<u8>,
    pub aligned_target: Vec<u8>,
    pub query_start: usize,
    pub query_end: usize,
    pub target_start: usize,
    pub target_end: usize,
    pub cigar: String,
    pub identity: f64,
    pub num_matches: usize,
    pub num_mismatches: usize,
    pub num_gaps: usize,
    pub alignment_length: usize,
}

impl From<cyanea_align::AlignmentResult> for AlignmentResultNif {
    fn from(r: cyanea_align::AlignmentResult) -> Self {
        Self {
            score: r.score,
            aligned_query: r.aligned_query.clone(),
            aligned_target: r.aligned_target.clone(),
            query_start: r.query_start,
            query_end: r.query_end,
            target_start: r.target_start,
            target_end: r.target_end,
            cigar: r.cigar_string(),
            identity: r.identity(),
            num_matches: r.matches(),
            num_mismatches: r.mismatches(),
            num_gaps: r.gaps(),
            alignment_length: r.length(),
        }
    }
}

// --- Helpers ---------------------------------------------------------------

fn parse_alignment_mode(mode: &str) -> Result<cyanea_align::AlignmentMode, String> {
    match mode {
        "local" => Ok(cyanea_align::AlignmentMode::Local),
        "global" => Ok(cyanea_align::AlignmentMode::Global),
        "semiglobal" => Ok(cyanea_align::AlignmentMode::SemiGlobal),
        _ => Err(format!("unknown alignment mode: {mode} (expected local, global, or semiglobal)")),
    }
}

fn parse_substitution_matrix(name: &str) -> Result<cyanea_align::SubstitutionMatrix, String> {
    match name {
        "blosum62" => Ok(cyanea_align::SubstitutionMatrix::blosum62()),
        "blosum45" => Ok(cyanea_align::SubstitutionMatrix::blosum45()),
        "blosum80" => Ok(cyanea_align::SubstitutionMatrix::blosum80()),
        "pam250" => Ok(cyanea_align::SubstitutionMatrix::pam250()),
        _ => Err(format!("unknown substitution matrix: {name} (expected blosum62, blosum45, blosum80, or pam250)")),
    }
}

// --- NIFs ------------------------------------------------------------------

#[rustler::nif]
fn align_dna(query: Vec<u8>, target: Vec<u8>, mode: String) -> Result<AlignmentResultNif, String> {
    let mode = parse_alignment_mode(&mode)?;
    let scoring = cyanea_align::ScoringScheme::Simple(cyanea_align::ScoringMatrix::dna_default());
    cyanea_align::align(&query, &target, mode, &scoring)
        .map(AlignmentResultNif::from)
        .map_err(to_nif_error)
}

#[rustler::nif]
fn align_dna_custom(
    query: Vec<u8>,
    target: Vec<u8>,
    mode: String,
    match_score: i32,
    mismatch_score: i32,
    gap_open: i32,
    gap_extend: i32,
) -> Result<AlignmentResultNif, String> {
    let mode = parse_alignment_mode(&mode)?;
    let matrix = cyanea_align::ScoringMatrix::new(match_score, mismatch_score, gap_open, gap_extend)
        .map_err(to_nif_error)?;
    let scoring = cyanea_align::ScoringScheme::Simple(matrix);
    cyanea_align::align(&query, &target, mode, &scoring)
        .map(AlignmentResultNif::from)
        .map_err(to_nif_error)
}

#[rustler::nif]
fn align_protein(
    query: Vec<u8>,
    target: Vec<u8>,
    mode: String,
    matrix: String,
) -> Result<AlignmentResultNif, String> {
    let mode = parse_alignment_mode(&mode)?;
    let sub_matrix = parse_substitution_matrix(&matrix)?;
    let scoring = cyanea_align::ScoringScheme::Substitution(sub_matrix);
    cyanea_align::align(&query, &target, mode, &scoring)
        .map(AlignmentResultNif::from)
        .map_err(to_nif_error)
}

#[rustler::nif(schedule = "DirtyCpu")]
fn align_batch_dna(
    pairs: Vec<(Vec<u8>, Vec<u8>)>,
    mode: String,
) -> Result<Vec<AlignmentResultNif>, String> {
    let mode = parse_alignment_mode(&mode)?;
    let scoring = cyanea_align::ScoringScheme::Simple(cyanea_align::ScoringMatrix::dna_default());
    let refs: Vec<(&[u8], &[u8])> = pairs.iter().map(|(q, t)| (q.as_slice(), t.as_slice())).collect();
    cyanea_align::align_batch(&refs, mode, &scoring)
        .map(|results| results.into_iter().map(AlignmentResultNif::from).collect())
        .map_err(to_nif_error)
}

// ===========================================================================
// cyanea-stats — Statistical Methods
// ===========================================================================

// --- Bridge structs --------------------------------------------------------

#[derive(Debug, NifStruct)]
#[module = "Cyanea.Native.DescriptiveStats"]
pub struct DescriptiveStatsNif {
    pub count: usize,
    pub mean: f64,
    pub median: f64,
    pub variance: f64,
    pub sample_variance: f64,
    pub std_dev: f64,
    pub sample_std_dev: f64,
    pub min: f64,
    pub max: f64,
    pub range: f64,
    pub q1: f64,
    pub q3: f64,
    pub iqr: f64,
    pub skewness: f64,
    pub kurtosis: f64,
}

impl From<cyanea_stats::DescriptiveStats> for DescriptiveStatsNif {
    fn from(s: cyanea_stats::DescriptiveStats) -> Self {
        Self {
            count: s.count,
            mean: s.mean,
            median: s.median,
            variance: s.variance,
            sample_variance: s.sample_variance,
            std_dev: s.std_dev,
            sample_std_dev: s.sample_std_dev,
            min: s.min,
            max: s.max,
            range: s.range,
            q1: s.q1,
            q3: s.q3,
            iqr: s.iqr,
            skewness: s.skewness,
            kurtosis: s.kurtosis,
        }
    }
}

#[derive(Debug, NifStruct)]
#[module = "Cyanea.Native.TestResult"]
pub struct TestResultNif {
    pub statistic: f64,
    pub p_value: f64,
    pub degrees_of_freedom: Option<f64>,
    pub method: String,
}

impl From<cyanea_stats::TestResult> for TestResultNif {
    fn from(r: cyanea_stats::TestResult) -> Self {
        Self {
            statistic: r.statistic,
            p_value: r.p_value,
            degrees_of_freedom: r.degrees_of_freedom,
            method: r.method,
        }
    }
}

// --- NIFs ------------------------------------------------------------------

#[rustler::nif]
fn descriptive_stats(data: Vec<f64>) -> Result<DescriptiveStatsNif, String> {
    cyanea_stats::descriptive::describe(&data)
        .map(DescriptiveStatsNif::from)
        .map_err(to_nif_error)
}

#[rustler::nif]
fn pearson_correlation(x: Vec<f64>, y: Vec<f64>) -> Result<f64, String> {
    cyanea_stats::correlation::pearson(&x, &y).map_err(to_nif_error)
}

#[rustler::nif]
fn spearman_correlation(x: Vec<f64>, y: Vec<f64>) -> Result<f64, String> {
    cyanea_stats::correlation::spearman(&x, &y).map_err(to_nif_error)
}

#[rustler::nif]
fn t_test_one_sample(data: Vec<f64>, mu: f64) -> Result<TestResultNif, String> {
    cyanea_stats::testing::t_test_one_sample(&data, mu)
        .map(TestResultNif::from)
        .map_err(to_nif_error)
}

#[rustler::nif]
fn t_test_two_sample(x: Vec<f64>, y: Vec<f64>, equal_var: bool) -> Result<TestResultNif, String> {
    cyanea_stats::testing::t_test_two_sample(&x, &y, equal_var)
        .map(TestResultNif::from)
        .map_err(to_nif_error)
}

#[rustler::nif]
fn mann_whitney_u(x: Vec<f64>, y: Vec<f64>) -> Result<TestResultNif, String> {
    cyanea_stats::testing::mann_whitney_u(&x, &y)
        .map(TestResultNif::from)
        .map_err(to_nif_error)
}

#[rustler::nif]
fn p_adjust_bonferroni(p_values: Vec<f64>) -> Result<Vec<f64>, String> {
    cyanea_stats::correction::bonferroni(&p_values).map_err(to_nif_error)
}

#[rustler::nif]
fn p_adjust_bh(p_values: Vec<f64>) -> Result<Vec<f64>, String> {
    cyanea_stats::correction::benjamini_hochberg(&p_values).map_err(to_nif_error)
}

// ===========================================================================
// cyanea-omics — Omics Data Structures
// ===========================================================================

// --- Bridge structs --------------------------------------------------------

#[derive(Debug, NifStruct)]
#[module = "Cyanea.Native.VariantClassification"]
pub struct VariantClassificationNif {
    pub chrom: String,
    pub position: u64,
    pub variant_type: String,
    pub is_snv: bool,
    pub is_indel: bool,
    pub is_transition: bool,
    pub is_transversion: bool,
}

#[derive(Debug, NifStruct)]
#[module = "Cyanea.Native.GenomicInterval"]
pub struct GenomicIntervalNif {
    pub chrom: String,
    pub start: u64,
    pub end: u64,
    pub strand: String,
}

impl From<cyanea_omics::GenomicInterval> for GenomicIntervalNif {
    fn from(iv: cyanea_omics::GenomicInterval) -> Self {
        Self {
            chrom: iv.chrom.clone(),
            start: iv.start,
            end: iv.end,
            strand: iv.strand.to_string(),
        }
    }
}

#[derive(Debug, NifStruct)]
#[module = "Cyanea.Native.ExpressionSummary"]
pub struct ExpressionSummaryNif {
    pub n_features: usize,
    pub n_samples: usize,
    pub feature_names: Vec<String>,
    pub sample_names: Vec<String>,
    pub feature_means: Vec<f64>,
    pub sample_means: Vec<f64>,
}

// --- NIFs ------------------------------------------------------------------

#[rustler::nif]
fn classify_variant(
    chrom: String,
    position: u64,
    ref_allele: Vec<u8>,
    alt_alleles: Vec<Vec<u8>>,
) -> Result<VariantClassificationNif, String> {
    let variant = cyanea_omics::Variant::new(chrom, position, ref_allele, alt_alleles)
        .map_err(to_nif_error)?;
    let vtype = variant.variant_type();
    Ok(VariantClassificationNif {
        chrom: variant.chrom.clone(),
        position: variant.position,
        variant_type: format!("{:?}", vtype),
        is_snv: variant.is_snv(),
        is_indel: variant.is_indel(),
        is_transition: variant.is_transition(),
        is_transversion: variant.is_transversion(),
    })
}

#[rustler::nif]
fn merge_genomic_intervals(
    chroms: Vec<String>,
    starts: Vec<u64>,
    ends: Vec<u64>,
) -> Result<Vec<GenomicIntervalNif>, String> {
    if chroms.len() != starts.len() || chroms.len() != ends.len() {
        return Err("chroms, starts, and ends must have equal length".into());
    }
    let mut intervals = Vec::with_capacity(chroms.len());
    for i in 0..chroms.len() {
        let iv = cyanea_omics::GenomicInterval::new(&chroms[i], starts[i], ends[i])
            .map_err(to_nif_error)?;
        intervals.push(iv);
    }
    let set = cyanea_omics::IntervalSet::from_intervals(intervals);
    let merged = set.merge_overlapping();
    Ok(merged.into_intervals().into_iter().map(GenomicIntervalNif::from).collect())
}

#[rustler::nif]
fn genomic_coverage(
    chroms: Vec<String>,
    starts: Vec<u64>,
    ends: Vec<u64>,
    query_chrom: String,
) -> Result<u64, String> {
    if chroms.len() != starts.len() || chroms.len() != ends.len() {
        return Err("chroms, starts, and ends must have equal length".into());
    }
    let mut intervals = Vec::with_capacity(chroms.len());
    for i in 0..chroms.len() {
        let iv = cyanea_omics::GenomicInterval::new(&chroms[i], starts[i], ends[i])
            .map_err(to_nif_error)?;
        intervals.push(iv);
    }
    let set = cyanea_omics::IntervalSet::from_intervals(intervals);
    Ok(set.coverage(&query_chrom))
}

#[rustler::nif]
fn expression_summary(
    data: Vec<Vec<f64>>,
    feature_names: Vec<String>,
    sample_names: Vec<String>,
) -> Result<ExpressionSummaryNif, String> {
    // Capture names before they're moved into the matrix constructor.
    let feat_names = feature_names.clone();
    let samp_names = sample_names.clone();
    let matrix = cyanea_omics::ExpressionMatrix::new(data, feature_names, sample_names)
        .map_err(to_nif_error)?;
    let (n_features, n_samples) = matrix.shape();
    let feature_means: Vec<f64> = (0..n_features)
        .map(|i| matrix.row_mean(i).unwrap_or(0.0))
        .collect();
    let sample_means: Vec<f64> = (0..n_samples)
        .map(|i| matrix.column_mean(i).unwrap_or(0.0))
        .collect();
    Ok(ExpressionSummaryNif {
        n_features,
        n_samples,
        feature_names: feat_names,
        sample_names: samp_names,
        feature_means,
        sample_means,
    })
}

#[rustler::nif]
fn log_transform_matrix(
    data: Vec<Vec<f64>>,
    pseudocount: f64,
) -> Result<Vec<Vec<f64>>, String> {
    Ok(data
        .iter()
        .map(|row| row.iter().map(|&x| (x + pseudocount).log2()).collect())
        .collect())
}

// ===========================================================================
// cyanea-ml — ML Primitives (planned)
// ===========================================================================
//
// Planned NIFs:
// - embed_sequences(sequences, model) — sequence embeddings (DirtyCpu)
// - cluster(data, method, k) — k-means / DBSCAN clustering

// ===========================================================================
// cyanea-chem — Chemistry / Small Molecules (planned)
// ===========================================================================
//
// Planned NIFs:
// - parse_smiles(smiles) — SMILES string to molecular representation
// - molecular_properties(smiles) — MW, LogP, PSA

// ===========================================================================
// cyanea-struct — 3D Structures (planned)
// ===========================================================================
//
// Planned NIFs:
// - parse_pdb(path) — PDB/mmCIF structure parsing (DirtyCpu)
// - calc_rmsd(structure_a, structure_b) — structural superposition

// ===========================================================================
// cyanea-phylo — Phylogenetics (planned)
// ===========================================================================
//
// Planned NIFs:
// - parse_newick(newick_string) — Newick tree parsing
// - tree_distance(tree_a, tree_b) — Robinson-Foulds distance

// ===========================================================================
// cyanea-gpu — GPU Compute (planned)
// ===========================================================================
//
// Planned NIFs:
// - gpu_available() — check for CUDA/Metal backend
// - gpu_batch_align(sequences, reference) — GPU-accelerated batch alignment
