// ---------------------------------------------------------------------------
// @cyanea/bio -- Typed wrapper around cyanea-wasm WASM bindings
// ---------------------------------------------------------------------------
// Imports the raw WASM functions (which return JSON strings), parses the
// JSON envelope, and exposes a clean, fully typed TypeScript API.
//
// Usage:
//   import init from "../pkg/cyanea_wasm.js";
//   import { Seq, Align, Stats, ML, Chem, StructBio, Phylo, IO, Omics, Core } from "./index.js";
//
//   await init();
//   const stats = Seq.parseFasta(">seq1\nACGT\n");
//   console.log(stats.gc_content);
// ---------------------------------------------------------------------------
// ── Raw WASM imports ───────────────────────────────────────────────────────
// These are the raw wasm-bindgen functions that return JSON strings.
// The import path assumes wasm-pack output in ../pkg/.
// All imports are aliased with a _raw prefix to avoid shadowing by the
// namespace wrapper functions that share similar names.
import { 
// seq
parse_fasta as _raw_parse_fasta, parse_fastq as _raw_parse_fastq, gc_content_json as _raw_gc_content_json, reverse_complement as _raw_reverse_complement, transcribe as _raw_transcribe, translate as _raw_translate, validate as _raw_validate, minhash_sketch as _raw_minhash_sketch, minhash_compare as _raw_minhash_compare, rna_fold_nussinov as _raw_rna_fold_nussinov, rna_fold_zuker as _raw_rna_fold_zuker, protein_props as _raw_protein_props, simulate_reads as _raw_simulate_reads, codon_usage as _raw_codon_usage, assembly_stats_json as _raw_assembly_stats_json, 
// align
align_dna as _raw_align_dna, align_dna_custom as _raw_align_dna_custom, align_protein as _raw_align_protein, align_batch as _raw_align_batch, parse_cigar as _raw_parse_cigar, validate_cigar as _raw_validate_cigar, cigar_stats as _raw_cigar_stats, cigar_to_alignment as _raw_cigar_to_alignment, alignment_to_cigar as _raw_alignment_to_cigar, generate_md_tag as _raw_generate_md_tag, merge_cigar as _raw_merge_cigar, reverse_cigar as _raw_reverse_cigar, collapse_cigar as _raw_collapse_cigar, hard_clip_to_soft as _raw_hard_clip_to_soft, split_cigar as _raw_split_cigar, progressive_msa as _raw_progressive_msa, poa_consensus as _raw_poa_consensus, align_banded as _raw_align_banded, 
// stats
describe as _raw_describe, pearson as _raw_pearson, spearman as _raw_spearman, t_test as _raw_t_test, t_test_two_sample as _raw_t_test_two_sample, mann_whitney_u as _raw_mann_whitney_u, bonferroni as _raw_bonferroni, benjamini_hochberg as _raw_benjamini_hochberg, kaplan_meier as _raw_kaplan_meier, log_rank_test as _raw_log_rank_test, cox_ph as _raw_cox_ph, wright_fisher as _raw_wright_fisher, permutation_test as _raw_permutation_test, bootstrap_ci as _raw_bootstrap_ci, shannon_index as _raw_shannon_index, simpson_index as _raw_simpson_index, bray_curtis as _raw_bray_curtis, fst_hudson as _raw_fst_hudson, tajimas_d as _raw_tajimas_d, 
// ml
kmer_count as _raw_kmer_count, euclidean_distance as _raw_euclidean_distance, manhattan_distance as _raw_manhattan_distance, hamming_distance as _raw_hamming_distance, cosine_similarity as _raw_cosine_similarity, umap as _raw_umap, pca as _raw_pca, tsne as _raw_tsne, kmeans as _raw_kmeans, random_forest_classify as _raw_random_forest_classify, gbdt_regression as _raw_gbdt_regression, gbdt_classify as _raw_gbdt_classify, hmm_viterbi as _raw_hmm_viterbi, hmm_likelihood as _raw_hmm_likelihood, confusion_matrix as _raw_confusion_matrix, roc_curve as _raw_roc_curve, pr_curve as _raw_pr_curve, cross_validate_rf as _raw_cross_validate_rf, feature_importance_variance as _raw_feature_importance_variance, 
// chem
smiles_properties as _raw_smiles_properties, canonical as _raw_canonical, smiles_fingerprint as _raw_smiles_fingerprint, tanimoto as _raw_tanimoto, smiles_substructure as _raw_smiles_substructure, parse_sdf as _raw_parse_sdf, maccs_fingerprint as _raw_maccs_fingerprint, tanimoto_maccs as _raw_tanimoto_maccs, 
// struct_bio
pdb_info as _raw_pdb_info, pdb_secondary_structure as _raw_pdb_secondary_structure, rmsd as _raw_rmsd, contact_map as _raw_contact_map, ramachandran_analysis as _raw_ramachandran_analysis, parse_mmcif as _raw_parse_mmcif, kabsch_align as _raw_kabsch_align, 
// phylo
newick_info as _raw_newick_info, evolutionary_distance as _raw_evolutionary_distance, build_upgma as _raw_build_upgma, build_nj as _raw_build_nj, rf_distance as _raw_rf_distance, parse_nexus as _raw_parse_nexus, write_nexus as _raw_write_nexus, simulate_evolution as _raw_simulate_evolution, simulate_coalescent as _raw_simulate_coalescent, simulate_coalescent_growth as _raw_simulate_coalescent_growth, 
// io
pileup_from_sam as _raw_pileup_from_sam, depth_stats_from_sam as _raw_depth_stats_from_sam, pileup_to_mpileup_text as _raw_pileup_to_mpileup_text, parse_vcf_text as _raw_parse_vcf_text, parse_bed_text as _raw_parse_bed_text, parse_gff3_text as _raw_parse_gff3_text, parse_blast_xml as _raw_parse_blast_xml, parse_bedgraph as _raw_parse_bedgraph, parse_gfa as _raw_parse_gfa, ncbi_fetch_url as _raw_ncbi_fetch_url, 
// omics
merge_intervals as _raw_merge_intervals, intersect_intervals as _raw_intersect_intervals, subtract_intervals as _raw_subtract_intervals, complement_intervals as _raw_complement_intervals, closest_intervals as _raw_closest_intervals, jaccard_intervals as _raw_jaccard_intervals, make_windows as _raw_make_windows, liftover_interval as _raw_liftover_interval, annotate_variant as _raw_annotate_variant, cbs_segment as _raw_cbs_segment, bisulfite_convert as _raw_bisulfite_convert, find_cpg_islands as _raw_find_cpg_islands, morans_i as _raw_morans_i, gearys_c as _raw_gearys_c, 
// core
sha256 as _raw_sha256, } from "./cyanea_wasm.js";
// ── Error type ─────────────────────────────────────────────────────────────
/**
 * Error thrown when a WASM function returns an error envelope.
 * The `message` property contains the error string from the Rust side.
 */
