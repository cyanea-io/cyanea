/* @ts-self-types="./cyanea_wasm.d.ts" */

/**
 * Perform banded alignment between two sequences.
 *
 * `mode` is `"global"`, `"local"`, or `"semiglobal"`.
 * `bandwidth` controls the diagonal band width (actual band is `2 * bandwidth + 1`).
 * Returns a JSON `AlignmentResult`.
 * @param {string} query
 * @param {string} target
 * @param {string} mode
 * @param {number} bandwidth
 * @param {number} match_score
 * @param {number} mismatch_score
 * @param {number} gap_open
 * @param {number} gap_extend
 * @returns {string}
 */
export function align_banded(query, target, mode, bandwidth, match_score, mismatch_score, gap_open, gap_extend) {
    let deferred4_0;
    let deferred4_1;
    try {
        const ptr0 = passStringToWasm0(query, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(target, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(mode, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ret = wasm.align_banded(ptr0, len0, ptr1, len1, ptr2, len2, bandwidth, match_score, mismatch_score, gap_open, gap_extend);
        deferred4_0 = ret[0];
        deferred4_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred4_0, deferred4_1, 1);
    }
}

/**
 * Batch-align multiple sequence pairs with custom scoring.
 *
 * `pairs_json` is a JSON array of `{"query": "...", "target": "..."}` objects.
 * `mode` is `"local"`, `"global"`, or `"semiglobal"`.
 * @param {string} pairs_json
 * @param {string} mode
 * @param {number} match_score
 * @param {number} mismatch_score
 * @param {number} gap_open
 * @param {number} gap_extend
 * @returns {string}
 */
export function align_batch(pairs_json, mode, match_score, mismatch_score, gap_open, gap_extend) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(pairs_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(mode, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.align_batch(ptr0, len0, ptr1, len1, match_score, mismatch_score, gap_open, gap_extend);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * Align two DNA sequences with default scoring (+2/-1/-5/-2).
 *
 * `mode` is `"local"`, `"global"`, or `"semiglobal"`. Returns JSON `AlignmentResult`.
 * @param {string} query
 * @param {string} target
 * @param {string} mode
 * @returns {string}
 */
export function align_dna(query, target, mode) {
    let deferred4_0;
    let deferred4_1;
    try {
        const ptr0 = passStringToWasm0(query, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(target, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(mode, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ret = wasm.align_dna(ptr0, len0, ptr1, len1, ptr2, len2);
        deferred4_0 = ret[0];
        deferred4_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred4_0, deferred4_1, 1);
    }
}

/**
 * Align two DNA sequences with custom scoring parameters.
 * @param {string} query
 * @param {string} target
 * @param {string} mode
 * @param {number} match_score
 * @param {number} mismatch_score
 * @param {number} gap_open
 * @param {number} gap_extend
 * @returns {string}
 */
export function align_dna_custom(query, target, mode, match_score, mismatch_score, gap_open, gap_extend) {
    let deferred4_0;
    let deferred4_1;
    try {
        const ptr0 = passStringToWasm0(query, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(target, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(mode, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ret = wasm.align_dna_custom(ptr0, len0, ptr1, len1, ptr2, len2, match_score, mismatch_score, gap_open, gap_extend);
        deferred4_0 = ret[0];
        deferred4_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred4_0, deferred4_1, 1);
    }
}

/**
 * Align two protein sequences using a named substitution matrix.
 *
 * `matrix` is one of `"blosum62"`, `"blosum45"`, `"blosum80"`, `"pam250"`.
 * @param {string} query
 * @param {string} target
 * @param {string} mode
 * @param {string} matrix
 * @returns {string}
 */
export function align_protein(query, target, mode, matrix) {
    let deferred5_0;
    let deferred5_1;
    try {
        const ptr0 = passStringToWasm0(query, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(target, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(mode, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ptr3 = passStringToWasm0(matrix, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len3 = WASM_VECTOR_LEN;
        const ret = wasm.align_protein(ptr0, len0, ptr1, len1, ptr2, len2, ptr3, len3);
        deferred5_0 = ret[0];
        deferred5_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred5_0, deferred5_1, 1);
    }
}

/**
 * Extract CIGAR from a gapped alignment (using =/X distinction).
 *
 * Both `query` and `target` must be gapped strings (same length, `-` for gaps).
 * Returns a CIGAR string.
 * @param {string} query
 * @param {string} target
 * @returns {string}
 */
export function alignment_to_cigar(query, target) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(query, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(target, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.alignment_to_cigar(ptr0, len0, ptr1, len1);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * Annotate a variant against a set of genes.
 *
 * `variant_json`: `{chrom, position, ref_allele, alt_alleles}`.
 *   Position is 1-based (VCF convention).
 *   `ref_allele` and `alt_alleles` are strings (e.g., `"A"` and `["T"]`).
 * `genes_json`: array of gene objects (see parse_genes for format).
 * Output: JSON array of `JsVariantEffect`.
 * @param {string} variant_json
 * @param {string} genes_json
 * @returns {string}
 */
export function annotate_variant(variant_json, genes_json) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(variant_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(genes_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.annotate_variant(ptr0, len0, ptr1, len1);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * Apply a SMIRKS reaction to a molecule.
 * @param {string} smiles
 * @param {string} smirks
 * @returns {string}
 */
export function apply_reaction_js(smiles, smirks) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(smiles, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(smirks, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.apply_reaction_js(ptr0, len0, ptr1, len1);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * Compute assembly statistics from a set of contigs.
 *
 * `contigs_json`: JSON array of contig sequences (strings).
 * Returns JSON with n_contigs, total_length, N50, L50, N90, L90, GC content, etc.
 * @param {string} contigs_json
 * @returns {string}
 */
export function assembly_stats_json(contigs_json) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(contigs_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.assembly_stats_json(ptr0, len0);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Compute atom-atom mapping between two SMILES strings.
 * @param {string} smiles1
 * @param {string} smiles2
 * @returns {string}
 */
export function atom_atom_mapping(smiles1, smiles2) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(smiles1, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(smiles2, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.atom_atom_mapping(ptr0, len0, ptr1, len1);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * Benjamini-Hochberg FDR correction on a JSON array of p-values.
 * @param {string} p_json
 * @returns {string}
 */
export function benjamini_hochberg(p_json) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(p_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.benjamini_hochberg(ptr0, len0);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Simulate bisulfite conversion of a DNA sequence.
 *
 * `seq`: DNA sequence string.
 * `methylated_json`: JSON array of 0-based positions that are methylated.
 * Output: JSON string of the converted sequence.
 * @param {string} seq
 * @param {string} methylated_json
 * @returns {string}
 */
export function bisulfite_convert(seq, methylated_json) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(seq, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(methylated_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.bisulfite_convert(ptr0, len0, ptr1, len1);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * Bonferroni p-value correction on a JSON array of p-values.
 * @param {string} p_json
 * @returns {string}
 */
export function bonferroni(p_json) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(p_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.bonferroni(ptr0, len0);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Bootstrap confidence interval: generates a null distribution of means
 * via bootstrap resampling.
 *
 * Input: data as a JSON array.
 * Output: JSON array of bootstrap statistic values.
 * @param {string} data_json
 * @param {number} n_bootstrap
 * @param {bigint} seed
 * @returns {string}
 */
export function bootstrap_ci(data_json, n_bootstrap, seed) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(data_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.bootstrap_ci(ptr0, len0, n_bootstrap, seed);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Bray-Curtis dissimilarity between two samples (JSON arrays of counts).
 *
 * Output: JSON f64 value (0 = identical, 1 = completely different).
 * @param {string} a_json
 * @param {string} b_json
 * @returns {string}
 */
export function bray_curtis(a_json, b_json) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(a_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(b_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.bray_curtis(ptr0, len0, ptr1, len1);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * Build a Neighbor-Joining tree from a distance matrix.
 *
 * `labels_json`: JSON array of strings. `matrix_json`: JSON 2D array of f64.
 * @param {string} labels_json
 * @param {string} matrix_json
 * @returns {string}
 */
export function build_nj(labels_json, matrix_json) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(labels_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(matrix_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.build_nj(ptr0, len0, ptr1, len1);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * Build a UPGMA tree from a distance matrix.
 *
 * `labels_json`: JSON array of strings. `matrix_json`: JSON 2D array of f64.
 * @param {string} labels_json
 * @param {string} matrix_json
 * @returns {string}
 */
export function build_upgma(labels_json, matrix_json) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(labels_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(matrix_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.build_upgma(ptr0, len0, ptr1, len1);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * Generate canonical SMILES from an input SMILES string.
 * @param {string} smiles
 * @returns {string}
 */
export function canonical(smiles) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(smiles, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.canonical(ptr0, len0);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Segment a log2 ratio profile using Circular Binary Segmentation.
 *
 * `positions_json`: JSON array of u64 positions.
 * `values_json`: JSON array of f64 log2 ratio values.
 * `chrom`: chromosome name.
 * `alpha`: significance threshold (e.g., 0.01).
 * `min_probes`: minimum probes per segment (e.g., 3).
 * Output: JSON array of `JsCnvSegment`.
 * @param {string} positions_json
 * @param {string} values_json
 * @param {string} chrom
 * @param {number} alpha
 * @param {number} min_probes
 * @returns {string}
 */
export function cbs_segment(positions_json, values_json, chrom, alpha, min_probes) {
    let deferred4_0;
    let deferred4_1;
    try {
        const ptr0 = passStringToWasm0(positions_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(values_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(chrom, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ret = wasm.cbs_segment(ptr0, len0, ptr1, len1, ptr2, len2, alpha, min_probes);
        deferred4_0 = ret[0];
        deferred4_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred4_0, deferred4_1, 1);
    }
}

/**
 * Compute statistics from a CIGAR string.
 *
 * Returns a JSON object with reference/query consumed, alignment columns,
 * identity, gap counts, and clipping totals.
 * @param {string} cigar
 * @returns {string}
 */
export function cigar_stats(cigar) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(cigar, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.cigar_stats(ptr0, len0);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Reconstruct gapped alignment from CIGAR + ungapped sequences.
 *
 * Returns `{"ok": {"aligned_query": [...], "aligned_target": [...]}}`.
 * @param {string} cigar
 * @param {string} query
 * @param {string} target
 * @returns {string}
 */
export function cigar_to_alignment(cigar, query, target) {
    let deferred4_0;
    let deferred4_1;
    try {
        const ptr0 = passStringToWasm0(cigar, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(query, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(target, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ret = wasm.cigar_to_alignment(ptr0, len0, ptr1, len1, ptr2, len2);
        deferred4_0 = ret[0];
        deferred4_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred4_0, deferred4_1, 1);
    }
}

/**
 * Find the closest interval in `b` for each interval in `a`.
 *
 * Input: two JSON arrays of `{chrom, start, end}`.
 * Output: JSON array of `JsClosestResult`.
 * @param {string} a_json
 * @param {string} b_json
 * @returns {string}
 */
export function closest_intervals(a_json, b_json) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(a_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(b_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.closest_intervals(ptr0, len0, ptr1, len1);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * Compute codon usage from a coding DNA sequence.
 *
 * The sequence should be in-frame coding DNA. Returns JSON with codon counts and total.
 * @param {string} seq
 * @returns {string}
 */
export function codon_usage(seq) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(seq, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.codon_usage(ptr0, len0);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Collapse =/X operations into M (alignment match).
 *
 * Returns the collapsed CIGAR string.
 * @param {string} cigar
 * @returns {string}
 */
export function collapse_cigar(cigar) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(cigar, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.collapse_cigar(ptr0, len0);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Complement of intervals with respect to a genome.
 *
 * `json`: JSON array of `{chrom, start, end}`.
 * `genome_json`: JSON array of `{chrom, length}`.
 * Output: JSON array of `JsGenomicInterval`.
 * @param {string} json
 * @param {string} genome_json
 * @returns {string}
 */
export function complement_intervals(json, genome_json) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(genome_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.complement_intervals(ptr0, len0, ptr1, len1);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * Compute a confusion matrix from actual and predicted labels.
 *
 * `actual_json`: JSON array of actual class labels (usize).
 * `predicted_json`: JSON array of predicted class labels (usize).
 * @param {string} actual_json
 * @param {string} predicted_json
 * @returns {string}
 */
export function confusion_matrix(actual_json, predicted_json) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(actual_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(predicted_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.confusion_matrix(ptr0, len0, ptr1, len1);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * Compute a CA-CA contact map from PDB text and return contacts below cutoff as JSON.
 * @param {string} pdb_text
 * @param {number} cutoff
 * @returns {string}
 */
export function contact_map(pdb_text, cutoff) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(pdb_text, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.contact_map(ptr0, len0, cutoff);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Cosine similarity between two JSON arrays of numbers.
 * @param {string} a_json
 * @param {string} b_json
 * @returns {string}
 */
export function cosine_similarity(a_json, b_json) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(a_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(b_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.cosine_similarity(ptr0, len0, ptr1, len1);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * Cox proportional hazards regression.
 *
 * Input: times, status, and flattened covariate matrix as JSON arrays.
 * Output: JSON `JsCoxPhResult`.
 * @param {string} times_json
 * @param {string} status_json
 * @param {string} covariates_json
 * @param {number} n_covariates
 * @returns {string}
 */
export function cox_ph(times_json, status_json, covariates_json, n_covariates) {
    let deferred4_0;
    let deferred4_1;
    try {
        const ptr0 = passStringToWasm0(times_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(status_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(covariates_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ret = wasm.cox_ph(ptr0, len0, ptr1, len1, ptr2, len2, n_covariates);
        deferred4_0 = ret[0];
        deferred4_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred4_0, deferred4_1, 1);
    }
}

/**
 * K-fold cross-validation with a random forest classifier.
 *
 * `data_json`: JSON array of numbers (flat row-major matrix).
 * `n_features`: number of features per sample.
 * `labels_json`: JSON array of class labels (usize).
 * `k`: number of folds.
 * `seed`: random seed.
 * @param {string} data_json
 * @param {number} n_features
 * @param {string} labels_json
 * @param {number} k
 * @param {bigint} seed
 * @returns {string}
 */
export function cross_validate_rf(data_json, n_features, labels_json, k, seed) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(data_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(labels_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.cross_validate_rf(ptr0, len0, n_features, ptr1, len1, k, seed);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * Compute depth statistics from SAM text.
 *
 * Parses SAM-formatted text and returns per-reference depth statistics.
 * @param {string} sam_text
 * @returns {string}
 */
export function depth_stats_from_sam(sam_text) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(sam_text, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.depth_stats_from_sam(ptr0, len0);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Compute descriptive statistics from a JSON array of numbers.
 *
 * Input: `"[1.0, 2.0, 3.0]"` — Output: JSON `JsDescriptiveStats`.
 * @param {string} data_json
 * @returns {string}
 */
export function describe(data_json) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(data_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.describe(ptr0, len0);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Embed a single 3D conformer from SMILES.
 * @param {string} smiles
 * @param {bigint} seed
 * @param {boolean} use_torsion_prefs
 * @param {number} max_minimize_steps
 * @returns {string}
 */
export function embed_conformer(smiles, seed, use_torsion_prefs, max_minimize_steps) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(smiles, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.embed_conformer(ptr0, len0, seed, use_torsion_prefs, max_minimize_steps);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Embed multiple 3D conformers from SMILES with RMSD pruning.
 * @param {string} smiles
 * @param {number} max_conformers
 * @param {number} rmsd_threshold
 * @param {bigint} seed
 * @returns {string}
 */
export function embed_conformers(smiles, max_conformers, rmsd_threshold, seed) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(smiles, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.embed_conformers(ptr0, len0, max_conformers, rmsd_threshold, seed);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Euclidean distance between two JSON arrays of numbers.
 * @param {string} a_json
 * @param {string} b_json
 * @returns {string}
 */
export function euclidean_distance(a_json, b_json) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(a_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(b_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.euclidean_distance(ptr0, len0, ptr1, len1);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * Compute evolutionary distance between two sequences.
 *
 * `model` is one of `"p"`, `"jc"`, or `"k2p"`.
 * @param {string} seq1
 * @param {string} seq2
 * @param {string} model
 * @returns {string}
 */
export function evolutionary_distance(seq1, seq2, model) {
    let deferred4_0;
    let deferred4_1;
    try {
        const ptr0 = passStringToWasm0(seq1, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(seq2, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(model, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ret = wasm.evolutionary_distance(ptr0, len0, ptr1, len1, ptr2, len2);
        deferred4_0 = ret[0];
        deferred4_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred4_0, deferred4_1, 1);
    }
}

/**
 * Feature selection via variance threshold.
 *
 * `data_json`: JSON array of numbers (flat row-major matrix).
 * `n_features`: number of features per sample.
 * `threshold`: minimum variance (features with variance > threshold are kept).
 * @param {string} data_json
 * @param {number} n_features
 * @param {number} threshold
 * @returns {string}
 */
export function feature_importance_variance(data_json, n_features, threshold) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(data_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.feature_importance_variance(ptr0, len0, n_features, threshold);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Find CpG islands in a DNA sequence.
 *
 * `seq`: DNA sequence string.
 * `chrom`: chromosome name.
 * Output: JSON array of `JsCpgIsland`.
 * @param {string} seq
 * @param {string} chrom
 * @returns {string}
 */
export function find_cpg_islands(seq, chrom) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(seq, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(chrom, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.find_cpg_islands(ptr0, len0, ptr1, len1);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * Hudson's Fst estimator between two populations.
 *
 * Input: two JSON arrays of genotype matrices, each `Vec<Vec<Option<u8>>>`.
 * Each inner Vec is the genotype vector for one locus.
 * Output: JSON `JsFstResult`.
 * @param {string} pop1_json
 * @param {string} pop2_json
 * @returns {string}
 */
export function fst_hudson(pop1_json, pop2_json) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(pop1_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(pop2_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.fst_hudson(ptr0, len0, ptr1, len1);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * Compute Gasteiger-Marsili partial charges from SMILES.
 * @param {string} smiles
 * @returns {string}
 */
export function gasteiger_charges_js(smiles) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(smiles, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.gasteiger_charges_js(ptr0, len0);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Gradient boosted decision tree classification.
 *
 * `data_json`: JSON array of numbers (flat row-major matrix).
 * `n_features`: number of features per sample.
 * `labels_json`: JSON array of class labels (usize).
 * `n_estimators`: number of boosting rounds.
 * `learning_rate`: shrinkage factor.
 * `max_depth`: maximum depth per tree.
 * `seed`: random seed.
 * @param {string} data_json
 * @param {number} n_features
 * @param {string} labels_json
 * @param {number} n_estimators
 * @param {number} learning_rate
 * @param {number} max_depth
 * @param {bigint} seed
 * @returns {string}
 */
export function gbdt_classify(data_json, n_features, labels_json, n_estimators, learning_rate, max_depth, seed) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(data_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(labels_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.gbdt_classify(ptr0, len0, n_features, ptr1, len1, n_estimators, learning_rate, max_depth, seed);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * Gradient boosted decision tree regression.
 *
 * `data_json`: JSON array of numbers (flat row-major matrix).
 * `n_features`: number of features per sample.
 * `targets_json`: JSON array of target values (f64).
 * `n_estimators`: number of boosting rounds.
 * `learning_rate`: shrinkage factor.
 * `max_depth`: maximum depth per tree.
 * `seed`: random seed.
 * @param {string} data_json
 * @param {number} n_features
 * @param {string} targets_json
 * @param {number} n_estimators
 * @param {number} learning_rate
 * @param {number} max_depth
 * @param {bigint} seed
 * @returns {string}
 */
export function gbdt_regression(data_json, n_features, targets_json, n_estimators, learning_rate, max_depth, seed) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(data_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(targets_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.gbdt_regression(ptr0, len0, n_features, ptr1, len1, n_estimators, learning_rate, max_depth, seed);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * GC content of a raw nucleotide string, returned as JSON.
 * @param {string} seq
 * @returns {string}
 */
export function gc_content_json(seq) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(seq, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.gc_content_json(ptr0, len0);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Compute Geary's C spatial autocorrelation.
 *
 * `values_json`: JSON array of f64 values (one per node).
 * `neighbors_json`: JSON array of arrays of `[neighbor_index, distance]`.
 * Output: JSON `JsGearysC`.
 * @param {string} values_json
 * @param {string} neighbors_json
 * @returns {string}
 */
export function gearys_c(values_json, neighbors_json) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(values_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(neighbors_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.gearys_c(ptr0, len0, ptr1, len1);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * Generate a SAM MD:Z tag from CIGAR + ungapped sequences.
 * @param {string} cigar
 * @param {string} query
 * @param {string} reference
 * @returns {string}
 */
export function generate_md_tag(cigar, query, reference) {
    let deferred4_0;
    let deferred4_1;
    try {
        const ptr0 = passStringToWasm0(cigar, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(query, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(reference, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ret = wasm.generate_md_tag(ptr0, len0, ptr1, len1, ptr2, len2);
        deferred4_0 = ret[0];
        deferred4_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred4_0, deferred4_1, 1);
    }
}

/**
 * Hamming distance between two raw strings (byte-level comparison).
 * @param {string} a
 * @param {string} b
 * @returns {string}
 */
export function hamming_distance(a, b) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(a, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(b, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.hamming_distance(ptr0, len0, ptr1, len1);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * Convert hard clips (H) to soft clips (S).
 *
 * Returns the converted CIGAR string.
 * @param {string} cigar
 * @returns {string}
 */
export function hard_clip_to_soft(cigar) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(cigar, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.hard_clip_to_soft(ptr0, len0);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * HMM log-likelihood of an observation sequence.
 *
 * `n_states`: number of hidden states.
 * `n_symbols`: number of observable symbols.
 * `initial_json`: JSON array of initial probabilities.
 * `transition_json`: JSON array of transition probabilities (row-major).
 * `emission_json`: JSON array of emission probabilities (row-major).
 * `observations_json`: JSON array of observation indices.
 * @param {number} n_states
 * @param {number} n_symbols
 * @param {string} initial_json
 * @param {string} transition_json
 * @param {string} emission_json
 * @param {string} observations_json
 * @returns {string}
 */
export function hmm_likelihood(n_states, n_symbols, initial_json, transition_json, emission_json, observations_json) {
    let deferred5_0;
    let deferred5_1;
    try {
        const ptr0 = passStringToWasm0(initial_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(transition_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(emission_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ptr3 = passStringToWasm0(observations_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len3 = WASM_VECTOR_LEN;
        const ret = wasm.hmm_likelihood(n_states, n_symbols, ptr0, len0, ptr1, len1, ptr2, len2, ptr3, len3);
        deferred5_0 = ret[0];
        deferred5_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred5_0, deferred5_1, 1);
    }
}

/**
 * HMM Viterbi decoding.
 *
 * `n_states`: number of hidden states.
 * `n_symbols`: number of observable symbols.
 * `initial_json`: JSON array of initial probabilities.
 * `transition_json`: JSON array of transition probabilities (row-major).
 * `emission_json`: JSON array of emission probabilities (row-major).
 * `observations_json`: JSON array of observation indices.
 * @param {number} n_states
 * @param {number} n_symbols
 * @param {string} initial_json
 * @param {string} transition_json
 * @param {string} emission_json
 * @param {string} observations_json
 * @returns {string}
 */
export function hmm_viterbi(n_states, n_symbols, initial_json, transition_json, emission_json, observations_json) {
    let deferred5_0;
    let deferred5_1;
    try {
        const ptr0 = passStringToWasm0(initial_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(transition_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(emission_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ptr3 = passStringToWasm0(observations_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len3 = WASM_VECTOR_LEN;
        const ret = wasm.hmm_viterbi(n_states, n_symbols, ptr0, len0, ptr1, len1, ptr2, len2, ptr3, len3);
        deferred5_0 = ret[0];
        deferred5_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred5_0, deferred5_1, 1);
    }
}

/**
 * Intersect two interval sets, returning overlapping sub-regions.
 *
 * Input: two JSON arrays of `{chrom, start, end}`.
 * Output: JSON array of `JsGenomicInterval`.
 * @param {string} a_json
 * @param {string} b_json
 * @returns {string}
 */
export function intersect_intervals(a_json, b_json) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(a_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(b_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.intersect_intervals(ptr0, len0, ptr1, len1);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * Jaccard similarity between two interval sets.
 *
 * Input: two JSON arrays of `{chrom, start, end}`.
 * Output: JSON `JsJaccard`.
 * @param {string} a_json
 * @param {string} b_json
 * @returns {string}
 */
export function jaccard_intervals(a_json, b_json) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(a_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(b_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.jaccard_intervals(ptr0, len0, ptr1, len1);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * Kabsch superposition on two coordinate sets (JSON arrays of [x,y,z]).
 *
 * Returns RMSD, rotation matrix (9 elements, row-major), and translation vector.
 * @param {string} coords1_json
 * @param {string} coords2_json
 * @returns {string}
 */
export function kabsch_align(coords1_json, coords2_json) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(coords1_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(coords2_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.kabsch_align(ptr0, len0, ptr1, len1);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * Kaplan-Meier survival curve from JSON arrays of times and event status.
 *
 * Input: times as `"[1.0, 2.0, 3.0]"`, status as `"[true, false, true]"`.
 * Output: JSON `JsKmResult`.
 * @param {string} times_json
 * @param {string} status_json
 * @returns {string}
 */
export function kaplan_meier(times_json, status_json) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(times_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(status_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.kaplan_meier(ptr0, len0, ptr1, len1);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * K-means clustering.
 *
 * `data_json`: JSON array of numbers (flat row-major matrix).
 * `n_features`: number of features per sample.
 * `n_clusters`: number of clusters.
 * `max_iter`: maximum iterations.
 * `seed`: random seed.
 * @param {string} data_json
 * @param {number} n_features
 * @param {number} n_clusters
 * @param {number} max_iter
 * @param {bigint} seed
 * @returns {string}
 */
export function kmeans(data_json, n_features, n_clusters, max_iter, seed) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(data_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.kmeans(ptr0, len0, n_features, n_clusters, max_iter, seed);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Count k-mers in a nucleotide/protein sequence string.
 *
 * Returns JSON `JsKmerCounts` with string keys.
 * @param {string} seq
 * @param {number} k
 * @returns {string}
 */
export function kmer_count(seq, k) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(seq, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.kmer_count(ptr0, len0, k);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Liftover a single genomic interval using a UCSC chain file.
 *
 * `chain_text`: full chain file content as a string.
 * `chrom`, `start`, `end`: interval to liftover.
 * Output: JSON `JsLiftoverResult`.
 * @param {string} chain_text
 * @param {string} chrom
 * @param {bigint} start
 * @param {bigint} end
 * @returns {string}
 */
export function liftover_interval(chain_text, chrom, start, end) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(chain_text, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(chrom, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.liftover_interval(ptr0, len0, ptr1, len1, start, end);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * Log-rank test comparing survival between two groups.
 *
 * Input: times and status for each group as JSON arrays.
 * Output: JSON `JsLogRankResult`.
 * @param {string} times1_json
 * @param {string} status1_json
 * @param {string} times2_json
 * @param {string} status2_json
 * @returns {string}
 */
export function log_rank_test(times1_json, status1_json, times2_json, status2_json) {
    let deferred5_0;
    let deferred5_1;
    try {
        const ptr0 = passStringToWasm0(times1_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(status1_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(times2_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ptr3 = passStringToWasm0(status2_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len3 = WASM_VECTOR_LEN;
        const ret = wasm.log_rank_test(ptr0, len0, ptr1, len1, ptr2, len2, ptr3, len3);
        deferred5_0 = ret[0];
        deferred5_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred5_0, deferred5_1, 1);
    }
}

/**
 * Compute a MACCS 166-key structural fingerprint from a SMILES string.
 *
 * Returns the set bit positions, count of set bits, and total bit count.
 * @param {string} smiles
 * @returns {string}
 */
export function maccs_fingerprint(smiles) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(smiles, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.maccs_fingerprint(ptr0, len0);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Generate non-overlapping tiling windows across a genome.
 *
 * `genome_json`: JSON array of `{chrom, length}`.
 * `window_size`: window size in bases.
 * Output: JSON array of `JsGenomicInterval`.
 * @param {string} genome_json
 * @param {bigint} window_size
 * @returns {string}
 */
export function make_windows(genome_json, window_size) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(genome_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.make_windows(ptr0, len0, window_size);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Manhattan distance between two JSON arrays of numbers.
 * @param {string} a_json
 * @param {string} b_json
 * @returns {string}
 */
export function manhattan_distance(a_json, b_json) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(a_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(b_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.manhattan_distance(ptr0, len0, ptr1, len1);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * Mann-Whitney U test (non-parametric) on two JSON arrays.
 * @param {string} x_json
 * @param {string} y_json
 * @returns {string}
 */
export function mann_whitney_u(x_json, y_json) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(x_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(y_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.mann_whitney_u(ptr0, len0, ptr1, len1);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * Merge adjacent same-type CIGAR operations.
 *
 * Returns the merged CIGAR string.
 * @param {string} cigar
 * @returns {string}
 */
export function merge_cigar(cigar) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(cigar, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.merge_cigar(ptr0, len0);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Merge overlapping intervals.
 *
 * Input: JSON array of `{chrom, start, end}` objects.
 * Output: JSON array of merged `JsGenomicInterval`.
 * @param {string} json
 * @returns {string}
 */
export function merge_intervals(json) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.merge_intervals(ptr0, len0);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Compare two sequences using MinHash and return similarity metrics.
 *
 * Returns Jaccard similarity, containment (both directions), and ANI estimate.
 * @param {string} seq_a
 * @param {string} seq_b
 * @param {number} k
 * @param {number} sketch_size
 * @returns {string}
 */
export function minhash_compare(seq_a, seq_b, k, sketch_size) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(seq_a, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(seq_b, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.minhash_compare(ptr0, len0, ptr1, len1, k, sketch_size);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * Create a MinHash sketch of a nucleotide sequence.
 *
 * Returns a JSON object with k, sketch_size, num_hashes, and the hash values.
 * @param {string} seq
 * @param {number} k
 * @param {number} sketch_size
 * @returns {string}
 */
export function minhash_sketch(seq, k, sketch_size) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(seq, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.minhash_sketch(ptr0, len0, k, sketch_size);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Minimize MMFF94 energy for a SMILES string.
 * @param {string} smiles
 * @param {number} max_steps
 * @param {number} gradient_threshold
 * @returns {string}
 */
export function minimize_mmff94(smiles, max_steps, gradient_threshold) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(smiles, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.minimize_mmff94(ptr0, len0, max_steps, gradient_threshold);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Minimize UFF energy for a SMILES string (auto-embeds, then minimizes).
 * @param {string} smiles
 * @param {number} max_steps
 * @param {number} gradient_threshold
 * @returns {string}
 */
export function minimize_uff(smiles, max_steps, gradient_threshold) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(smiles, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.minimize_uff(ptr0, len0, max_steps, gradient_threshold);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Compute MMFF94 energy for a SMILES string (auto-embeds 3D coordinates).
 * @param {string} smiles
 * @returns {string}
 */
export function mmff94_energy_js(smiles) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(smiles, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.mmff94_energy_js(ptr0, len0);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Compute Moran's I spatial autocorrelation.
 *
 * `values_json`: JSON array of f64 values (one per node).
 * `neighbors_json`: JSON array of arrays, where each inner array contains
 *   `[neighbor_index, distance]` pairs.
 * Output: JSON `JsSpatialAutocorrelation`.
 * @param {string} values_json
 * @param {string} neighbors_json
 * @returns {string}
 */
export function morans_i(values_json, neighbors_json) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(values_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(neighbors_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.morans_i(ptr0, len0, ptr1, len1);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * Build an NCBI Entrez efetch URL for the given database and IDs.
 *
 * `ids` is a comma-separated string of identifiers.
 * @param {string} db
 * @param {string} ids
 * @param {string} rettype
 * @returns {string}
 */
export function ncbi_fetch_url(db, ids, rettype) {
    let deferred4_0;
    let deferred4_1;
    try {
        const ptr0 = passStringToWasm0(db, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(ids, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(rettype, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ret = wasm.ncbi_fetch_url(ptr0, len0, ptr1, len1, ptr2, len2);
        deferred4_0 = ret[0];
        deferred4_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred4_0, deferred4_1, 1);
    }
}

/**
 * Parse a Newick string and return tree info as JSON.
 * @param {string} newick
 * @returns {string}
 */
export function newick_info(newick) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(newick, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.newick_info(ptr0, len0);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Parse BED text and return records as JSON.
 * @param {string} text
 * @returns {string}
 */
export function parse_bed_text(text) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(text, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.parse_bed_text(ptr0, len0);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Parse bedGraph text and return records as JSON.
 * @param {string} text
 * @returns {string}
 */
export function parse_bedgraph(text) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(text, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.parse_bedgraph(ptr0, len0);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Parse BLAST XML output and return results as JSON.
 * @param {string} xml
 * @returns {string}
 */
export function parse_blast_xml(xml) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(xml, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.parse_blast_xml(ptr0, len0);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Parse a SAM CIGAR string and return the operations as JSON.
 *
 * Returns a JSON array of CIGAR operations (e.g. `[{"AlnMatch":10},{"Insertion":3}]`).
 * Accepts the full SAM alphabet (M, I, D, N, S, H, P, =, X) and `*` for unavailable.
 * @param {string} cigar
 * @returns {string}
 */
export function parse_cigar(cigar) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(cigar, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.parse_cigar(ptr0, len0);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Parse FASTA from a string and return JSON.
 * @param {string} data
 * @returns {string}
 */
export function parse_fasta(data) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(data, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.parse_fasta(ptr0, len0);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Parse FASTQ from a string and return JSON array of records.
 *
 * Each record has `name`, `sequence`, and `quality` fields.
 * @param {string} data
 * @returns {string}
 */
export function parse_fastq(data) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(data, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.parse_fastq(ptr0, len0);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Parse GFA text and return graph summary as JSON.
 * @param {string} text
 * @returns {string}
 */
export function parse_gfa(text) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(text, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.parse_gfa(ptr0, len0);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Parse GFF3 text and return gene models as JSON.
 * @param {string} text
 * @returns {string}
 */
export function parse_gff3_text(text) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(text, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.parse_gff3_text(ptr0, len0);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Parse interleaved FASTQ data (alternating R1/R2 records).
 *
 * `validation`: `"strict"`, `"relaxed"`, or `"none"`.
 * @param {string} data
 * @param {string} validation
 * @returns {string}
 */
export function parse_interleaved_fastq(data, validation) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(data, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(validation, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.parse_interleaved_fastq(ptr0, len0, ptr1, len1);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * Parse mmCIF text and return structure info as JSON.
 * @param {string} text
 * @returns {string}
 */
export function parse_mmcif(text) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(text, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.parse_mmcif(ptr0, len0);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Parse a NEXUS format string and return file contents as JSON.
 *
 * Returns `JsNexusFile` with taxa list and named trees.
 * @param {string} text
 * @returns {string}
 */
export function parse_nexus(text) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(text, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.parse_nexus(ptr0, len0);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Parse paired FASTQ data from two separate strings.
 *
 * `validation`: `"strict"`, `"relaxed"`, or `"none"`.
 * Returns JSON array of paired records.
 * @param {string} r1_data
 * @param {string} r2_data
 * @param {string} validation
 * @returns {string}
 */
export function parse_paired_fastq(r1_data, r2_data, validation) {
    let deferred4_0;
    let deferred4_1;
    try {
        const ptr0 = passStringToWasm0(r1_data, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(r2_data, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(validation, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ret = wasm.parse_paired_fastq(ptr0, len0, ptr1, len1, ptr2, len2);
        deferred4_0 = ret[0];
        deferred4_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred4_0, deferred4_1, 1);
    }
}

/**
 * Parse an SDF string and return molecule summaries as JSON.
 *
 * Each successfully parsed molecule is returned with its name, formula,
 * atom/bond counts, and molecular weight.
 * @param {string} sdf_text
 * @returns {string}
 */
export function parse_sdf(sdf_text) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(sdf_text, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.parse_sdf(ptr0, len0);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Parse VCF text and return variants as JSON.
 * @param {string} text
 * @returns {string}
 */
export function parse_vcf_text(text) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(text, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.parse_vcf_text(ptr0, len0);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * PCA dimensionality reduction.
 *
 * `data_json`: JSON array of numbers (flat row-major matrix).
 * `n_features`: number of features per sample.
 * `n_components`: output dimensionality.
 * @param {string} data_json
 * @param {number} n_features
 * @param {number} n_components
 * @returns {string}
 */
export function pca(data_json, n_features, n_components) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(data_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.pca(ptr0, len0, n_features, n_components);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Parse PDB text and return structure info as JSON.
 * @param {string} pdb_text
 * @returns {string}
 */
export function pdb_info(pdb_text) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(pdb_text, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.pdb_info(ptr0, len0);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Assign secondary structure from PDB text and return JSON.
 * @param {string} pdb_text
 * @returns {string}
 */
export function pdb_secondary_structure(pdb_text) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(pdb_text, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.pdb_secondary_structure(ptr0, len0);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Pearson correlation between two JSON arrays.
 * @param {string} x_json
 * @param {string} y_json
 * @returns {string}
 */
export function pearson(x_json, y_json) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(x_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(y_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.pearson(ptr0, len0, ptr1, len1);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * Permutation test: generates a null distribution of mean differences
 * between groups.
 *
 * Input: pooled values and group sizes as JSON arrays.
 * Output: JSON array of permutation statistic values.
 * @param {string} values_json
 * @param {string} group_sizes_json
 * @param {number} n_permutations
 * @param {bigint} seed
 * @returns {string}
 */
export function permutation_test(values_json, group_sizes_json, n_permutations, seed) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(values_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(group_sizes_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.permutation_test(ptr0, len0, ptr1, len1, n_permutations, seed);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * Generate pileup from SAM text.
 *
 * Parses SAM-formatted text and generates per-position pileup data.
 * Returns JSON array of pileups (one per reference sequence).
 * @param {string} sam_text
 * @returns {string}
 */
export function pileup_from_sam(sam_text) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(sam_text, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.pileup_from_sam(ptr0, len0);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Convert SAM text to mpileup format.
 *
 * Parses SAM-formatted text and produces mpileup text output.
 * @param {string} sam_text
 * @returns {string}
 */
export function pileup_to_mpileup_text(sam_text) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(sam_text, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.pileup_to_mpileup_text(ptr0, len0);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Compute a POA consensus from multiple sequences.
 *
 * `seqs_json` is a JSON array of sequence strings. The first sequence
 * initializes the graph; subsequent sequences are aligned and integrated.
 * Returns a JSON object with `consensus`, `n_sequences`, and `n_nodes`.
 * @param {string} seqs_json
 * @returns {string}
 */
export function poa_consensus(seqs_json) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(seqs_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.poa_consensus(ptr0, len0);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Compute the precision-recall curve from predicted scores and binary labels.
 *
 * `scores_json`: JSON array of predicted scores (f64).
 * `labels_json`: JSON array of binary labels (bool).
 * @param {string} scores_json
 * @param {string} labels_json
 * @returns {string}
 */
export function pr_curve(scores_json, labels_json) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(scores_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(labels_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.pr_curve(ptr0, len0, ptr1, len1);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * Perform progressive multiple sequence alignment.
 *
 * `seqs_json` is a JSON array of sequence strings (e.g. `["ACGT","ACTT"]`).
 * Returns a JSON object with `aligned`, `n_columns`, and `n_sequences`.
 * @param {string} seqs_json
 * @param {number} match_score
 * @param {number} mismatch_score
 * @param {number} gap_open
 * @param {number} gap_extend
 * @returns {string}
 */
export function progressive_msa(seqs_json, match_score, mismatch_score, gap_open, gap_extend) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(seqs_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.progressive_msa(ptr0, len0, match_score, mismatch_score, gap_open, gap_extend);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Compute basic protein sequence properties.
 *
 * Returns JSON with molecular weight (estimated), isoelectric point, GRAVY, and length.
 * @param {string} seq
 * @returns {string}
 */
export function protein_props(seq) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(seq, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.protein_props(ptr0, len0);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Generate a Ramachandran report from PDB text and return JSON.
 * @param {string} pdb_text
 * @returns {string}
 */
export function ramachandran_analysis(pdb_text) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(pdb_text, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.ramachandran_analysis(ptr0, len0);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Random forest classification.
 *
 * `data_json`: JSON array of numbers (flat row-major matrix).
 * `n_features`: number of features per sample.
 * `labels_json`: JSON array of class labels (usize).
 * `n_trees`: number of trees in the ensemble.
 * `max_depth`: maximum depth per tree.
 * `seed`: random seed.
 * @param {string} data_json
 * @param {number} n_features
 * @param {string} labels_json
 * @param {number} n_trees
 * @param {number} max_depth
 * @param {bigint} seed
 * @returns {string}
 */
export function random_forest_classify(data_json, n_features, labels_json, n_trees, max_depth, seed) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(data_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(labels_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.random_forest_classify(ptr0, len0, n_features, ptr1, len1, n_trees, max_depth, seed);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * Find retrosynthetic disconnections for a target SMILES.
 * @param {string} smiles
 * @returns {string}
 */
export function retrosynthetic_disconnect(smiles) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(smiles, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.retrosynthetic_disconnect(ptr0, len0);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Reverse CIGAR operation order.
 *
 * Returns the reversed CIGAR string.
 * @param {string} cigar
 * @returns {string}
 */
export function reverse_cigar(cigar) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(cigar, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.reverse_cigar(ptr0, len0);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Reverse complement of a DNA sequence string, returned as JSON.
 * @param {string} seq
 * @returns {string}
 */
export function reverse_complement(seq) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(seq, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.reverse_complement(ptr0, len0);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Robinson-Foulds distance between two Newick trees.
 * @param {string} newick1
 * @param {string} newick2
 * @returns {string}
 */
export function rf_distance(newick1, newick2) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(newick1, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(newick2, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.rf_distance(ptr0, len0, ptr1, len1);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * Compute RMSD between two coordinate sets (JSON arrays of [x,y,z]).
 * @param {string} coords1_json
 * @param {string} coords2_json
 * @returns {string}
 */
export function rmsd(coords1_json, coords2_json) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(coords1_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(coords2_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.rmsd(ptr0, len0, ptr1, len1);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * Predict RNA secondary structure using the Nussinov algorithm (maximize base pairs).
 *
 * Returns JSON with dot-bracket structure, base pairs, and pair count.
 * @param {string} seq
 * @returns {string}
 */
export function rna_fold_nussinov(seq) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(seq, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.rna_fold_nussinov(ptr0, len0);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Predict RNA secondary structure using the Zuker MFE algorithm.
 *
 * Returns JSON with dot-bracket structure, base pairs, free energy, and pair count.
 * @param {string} seq
 * @returns {string}
 */
export function rna_fold_zuker(seq) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(seq, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.rna_fold_zuker(ptr0, len0);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Compute the ROC curve from predicted scores and binary labels.
 *
 * `scores_json`: JSON array of predicted scores (f64).
 * `labels_json`: JSON array of binary labels (bool).
 * @param {string} scores_json
 * @param {string} labels_json
 * @returns {string}
 */
export function roc_curve(scores_json, labels_json) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(scores_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(labels_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.roc_curve(ptr0, len0, ptr1, len1);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * Run ComBat batch correction.
 *
 * `data_json`: flat row-major JSON array of f64.
 * `n_features`: number of genes (columns).
 * `batch_json`: JSON array of batch label strings (one per cell).
 * Output: JSON `JsHarmonyResult` (same format as Harmony for simplicity).
 * @param {string} data_json
 * @param {number} n_features
 * @param {string} batch_json
 * @returns {string}
 */
export function sc_combat(data_json, n_features, batch_json) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(data_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(batch_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.sc_combat(ptr0, len0, n_features, ptr1, len1);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * Compute a diffusion map embedding.
 *
 * `data_json`: flat row-major JSON array of f64.
 * `n_features`: number of genes (columns).
 * `n_components`: number of diffusion components.
 * Output: JSON `JsDiffusionResult`.
 * @param {string} data_json
 * @param {number} n_features
 * @param {number} n_components
 * @returns {string}
 */
export function sc_diffusion_map(data_json, n_features, n_components) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(data_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.sc_diffusion_map(ptr0, len0, n_features, n_components);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Compute diffusion pseudotime.
 *
 * `diffmap_json`: JSON `{components: [[...], ...], eigenvalues: [...], n_obs: N}`.
 * `root_cell`: index of the root cell.
 * Output: JSON `JsDptResult`.
 * @param {string} diffmap_json
 * @param {number} root_cell
 * @returns {string}
 */
export function sc_dpt(diffmap_json, root_cell) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(diffmap_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.sc_dpt(ptr0, len0, root_cell);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Filter marker genes by fold-change, pct, and p-value thresholds.
 *
 * `markers_json`: JSON `JsMarkerResult`.
 * `log2fc`: minimum absolute log2 fold change.
 * `min_pct`: minimum fraction of cells expressing the gene in the cluster.
 * `padj`: maximum adjusted p-value.
 * Output: JSON `JsMarkerResult` (filtered).
 * @param {string} markers_json
 * @param {number} log2fc
 * @param {number} min_pct
 * @param {number} padj
 * @returns {string}
 */
export function sc_filter_markers(markers_json, log2fc, min_pct, padj) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(markers_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.sc_filter_markers(ptr0, len0, log2fc, min_pct, padj);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Run Harmony batch correction.
 *
 * `data_json`: flat row-major JSON array of f64.
 * `n_features`: number of genes (columns).
 * `batch_json`: JSON array of batch label strings (one per cell).
 * `n_clusters`: optional number of clusters for Harmony.
 * Output: JSON `JsHarmonyResult`.
 * @param {string} data_json
 * @param {number} n_features
 * @param {string} batch_json
 * @param {number} n_clusters
 * @returns {string}
 */
export function sc_harmony(data_json, n_features, batch_json, n_clusters) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(data_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(batch_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.sc_harmony(ptr0, len0, n_features, ptr1, len1, n_clusters);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * Identify highly variable genes.
 *
 * `data_json`: flat row-major JSON array of f64.
 * `n_features`: number of genes (columns).
 * `n_top_genes`: how many HVGs to select.
 * `method`: `"seurat_v3"` or `"cell_ranger"`.
 * Output: JSON `JsHvgResult`.
 * @param {string} data_json
 * @param {number} n_features
 * @param {number} n_top_genes
 * @param {string} method
 * @returns {string}
 */
export function sc_hvg(data_json, n_features, n_top_genes, method) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(data_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(method, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.sc_hvg(ptr0, len0, n_features, n_top_genes, ptr1, len1);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * Leiden clustering on a precomputed neighbor graph.
 *
 * `neighbors_json`: JSON with `{distances: [[r,c,v],...], connectivities: [[r,c,v],...], n_obs: N}`.
 * `resolution`: resolution parameter (higher = more clusters).
 * Output: JSON `JsClusterResult`.
 * @param {string} neighbors_json
 * @param {number} resolution
 * @returns {string}
 */
export function sc_leiden(neighbors_json, resolution) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(neighbors_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.sc_leiden(ptr0, len0, resolution);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Louvain clustering on a precomputed neighbor graph.
 *
 * `neighbors_json`: JSON with `{distances: [[r,c,v],...], connectivities: [[r,c,v],...], n_obs: N}`.
 * `resolution`: resolution parameter.
 * Output: JSON `JsClusterResult`.
 * @param {string} neighbors_json
 * @param {number} resolution
 * @returns {string}
 */
export function sc_louvain(neighbors_json, resolution) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(neighbors_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.sc_louvain(ptr0, len0, resolution);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Compute a k-nearest neighbors graph.
 *
 * `data_json`: flat row-major JSON array of f64.
 * `n_features`: number of genes (columns).
 * `n_neighbors`: number of neighbors to find.
 * `metric`: `"euclidean"` or `"cosine"`.
 * Output: JSON `JsNeighborsResult`.
 * @param {string} data_json
 * @param {number} n_features
 * @param {number} n_neighbors
 * @param {string} metric
 * @returns {string}
 */
export function sc_neighbors(data_json, n_features, n_neighbors, metric) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(data_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(metric, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.sc_neighbors(ptr0, len0, n_features, n_neighbors, ptr1, len1);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * Normalize cells to a target sum and optionally log-transform.
 *
 * `data_json`: flat row-major JSON array of f64.
 * `n_features`: number of genes (columns).
 * `target_sum`: normalization target (e.g. 10000).
 * `log1p`: whether to apply log(1+x) afterwards.
 * Output: JSON array of corrected values (flat row-major).
 * @param {string} data_json
 * @param {number} n_features
 * @param {number} target_sum
 * @param {boolean} log1p
 * @returns {string}
 */
export function sc_normalize(data_json, n_features, target_sum, log1p) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(data_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.sc_normalize(ptr0, len0, n_features, target_sum, log1p);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Compute PAGA graph abstraction.
 *
 * `neighbors_json`: JSON with `{connectivities: [[r,c,v],...], n_obs: N}`.
 * `clusters_json`: JSON array of cluster label strings (one per cell).
 * Output: JSON `JsPagaResult`.
 * @param {string} neighbors_json
 * @param {string} clusters_json
 * @returns {string}
 */
export function sc_paga(neighbors_json, clusters_json) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(neighbors_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(clusters_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.sc_paga(ptr0, len0, ptr1, len1);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * Rank genes per cluster (differential expression).
 *
 * `data_json`: flat row-major JSON array of f64.
 * `n_features`: number of genes (columns).
 * `clusters_json`: JSON array of cluster label strings (one per cell).
 * `method`: `"t-test"`, `"wilcoxon"`, or `"logistic"`.
 * Output: JSON `JsMarkerResult`.
 * @param {string} data_json
 * @param {number} n_features
 * @param {string} clusters_json
 * @param {string} method
 * @returns {string}
 */
export function sc_rank_genes(data_json, n_features, clusters_json, method) {
    let deferred4_0;
    let deferred4_1;
    try {
        const ptr0 = passStringToWasm0(data_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(clusters_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(method, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ret = wasm.sc_rank_genes(ptr0, len0, n_features, ptr1, len1, ptr2, len2);
        deferred4_0 = ret[0];
        deferred4_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred4_0, deferred4_1, 1);
    }
}

/**
 * Regress out covariates from the expression matrix.
 *
 * `data_json`: flat row-major JSON array of f64.
 * `n_features`: number of genes (columns).
 * `covariates_json`: JSON array of f64 arrays (one per covariate).
 * Output: JSON array of corrected values (flat row-major).
 * @param {string} data_json
 * @param {number} n_features
 * @param {string} covariates_json
 * @returns {string}
 */
export function sc_regress_out(data_json, n_features, covariates_json) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(data_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(covariates_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.sc_regress_out(ptr0, len0, n_features, ptr1, len1);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * Score a set of genes per cell (like scanpy.tl.score_genes).
 *
 * `data_json`: flat row-major JSON array of f64.
 * `n_features`: number of genes (columns).
 * `gene_indices_json`: JSON array of usize gene indices to score.
 * Output: JSON array of f64 scores (one per cell).
 * @param {string} data_json
 * @param {number} n_features
 * @param {string} gene_indices_json
 * @returns {string}
 */
export function sc_score_genes(data_json, n_features, gene_indices_json) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(data_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(gene_indices_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.sc_score_genes(ptr0, len0, n_features, ptr1, len1);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * SHA-256 hash of a string, returned as JSON hex string.
 * @param {string} data
 * @returns {string}
 */
export function sha256(data) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(data, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.sha256(ptr0, len0);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Shannon diversity index from a JSON array of species counts.
 *
 * Output: JSON f64 value.
 * @param {string} counts_json
 * @returns {string}
 */
export function shannon_index(counts_json) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(counts_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.shannon_index(ptr0, len0);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Simpson diversity index from a JSON array of species counts.
 *
 * Output: JSON f64 value.
 * @param {string} counts_json
 * @returns {string}
 */
export function simpson_index(counts_json) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(counts_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.simpson_index(ptr0, len0);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Simulate a coalescent (Kingman) tree for a constant-size population.
 *
 * `n_samples`: number of sampled lineages (>= 2).
 * `pop_size`: effective population size (> 0).
 * `seed`: random seed for reproducibility.
 * @param {number} n_samples
 * @param {number} pop_size
 * @param {bigint} seed
 * @returns {string}
 */
export function simulate_coalescent(n_samples, pop_size, seed) {
    let deferred1_0;
    let deferred1_1;
    try {
        const ret = wasm.simulate_coalescent(n_samples, pop_size, seed);
        deferred1_0 = ret[0];
        deferred1_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred1_0, deferred1_1, 1);
    }
}

/**
 * Simulate a coalescent tree with exponential population growth.
 *
 * `n_samples`: number of sampled lineages (>= 2).
 * `pop_size`: current effective population size (> 0).
 * `growth_rate`: exponential growth rate (>= 0).
 * `seed`: random seed for reproducibility.
 * @param {number} n_samples
 * @param {number} pop_size
 * @param {number} growth_rate
 * @param {bigint} seed
 * @returns {string}
 */
export function simulate_coalescent_growth(n_samples, pop_size, growth_rate, seed) {
    let deferred1_0;
    let deferred1_1;
    try {
        const ret = wasm.simulate_coalescent_growth(n_samples, pop_size, growth_rate, seed);
        deferred1_0 = ret[0];
        deferred1_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred1_0, deferred1_1, 1);
    }
}

/**
 * Simulate sequence evolution along a phylogenetic tree.
 *
 * `newick`: Newick string for the guide tree.
 * `seq_length`: length of sequences to simulate.
 * `model`: substitution model — `"jc69"` or `"k2p"` (defaults to JC69 for unknown).
 * `seed`: random seed for reproducibility.
 * @param {string} newick_str
 * @param {number} seq_length
 * @param {string} model
 * @param {bigint} seed
 * @returns {string}
 */
export function simulate_evolution(newick_str, seq_length, model, seed) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(newick_str, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(model, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.simulate_evolution(ptr0, len0, seq_length, ptr1, len1, seed);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * Simulate sequencing reads from a reference sequence.
 *
 * `config_json`: JSON object with optional fields: `read_length`, `coverage`,
 * `error_rate`, `seed`. Returns JSON array of simulated reads.
 * @param {string} ref_seq
 * @param {string} config_json
 * @returns {string}
 */
export function simulate_reads(ref_seq, config_json) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(ref_seq, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(config_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.simulate_reads(ptr0, len0, ptr1, len1);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * Compute a Morgan fingerprint and return set bits as JSON.
 * @param {string} smiles
 * @param {number} radius
 * @param {number} n_bits
 * @returns {string}
 */
export function smiles_fingerprint(smiles, radius, n_bits) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(smiles, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.smiles_fingerprint(ptr0, len0, radius, n_bits);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Parse SMILES and return molecular properties as JSON.
 * @param {string} smiles
 * @returns {string}
 */
export function smiles_properties(smiles) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(smiles, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.smiles_properties(ptr0, len0);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Check for substructure match between molecule and pattern SMILES.
 * @param {string} molecule
 * @param {string} pattern
 * @returns {string}
 */
export function smiles_substructure(molecule, pattern) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(molecule, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(pattern, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.smiles_substructure(ptr0, len0, ptr1, len1);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * Spearman rank correlation between two JSON arrays.
 * @param {string} x_json
 * @param {string} y_json
 * @returns {string}
 */
export function spearman(x_json, y_json) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(x_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(y_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.spearman(ptr0, len0, ptr1, len1);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * Split CIGAR at a reference coordinate, returning two CIGAR strings.
 *
 * Returns `{"ok": {"left": "...", "right": "..."}}`.
 * @param {string} cigar
 * @param {number} ref_pos
 * @returns {string}
 */
export function split_cigar(cigar, ref_pos) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(cigar, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.split_cigar(ptr0, len0, ref_pos);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Subtract intervals in `b` from intervals in `a`.
 *
 * Input: two JSON arrays of `{chrom, start, end}`.
 * Output: JSON array of `JsGenomicInterval`.
 * @param {string} a_json
 * @param {string} b_json
 * @returns {string}
 */
export function subtract_intervals(a_json, b_json) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(a_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(b_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.subtract_intervals(ptr0, len0, ptr1, len1);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * One-sample t-test on a JSON array against hypothesised mean `mu`.
 * @param {string} data_json
 * @param {number} mu
 * @returns {string}
 */
export function t_test(data_json, mu) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(data_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.t_test(ptr0, len0, mu);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Two-sample t-test (Student's or Welch's) on two JSON arrays.
 * @param {string} x_json
 * @param {string} y_json
 * @param {boolean} equal_var
 * @returns {string}
 */
export function t_test_two_sample(x_json, y_json, equal_var) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(x_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(y_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.t_test_two_sample(ptr0, len0, ptr1, len1, equal_var);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * Tajima's D statistic from pre-computed summary values.
 *
 * Output: JSON `JsTajimaD`.
 * @param {number} segregating_sites
 * @param {number} n_sequences
 * @param {number} avg_pairwise_diff
 * @returns {string}
 */
export function tajimas_d(segregating_sites, n_sequences, avg_pairwise_diff) {
    let deferred1_0;
    let deferred1_1;
    try {
        const ret = wasm.tajimas_d(segregating_sites, n_sequences, avg_pairwise_diff);
        deferred1_0 = ret[0];
        deferred1_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred1_0, deferred1_1, 1);
    }
}

/**
 * Tanimoto similarity between two SMILES strings.
 * @param {string} smiles1
 * @param {string} smiles2
 * @returns {string}
 */
export function tanimoto(smiles1, smiles2) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(smiles1, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(smiles2, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.tanimoto(ptr0, len0, ptr1, len1);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * Compute Tanimoto similarity between two SMILES strings using MACCS fingerprints.
 * @param {string} smiles1
 * @param {string} smiles2
 * @returns {string}
 */
export function tanimoto_maccs(smiles1, smiles2) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(smiles1, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(smiles2, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.tanimoto_maccs(ptr0, len0, ptr1, len1);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * Transcribe DNA to RNA, returned as JSON.
 * @param {string} seq
 * @returns {string}
 */
export function transcribe(seq) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(seq, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.transcribe(ptr0, len0);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Translate DNA to protein (standard codon table), returned as JSON.
 * @param {string} seq
 * @returns {string}
 */
export function translate(seq) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(seq, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.translate(ptr0, len0);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Trim single-end FASTQ records.
 *
 * `config_json`: JSON object with optional fields: `min_quality`, `window_size`,
 * `min_length`, `max_length`, `adapters`.
 * Returns JSON array of trimmed records.
 * @param {string} data
 * @param {string} config_json
 * @returns {string}
 */
export function trim_fastq(data, config_json) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(data, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(config_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.trim_fastq(ptr0, len0, ptr1, len1);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * Trim paired FASTQ records.
 *
 * `config_json`: JSON trim config (see `trim_fastq`).
 * `orphan_policy`: `"drop_both"`, `"keep_first"`, or `"keep_second"`.
 * @param {string} r1_data
 * @param {string} r2_data
 * @param {string} config_json
 * @param {string} orphan_policy
 * @returns {string}
 */
export function trim_paired_fastq(r1_data, r2_data, config_json, orphan_policy) {
    let deferred5_0;
    let deferred5_1;
    try {
        const ptr0 = passStringToWasm0(r1_data, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(r2_data, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(config_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ptr3 = passStringToWasm0(orphan_policy, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len3 = WASM_VECTOR_LEN;
        const ret = wasm.trim_paired_fastq(ptr0, len0, ptr1, len1, ptr2, len2, ptr3, len3);
        deferred5_0 = ret[0];
        deferred5_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred5_0, deferred5_1, 1);
    }
}

/**
 * t-SNE dimensionality reduction.
 *
 * `data_json`: JSON array of numbers (flat row-major matrix).
 * `n_features`: number of features per sample.
 * `n_components`: output dimensionality (typically 2 or 3).
 * `perplexity`: perplexity parameter (5-50 typical).
 * `learning_rate`: learning rate.
 * `n_iter`: number of iterations.
 * `seed`: random seed.
 * @param {string} data_json
 * @param {number} n_features
 * @param {number} n_components
 * @param {number} perplexity
 * @param {number} learning_rate
 * @param {number} n_iter
 * @param {bigint} seed
 * @returns {string}
 */
export function tsne(data_json, n_features, n_components, perplexity, learning_rate, n_iter, seed) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(data_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.tsne(ptr0, len0, n_features, n_components, perplexity, learning_rate, n_iter, seed);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Compute UFF energy for a SMILES string (auto-embeds 3D coordinates).
 * @param {string} smiles
 * @returns {string}
 */
export function uff_energy_js(smiles) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(smiles, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.uff_energy_js(ptr0, len0);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * UMAP dimensionality reduction.
 *
 * `data_json`: JSON array of numbers (flat row-major matrix).
 * `n_features`: number of features per sample.
 * `n_components`: output dimensionality (default 2).
 * `n_neighbors`: number of nearest neighbors (default 15).
 * `min_dist`: minimum distance in embedding (default 0.1).
 * `n_epochs`: optimization epochs (default 200).
 * `metric`: distance metric ("euclidean", "manhattan", "cosine").
 * @param {string} data_json
 * @param {number} n_features
 * @param {number} n_components
 * @param {number} n_neighbors
 * @param {number} min_dist
 * @param {number} n_epochs
 * @param {string} metric
 * @returns {string}
 */
export function umap(data_json, n_features, n_components, n_neighbors, min_dist, n_epochs, metric) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(data_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(metric, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.umap(ptr0, len0, n_features, n_components, n_neighbors, min_dist, n_epochs, ptr1, len1);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * Validate a sequence against an alphabet ("dna", "rna", or "protein").
 *
 * Returns JSON `{"ok": true}` if valid, or `{"error": "..."}` if invalid.
 * @param {string} seq
 * @param {string} alphabet
 * @returns {string}
 */
export function validate(seq, alphabet) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(seq, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(alphabet, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.validate(ptr0, len0, ptr1, len1);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * Validate a CIGAR string against SAM spec rules.
 *
 * Returns `{"ok": true}` if valid, or `{"error": "..."}` describing the violation.
 * @param {string} cigar
 * @returns {string}
 */
export function validate_cigar(cigar) {
    let deferred2_0;
    let deferred2_1;
    try {
        const ptr0 = passStringToWasm0(cigar, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.validate_cigar(ptr0, len0);
        deferred2_0 = ret[0];
        deferred2_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
    }
}

/**
 * Wright-Fisher allele frequency drift simulation.
 *
 * Output: JSON `JsWrightFisherResult`.
 * @param {number} pop_size
 * @param {number} initial_freq
 * @param {number} n_generations
 * @param {bigint} seed
 * @returns {string}
 */
export function wright_fisher(pop_size, initial_freq, n_generations, seed) {
    let deferred1_0;
    let deferred1_1;
    try {
        const ret = wasm.wright_fisher(pop_size, initial_freq, n_generations, seed);
        deferred1_0 = ret[0];
        deferred1_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred1_0, deferred1_1, 1);
    }
}

/**
 * Write a NEXUS file from taxa and trees JSON.
 *
 * `taxa_json`: JSON array of taxon name strings.
 * `trees_json`: JSON array of `{"name": "...", "newick": "..."}` objects.
 * @param {string} taxa_json
 * @param {string} trees_json
 * @returns {string}
 */
export function write_nexus(taxa_json, trees_json) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(taxa_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(trees_json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.write_nexus(ptr0, len0, ptr1, len1);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

function __wbg_get_imports() {
    const import0 = {
        __proto__: null,
        __wbindgen_init_externref_table: function() {
            const table = wasm.__wbindgen_externrefs;
            const offset = table.grow(4);
            table.set(0, undefined);
            table.set(offset + 0, undefined);
            table.set(offset + 1, null);
            table.set(offset + 2, true);
            table.set(offset + 3, false);
        },
    };
    return {
        __proto__: null,
        "./cyanea_wasm_bg.js": import0,
    };
}

function getStringFromWasm0(ptr, len) {
    ptr = ptr >>> 0;
    return decodeText(ptr, len);
}

let cachedUint8ArrayMemory0 = null;
function getUint8ArrayMemory0() {
    if (cachedUint8ArrayMemory0 === null || cachedUint8ArrayMemory0.byteLength === 0) {
        cachedUint8ArrayMemory0 = new Uint8Array(wasm.memory.buffer);
    }
    return cachedUint8ArrayMemory0;
}

function passStringToWasm0(arg, malloc, realloc) {
    if (realloc === undefined) {
        const buf = cachedTextEncoder.encode(arg);
        const ptr = malloc(buf.length, 1) >>> 0;
        getUint8ArrayMemory0().subarray(ptr, ptr + buf.length).set(buf);
        WASM_VECTOR_LEN = buf.length;
        return ptr;
    }

    let len = arg.length;
    let ptr = malloc(len, 1) >>> 0;

    const mem = getUint8ArrayMemory0();

    let offset = 0;

    for (; offset < len; offset++) {
        const code = arg.charCodeAt(offset);
        if (code > 0x7F) break;
        mem[ptr + offset] = code;
    }
    if (offset !== len) {
        if (offset !== 0) {
            arg = arg.slice(offset);
        }
        ptr = realloc(ptr, len, len = offset + arg.length * 3, 1) >>> 0;
        const view = getUint8ArrayMemory0().subarray(ptr + offset, ptr + len);
        const ret = cachedTextEncoder.encodeInto(arg, view);

        offset += ret.written;
        ptr = realloc(ptr, len, offset, 1) >>> 0;
    }

    WASM_VECTOR_LEN = offset;
    return ptr;
}

let cachedTextDecoder = new TextDecoder('utf-8', { ignoreBOM: true, fatal: true });
cachedTextDecoder.decode();
const MAX_SAFARI_DECODE_BYTES = 2146435072;
let numBytesDecoded = 0;
function decodeText(ptr, len) {
    numBytesDecoded += len;
    if (numBytesDecoded >= MAX_SAFARI_DECODE_BYTES) {
        cachedTextDecoder = new TextDecoder('utf-8', { ignoreBOM: true, fatal: true });
        cachedTextDecoder.decode();
        numBytesDecoded = len;
    }
    return cachedTextDecoder.decode(getUint8ArrayMemory0().subarray(ptr, ptr + len));
}

const cachedTextEncoder = new TextEncoder();

if (!('encodeInto' in cachedTextEncoder)) {
    cachedTextEncoder.encodeInto = function (arg, view) {
        const buf = cachedTextEncoder.encode(arg);
        view.set(buf);
        return {
            read: arg.length,
            written: buf.length
        };
    };
}

let WASM_VECTOR_LEN = 0;

let wasmModule, wasm;
function __wbg_finalize_init(instance, module) {
    wasm = instance.exports;
    wasmModule = module;
    cachedUint8ArrayMemory0 = null;
    wasm.__wbindgen_start();
    return wasm;
}

async function __wbg_load(module, imports) {
    if (typeof Response === 'function' && module instanceof Response) {
        if (typeof WebAssembly.instantiateStreaming === 'function') {
            try {
                return await WebAssembly.instantiateStreaming(module, imports);
            } catch (e) {
                const validResponse = module.ok && expectedResponseType(module.type);

                if (validResponse && module.headers.get('Content-Type') !== 'application/wasm') {
                    console.warn("`WebAssembly.instantiateStreaming` failed because your server does not serve Wasm with `application/wasm` MIME type. Falling back to `WebAssembly.instantiate` which is slower. Original error:\n", e);

                } else { throw e; }
            }
        }

        const bytes = await module.arrayBuffer();
        return await WebAssembly.instantiate(bytes, imports);
    } else {
        const instance = await WebAssembly.instantiate(module, imports);

        if (instance instanceof WebAssembly.Instance) {
            return { instance, module };
        } else {
            return instance;
        }
    }

    function expectedResponseType(type) {
        switch (type) {
            case 'basic': case 'cors': case 'default': return true;
        }
        return false;
    }
}

function initSync(module) {
    if (wasm !== undefined) return wasm;


    if (module !== undefined) {
        if (Object.getPrototypeOf(module) === Object.prototype) {
            ({module} = module)
        } else {
            console.warn('using deprecated parameters for `initSync()`; pass a single object instead')
        }
    }

    const imports = __wbg_get_imports();
    if (!(module instanceof WebAssembly.Module)) {
        module = new WebAssembly.Module(module);
    }
    const instance = new WebAssembly.Instance(module, imports);
    return __wbg_finalize_init(instance, module);
}

async function __wbg_init(module_or_path) {
    if (wasm !== undefined) return wasm;


    if (module_or_path !== undefined) {
        if (Object.getPrototypeOf(module_or_path) === Object.prototype) {
            ({module_or_path} = module_or_path)
        } else {
            console.warn('using deprecated parameters for the initialization function; pass a single object instead')
        }
    }

    if (module_or_path === undefined) {
        module_or_path = new URL('cyanea_wasm_bg.wasm', import.meta.url);
    }
    const imports = __wbg_get_imports();

    if (typeof module_or_path === 'string' || (typeof Request === 'function' && module_or_path instanceof Request) || (typeof URL === 'function' && module_or_path instanceof URL)) {
        module_or_path = fetch(module_or_path);
    }

    const { instance, module } = await __wbg_load(await module_or_path, imports);

    return __wbg_finalize_init(instance, module);
}

export { initSync, __wbg_init as default };