export class CyaneaError extends Error {
    name = "CyaneaError";
    constructor(message) {
        super(message);
    }
}
// ── JSON envelope unwrapper ────────────────────────────────────────────────
/**
 * Parse a JSON envelope string and return the success value, or throw
 * a `CyaneaError` if the envelope contains an error.
 */
function unwrap(json) {
    const parsed = JSON.parse(json);
    if ("error" in parsed) {
        throw new CyaneaError(parsed.error);
    }
    return parsed.ok;
}
// ── Seq ────────────────────────────────────────────────────────────────────
export var Seq;
(function (Seq) {
    function parseFasta(data) {
        return unwrap(_raw_parse_fasta(data));
    }
    Seq.parseFasta = parseFasta;
    function parseFastq(data) {
        return unwrap(_raw_parse_fastq(data));
    }
    Seq.parseFastq = parseFastq;
    function gcContent(seq) {
        return unwrap(_raw_gc_content_json(seq));
    }
    Seq.gcContent = gcContent;
    function reverseComplement(seq) {
        return unwrap(_raw_reverse_complement(seq));
    }
    Seq.reverseComplement = reverseComplement;
    function transcribe(seq) {
        return unwrap(_raw_transcribe(seq));
    }
    Seq.transcribe = transcribe;
    function translate(seq) {
        return unwrap(_raw_translate(seq));
    }
    Seq.translate = translate;
    function validate(seq, alphabet) {
        return unwrap(_raw_validate(seq, alphabet));
    }
    Seq.validate = validate;
    function minhashSketch(seq, k, sketchSize) {
        return unwrap(_raw_minhash_sketch(seq, k, sketchSize));
    }
    Seq.minhashSketch = minhashSketch;
    function minhashCompare(seqA, seqB, k, sketchSize) {
        return unwrap(_raw_minhash_compare(seqA, seqB, k, sketchSize));
    }
    Seq.minhashCompare = minhashCompare;
    /** Predict RNA secondary structure using Nussinov algorithm. */
    function rnaFoldNussinov(seq) {
        return unwrap(_raw_rna_fold_nussinov(seq));
    }
    Seq.rnaFoldNussinov = rnaFoldNussinov;
    /** Predict RNA secondary structure using Zuker MFE algorithm. */
    function rnaFoldZuker(seq) {
        return unwrap(_raw_rna_fold_zuker(seq));
    }
    Seq.rnaFoldZuker = rnaFoldZuker;
    /** Compute protein sequence properties (MW, pI, GRAVY, etc.). */
    function proteinProperties(seq) {
        return unwrap(_raw_protein_props(seq));
    }
    Seq.proteinProperties = proteinProperties;
    /** Simulate sequencing reads from a reference sequence. */
    function simulateReads(refSeq, configJson) {
        return unwrap(_raw_simulate_reads(refSeq, configJson));
    }
    Seq.simulateReads = simulateReads;
    /** Compute codon usage from a coding DNA sequence. */
    function codonUsage(seq) {
        return unwrap(_raw_codon_usage(seq));
    }
    Seq.codonUsage = codonUsage;
    /** Compute assembly statistics for a set of contigs. */
    function assemblyStats(contigsJson) {
        return unwrap(_raw_assembly_stats_json(contigsJson));
    }
    Seq.assemblyStats = assemblyStats;
})(Seq || (Seq = {}));
// ── Align ──────────────────────────────────────────────────────────────────
export var Align;
(function (Align) {
    function alignDna(query, target, mode) {
        return unwrap(_raw_align_dna(query, target, mode));
    }
    Align.alignDna = alignDna;
    function alignDnaCustom(query, target, mode, matchScore, mismatchScore, gapOpen, gapExtend) {
        return unwrap(_raw_align_dna_custom(query, target, mode, matchScore, mismatchScore, gapOpen, gapExtend));
    }
    Align.alignDnaCustom = alignDnaCustom;
    function alignProtein(query, target, mode, matrix) {
        return unwrap(_raw_align_protein(query, target, mode, matrix));
    }
    Align.alignProtein = alignProtein;
    function alignBatch(pairs, mode, matchScore, mismatchScore, gapOpen, gapExtend) {
        return unwrap(_raw_align_batch(JSON.stringify(pairs), mode, matchScore, mismatchScore, gapOpen, gapExtend));
    }
    Align.alignBatch = alignBatch;
    function parseCigar(cigar) {
        return unwrap(_raw_parse_cigar(cigar));
    }
    Align.parseCigar = parseCigar;
    function validateCigar(cigar) {
        return unwrap(_raw_validate_cigar(cigar));
    }
    Align.validateCigar = validateCigar;
    function cigarStats(cigar) {
        return unwrap(_raw_cigar_stats(cigar));
    }
    Align.cigarStats = cigarStats;
    function cigarToAlignment(cigar, query, target) {
        return unwrap(_raw_cigar_to_alignment(cigar, query, target));
    }
    Align.cigarToAlignment = cigarToAlignment;
    function alignmentToCigar(query, target) {
        return unwrap(_raw_alignment_to_cigar(query, target));
    }
    Align.alignmentToCigar = alignmentToCigar;
    function generateMdTag(cigar, query, reference) {
        return unwrap(_raw_generate_md_tag(cigar, query, reference));
    }
    Align.generateMdTag = generateMdTag;
    function mergeCigar(cigar) {
        return unwrap(_raw_merge_cigar(cigar));
    }
    Align.mergeCigar = mergeCigar;
    function reverseCigar(cigar) {
        return unwrap(_raw_reverse_cigar(cigar));
    }
    Align.reverseCigar = reverseCigar;
    function collapseCigar(cigar) {
        return unwrap(_raw_collapse_cigar(cigar));
    }
    Align.collapseCigar = collapseCigar;
    function hardClipToSoft(cigar) {
        return unwrap(_raw_hard_clip_to_soft(cigar));
    }
    Align.hardClipToSoft = hardClipToSoft;
    function splitCigar(cigar, refPos) {
        return unwrap(_raw_split_cigar(cigar, refPos));
    }
    Align.splitCigar = splitCigar;
    /** Progressive multiple sequence alignment. */
    function progressiveMsa(seqsJson, matchScore, mismatchScore, gapOpen, gapExtend) {
        return unwrap(_raw_progressive_msa(seqsJson, matchScore, mismatchScore, gapOpen, gapExtend));
    }
    Align.progressiveMsa = progressiveMsa;
    /** Partial-order alignment consensus. */
    function poaConsensus(seqsJson) {
        return unwrap(_raw_poa_consensus(seqsJson));
    }
    Align.poaConsensus = poaConsensus;
    /** Banded pairwise alignment. */
    function alignBanded(query, target, mode, bandwidth, matchScore, mismatchScore, gapOpen, gapExtend) {
        return unwrap(_raw_align_banded(query, target, mode, bandwidth, matchScore, mismatchScore, gapOpen, gapExtend));
    }
    Align.alignBanded = alignBanded;
})(Align || (Align = {}));
// ── Stats ──────────────────────────────────────────────────────────────────
export var Stats;
(function (Stats) {
    function describe(data) {
        return unwrap(_raw_describe(JSON.stringify(data)));
    }
    Stats.describe = describe;
    function pearson(x, y) {
        return unwrap(_raw_pearson(JSON.stringify(x), JSON.stringify(y)));
    }
    Stats.pearson = pearson;
    function spearman(x, y) {
        return unwrap(_raw_spearman(JSON.stringify(x), JSON.stringify(y)));
    }
    Stats.spearman = spearman;
    function tTest(data, mu) {
        return unwrap(_raw_t_test(JSON.stringify(data), mu));
    }
    Stats.tTest = tTest;
    function tTestTwoSample(x, y, equalVar) {
        return unwrap(_raw_t_test_two_sample(JSON.stringify(x), JSON.stringify(y), equalVar));
    }
    Stats.tTestTwoSample = tTestTwoSample;
    function mannWhitneyU(x, y) {
        return unwrap(_raw_mann_whitney_u(JSON.stringify(x), JSON.stringify(y)));
    }
    Stats.mannWhitneyU = mannWhitneyU;
    function bonferroni(pValues) {
        return unwrap(_raw_bonferroni(JSON.stringify(pValues)));
    }
    Stats.bonferroni = bonferroni;
    function benjaminiHochberg(pValues) {
        return unwrap(_raw_benjamini_hochberg(JSON.stringify(pValues)));
    }
    Stats.benjaminiHochberg = benjaminiHochberg;
    /** Kaplan-Meier survival analysis. */
    function kaplanMeier(timesJson, statusJson) {
        return unwrap(_raw_kaplan_meier(timesJson, statusJson));
    }
    Stats.kaplanMeier = kaplanMeier;
    /** Log-rank test comparing two survival curves. */
    function logRankTest(t1Json, s1Json, t2Json, s2Json) {
        return unwrap(_raw_log_rank_test(t1Json, s1Json, t2Json, s2Json));
    }
    Stats.logRankTest = logRankTest;
    /** Cox proportional hazards model. */
    function coxPh(timesJson, statusJson, covariatesJson, nCovariates) {
        return unwrap(_raw_cox_ph(timesJson, statusJson, covariatesJson, nCovariates));
    }
    Stats.coxPh = coxPh;
    /** Wright-Fisher population simulation. */
    function wrightFisher(popSize, initFreq, nGens, seed) {
        return unwrap(_raw_wright_fisher(popSize, initFreq, nGens, seed));
    }
    Stats.wrightFisher = wrightFisher;
    /** Permutation test for group differences. */
    function permutationTest(valuesJson, groupSizesJson, nPerms, seed) {
        return unwrap(_raw_permutation_test(valuesJson, groupSizesJson, nPerms, seed));
    }
    Stats.permutationTest = permutationTest;
    /** Bootstrap confidence interval. */
    function bootstrapCi(dataJson, nBootstrap, seed) {
        return unwrap(_raw_bootstrap_ci(dataJson, nBootstrap, seed));
    }
    Stats.bootstrapCi = bootstrapCi;
    /** Shannon diversity index. */
    function shannonIndex(countsJson) {
        return unwrap(_raw_shannon_index(countsJson));
    }
    Stats.shannonIndex = shannonIndex;
    /** Simpson diversity index. */
    function simpsonIndex(countsJson) {
        return unwrap(_raw_simpson_index(countsJson));
    }
    Stats.simpsonIndex = simpsonIndex;
    /** Bray-Curtis dissimilarity. */
    function brayCurtis(aJson, bJson) {
        return unwrap(_raw_bray_curtis(aJson, bJson));
    }
    Stats.brayCurtis = brayCurtis;
    /** Hudson's Fst estimator. */
    function fstHudson(pop1Json, pop2Json) {
        return unwrap(_raw_fst_hudson(pop1Json, pop2Json));
    }
    Stats.fstHudson = fstHudson;
    /** Tajima's D neutrality test. */
    function tajimasD(genotypesJson) {
        return unwrap(_raw_tajimas_d(genotypesJson));
    }
    Stats.tajimasD = tajimasD;
})(Stats || (Stats = {}));
// ── ML ─────────────────────────────────────────────────────────────────────
export var ML;
(function (ML) {
    function kmerCount(seq, k) {
        return unwrap(_raw_kmer_count(seq, k));
    }
    ML.kmerCount = kmerCount;
    function euclideanDistance(a, b) {
        return unwrap(_raw_euclidean_distance(JSON.stringify(a), JSON.stringify(b)));
    }
    ML.euclideanDistance = euclideanDistance;
    function manhattanDistance(a, b) {
        return unwrap(_raw_manhattan_distance(JSON.stringify(a), JSON.stringify(b)));
    }
    ML.manhattanDistance = manhattanDistance;
    function hammingDistance(a, b) {
        return unwrap(_raw_hamming_distance(a, b));
    }
    ML.hammingDistance = hammingDistance;
    function cosineSimilarity(a, b) {
        return unwrap(_raw_cosine_similarity(JSON.stringify(a), JSON.stringify(b)));
    }
    ML.cosineSimilarity = cosineSimilarity;
    function umap(data, nFeatures, nComponents, nNeighbors, minDist, nEpochs, metric) {
        return unwrap(_raw_umap(JSON.stringify(data), nFeatures, nComponents, nNeighbors, minDist, nEpochs, metric));
    }
    ML.umap = umap;
    function pca(data, nFeatures, nComponents) {
        return unwrap(_raw_pca(JSON.stringify(data), nFeatures, nComponents));
    }
    ML.pca = pca;
    function tsne(data, nFeatures, nComponents, perplexity, learningRate, nIter, seed) {
        return unwrap(_raw_tsne(JSON.stringify(data), nFeatures, nComponents, perplexity, learningRate, nIter, seed));
    }
    ML.tsne = tsne;
    function kmeans(data, nFeatures, nClusters, maxIter, seed) {
        return unwrap(_raw_kmeans(JSON.stringify(data), nFeatures, nClusters, maxIter, seed));
    }
    ML.kmeans = kmeans;
    /** Random forest classification. */
    function randomForestClassify(dataJson, nFeatures, labelsJson, configJson) {
        return unwrap(_raw_random_forest_classify(dataJson, nFeatures, labelsJson, configJson));
    }
    ML.randomForestClassify = randomForestClassify;
    /** Gradient-boosted tree regression. */
    function gbdtRegression(dataJson, nFeatures, targetsJson, configJson) {
        return unwrap(_raw_gbdt_regression(dataJson, nFeatures, targetsJson, configJson));
    }
    ML.gbdtRegression = gbdtRegression;
    /** Gradient-boosted tree classification. */
    function gbdtClassify(dataJson, nFeatures, labelsJson, configJson) {
        return unwrap(_raw_gbdt_classify(dataJson, nFeatures, labelsJson, configJson));
    }
    ML.gbdtClassify = gbdtClassify;
    /** HMM Viterbi decoding. */
    function hmmViterbi(nStates, nSymbols, initJson, transJson, emissJson, obsJson) {
        return unwrap(_raw_hmm_viterbi(nStates, nSymbols, initJson, transJson, emissJson, obsJson));
    }
    ML.hmmViterbi = hmmViterbi;
    /** HMM log-likelihood. */
    function hmmLikelihood(nStates, nSymbols, initJson, transJson, emissJson, obsJson) {
        return unwrap(_raw_hmm_likelihood(nStates, nSymbols, initJson, transJson, emissJson, obsJson));
    }
    ML.hmmLikelihood = hmmLikelihood;
    /** Confusion matrix from actual and predicted labels. */
    function confusionMatrix(actualJson, predictedJson) {
        return unwrap(_raw_confusion_matrix(actualJson, predictedJson));
    }
    ML.confusionMatrix = confusionMatrix;
    /** ROC curve from scores and binary labels. */
    function rocCurve(scoresJson, labelsJson) {
        return unwrap(_raw_roc_curve(scoresJson, labelsJson));
    }
    ML.rocCurve = rocCurve;
    /** Precision-recall curve from scores and binary labels. */
    function prCurve(scoresJson, labelsJson) {
        return unwrap(_raw_pr_curve(scoresJson, labelsJson));
    }
    ML.prCurve = prCurve;
    /** K-fold cross-validation with random forest. */
    function crossValidateRf(dataJson, nFeatures, labelsJson, k, seed) {
        return unwrap(_raw_cross_validate_rf(dataJson, nFeatures, labelsJson, k, seed));
    }
    ML.crossValidateRf = crossValidateRf;
    /** Variance-threshold feature selection. */
    function featureImportanceVariance(dataJson, nFeatures, threshold) {
        return unwrap(_raw_feature_importance_variance(dataJson, nFeatures, threshold));
    }
    ML.featureImportanceVariance = featureImportanceVariance;
})(ML || (ML = {}));
// ── Chem ───────────────────────────────────────────────────────────────────
export var Chem;
(function (Chem) {
    function properties(smiles) {
        return unwrap(_raw_smiles_properties(smiles));
    }
    Chem.properties = properties;
    function canonical(smiles) {
        return unwrap(_raw_canonical(smiles));
    }
    Chem.canonical = canonical;
    function fingerprint(smiles, radius, nBits) {
        return unwrap(_raw_smiles_fingerprint(smiles, radius, nBits));
    }
    Chem.fingerprint = fingerprint;
    function tanimoto(smiles1, smiles2) {
        return unwrap(_raw_tanimoto(smiles1, smiles2));
    }
    Chem.tanimoto = tanimoto;
    function substructure(molecule, pattern) {
        return unwrap(_raw_smiles_substructure(molecule, pattern));
    }
    Chem.substructure = substructure;
    /** Parse SDF V2000/V3000 text and return molecules. */
    function parseSdf(sdfText) {
        return unwrap(_raw_parse_sdf(sdfText));
    }
    Chem.parseSdf = parseSdf;
    /** Compute MACCS 166-key fingerprint. */
    function maccsFingerprint(smiles) {
        return unwrap(_raw_maccs_fingerprint(smiles));
    }
    Chem.maccsFingerprint = maccsFingerprint;
    /** Tanimoto similarity using MACCS fingerprints. */
    function tanimotoMaccs(smiles1, smiles2) {
        return unwrap(_raw_tanimoto_maccs(smiles1, smiles2));
    }
    Chem.tanimotoMaccs = tanimotoMaccs;
})(Chem || (Chem = {}));
// ── StructBio ──────────────────────────────────────────────────────────────
export var StructBio;
(function (StructBio) {
    function pdbInfo(pdbText) {
        return unwrap(_raw_pdb_info(pdbText));
    }
    StructBio.pdbInfo = pdbInfo;
    function secondaryStructure(pdbText) {
        return unwrap(_raw_pdb_secondary_structure(pdbText));
    }
    StructBio.secondaryStructure = secondaryStructure;
    function rmsd(coords1, coords2) {
        return unwrap(_raw_rmsd(JSON.stringify(coords1), JSON.stringify(coords2)));
    }
    StructBio.rmsd = rmsd;
    /** Compute CA-CA contact map from PDB text. */
    function contactMap(pdbText, cutoff) {
        return unwrap(_raw_contact_map(pdbText, cutoff));
    }
    StructBio.contactMap = contactMap;
    /** Ramachandran analysis from PDB text. */
    function ramachandran(pdbText) {
        return unwrap(_raw_ramachandran_analysis(pdbText));
    }
    StructBio.ramachandran = ramachandran;
    /** Parse mmCIF text and return structure info. */
    function parseMmcif(text) {
        return unwrap(_raw_parse_mmcif(text));
    }
    StructBio.parseMmcif = parseMmcif;
    /** Kabsch superposition on two coordinate sets. */
    function kabschAlign(coords1Json, coords2Json) {
        return unwrap(_raw_kabsch_align(coords1Json, coords2Json));
    }
    StructBio.kabschAlign = kabschAlign;
})(StructBio || (StructBio = {}));
// ── Phylo ──────────────────────────────────────────────────────────────────
export var Phylo;
(function (Phylo) {
    function newickInfo(newick) {
        return unwrap(_raw_newick_info(newick));
    }
    Phylo.newickInfo = newickInfo;
    function evolutionaryDistance(seq1, seq2, model) {
        return unwrap(_raw_evolutionary_distance(seq1, seq2, model));
    }
    Phylo.evolutionaryDistance = evolutionaryDistance;
    function buildUpgma(labels, matrix) {
        return unwrap(_raw_build_upgma(JSON.stringify(labels), JSON.stringify(matrix)));
    }
    Phylo.buildUpgma = buildUpgma;
    function buildNj(labels, matrix) {
        return unwrap(_raw_build_nj(JSON.stringify(labels), JSON.stringify(matrix)));
    }
    Phylo.buildNj = buildNj;
    function rfDistance(newick1, newick2) {
        return unwrap(_raw_rf_distance(newick1, newick2));
    }
    Phylo.rfDistance = rfDistance;
    /** Parse NEXUS format text. */
    function parseNexus(text) {
        return unwrap(_raw_parse_nexus(text));
    }
    Phylo.parseNexus = parseNexus;
    /** Write NEXUS format from taxa and trees. */
    function writeNexus(taxaJson, treesJson) {
        return unwrap(_raw_write_nexus(taxaJson, treesJson));
    }
    Phylo.writeNexus = writeNexus;
    /** Simulate sequence evolution along a phylogenetic tree. */
    function simulateEvolution(newick, seqLength, model, seed) {
        return unwrap(_raw_simulate_evolution(newick, seqLength, model, seed));
    }
    Phylo.simulateEvolution = simulateEvolution;
    /** Simulate a coalescent tree. */
    function simulateCoalescent(nSamples, popSize, seed) {
        return unwrap(_raw_simulate_coalescent(nSamples, popSize, seed));
    }
    Phylo.simulateCoalescent = simulateCoalescent;
    /** Simulate a coalescent tree with exponential growth. */
    function simulateCoalescentGrowth(nSamples, popSize, growthRate, seed) {
        return unwrap(_raw_simulate_coalescent_growth(nSamples, popSize, growthRate, seed));
    }
    Phylo.simulateCoalescentGrowth = simulateCoalescentGrowth;
})(Phylo || (Phylo = {}));
// ── IO ─────────────────────────────────────────────────────────────────
export var IO;
(function (IO) {
    function pileup(samText) {
        return unwrap(_raw_pileup_from_sam(samText));
    }
    IO.pileup = pileup;
    function depthStats(samText) {
        return unwrap(_raw_depth_stats_from_sam(samText));
    }
    IO.depthStats = depthStats;
    function mpileup(samText) {
        return unwrap(_raw_pileup_to_mpileup_text(samText));
    }
    IO.mpileup = mpileup;
    /** Parse VCF text. */
    function parseVcf(text) {
        return unwrap(_raw_parse_vcf_text(text));
    }
    IO.parseVcf = parseVcf;
    /** Parse BED text. */
    function parseBed(text) {
        return unwrap(_raw_parse_bed_text(text));
    }
    IO.parseBed = parseBed;
    /** Parse GFF3 text. */
    function parseGff3(text) {
        return unwrap(_raw_parse_gff3_text(text));
    }
    IO.parseGff3 = parseGff3;
    /** Parse BLAST XML text. */
    function parseBlastXml(xml) {
        return unwrap(_raw_parse_blast_xml(xml));
    }
    IO.parseBlastXml = parseBlastXml;
    /** Parse bedGraph text. */
    function parseBedgraph(text) {
        return unwrap(_raw_parse_bedgraph(text));
    }
    IO.parseBedgraph = parseBedgraph;
    /** Parse GFA assembly graph text. */
    function parseGfa(text) {
        return unwrap(_raw_parse_gfa(text));
    }
    IO.parseGfa = parseGfa;
    /** Build an NCBI E-utilities fetch URL. */
    function ncbiFetchUrl(db, ids, rettype) {
        return unwrap(_raw_ncbi_fetch_url(db, ids, rettype));
    }
    IO.ncbiFetchUrl = ncbiFetchUrl;
})(IO || (IO = {}));
// ── Omics ──────────────────────────────────────────────────────────────────
export var Omics;
(function (Omics) {
    /** Merge overlapping/adjacent intervals. */
    function mergeIntervals(intervalsJson) {
        return unwrap(_raw_merge_intervals(intervalsJson));
    }
    Omics.mergeIntervals = mergeIntervals;
    /** Intersect two interval sets. */
    function intersectIntervals(aJson, bJson) {
        return unwrap(_raw_intersect_intervals(aJson, bJson));
    }
    Omics.intersectIntervals = intersectIntervals;
    /** Subtract interval set B from A. */
    function subtractIntervals(aJson, bJson) {
        return unwrap(_raw_subtract_intervals(aJson, bJson));
    }
    Omics.subtractIntervals = subtractIntervals;
    /** Complement intervals relative to genome. */
    function complementIntervals(intervalsJson, genomeJson) {
        return unwrap(_raw_complement_intervals(intervalsJson, genomeJson));
    }
    Omics.complementIntervals = complementIntervals;
    /** Find closest intervals. */
    function closestIntervals(aJson, bJson) {
        return unwrap(_raw_closest_intervals(aJson, bJson));
    }
    Omics.closestIntervals = closestIntervals;
    /** Jaccard similarity between interval sets. */
    function jaccardIntervals(aJson, bJson) {
        return unwrap(_raw_jaccard_intervals(aJson, bJson));
    }
    Omics.jaccardIntervals = jaccardIntervals;
    /** Generate genomic windows. */
    function makeWindows(genomeJson, windowSize) {
        return unwrap(_raw_make_windows(genomeJson, windowSize));
    }
    Omics.makeWindows = makeWindows;
    /** Liftover a genomic interval using chain file. */
    function liftoverInterval(chainText, chrom, start, end) {
        return unwrap(_raw_liftover_interval(chainText, chrom, start, end));
    }
    Omics.liftoverInterval = liftoverInterval;
    /** Annotate a variant against gene definitions. */
    function annotateVariant(variantJson, genesJson) {
        return unwrap(_raw_annotate_variant(variantJson, genesJson));
    }
    Omics.annotateVariant = annotateVariant;
    /** Circular binary segmentation for CNV detection. */
    function cbsSegment(positionsJson, valuesJson, chrom, configJson) {
        return unwrap(_raw_cbs_segment(positionsJson, valuesJson, chrom, configJson));
    }
    Omics.cbsSegment = cbsSegment;
    /** Bisulfite convert a DNA sequence. */
    function bisulfiteConvert(seq, methylatedJson) {
        return unwrap(_raw_bisulfite_convert(seq, methylatedJson));
    }
    Omics.bisulfiteConvert = bisulfiteConvert;
    /** Find CpG islands in a DNA sequence. */
    function findCpgIslands(seq, chrom) {
        return unwrap(_raw_find_cpg_islands(seq, chrom));
    }
    Omics.findCpgIslands = findCpgIslands;
    /** Moran's I spatial autocorrelation. */
    function moransI(valuesJson, neighborsJson) {
        return unwrap(_raw_morans_i(valuesJson, neighborsJson));
    }
    Omics.moransI = moransI;
    /** Geary's C spatial autocorrelation. */
    function gearysC(valuesJson, neighborsJson) {
        return unwrap(_raw_gearys_c(valuesJson, neighborsJson));
    }
    Omics.gearysC = gearysC;
})(Omics || (Omics = {}));
// ── Core Utilities ─────────────────────────────────────────────────────────
export var Core;
(function (Core) {
    function sha256(data) {
        return unwrap(_raw_sha256(data));
    }
    Core.sha256 = sha256;
})(Core || (Core = {}));
//# sourceMappingURL=index.js.map