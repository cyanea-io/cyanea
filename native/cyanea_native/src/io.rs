//! cyanea-io NIFs — File format parsing (CSV, VCF, BED, GFF3, SAM, BAM,
//! Parquet, GenBank, EMBL, Stockholm, Clustal, Phylip, bigWig, bedGraph).

use crate::bridge::*;
use crate::to_nif_error;
use std::collections::HashSet;

// ===========================================================================
// Existing NIFs
// ===========================================================================

#[rustler::nif(schedule = "DirtyCpu")]
pub fn csv_info(path: String) -> Result<CsvInfoNif, String> {
    cyanea_io::parse_csv_info(&path)
        .map(CsvInfoNif::from)
        .map_err(to_nif_error)
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn csv_preview(path: String, limit: usize) -> Result<String, String> {
    cyanea_io::csv_preview(&path, limit).map_err(to_nif_error)
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn vcf_stats(path: String) -> Result<VcfStatsNif, String> {
    cyanea_io::vcf_stats(&path)
        .map(VcfStatsNif::from)
        .map_err(to_nif_error)
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn bed_stats(path: String) -> Result<BedStatsNif, String> {
    cyanea_io::bed_stats(&path)
        .map(BedStatsNif::from)
        .map_err(to_nif_error)
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn gff3_stats(path: String) -> Result<GffStatsNif, String> {
    cyanea_io::gff3_stats(&path)
        .map(GffStatsNif::from)
        .map_err(to_nif_error)
}

// ===========================================================================
// New NIFs (existing format parsers)
// ===========================================================================

#[rustler::nif(schedule = "DirtyCpu")]
pub fn parse_vcf(path: String) -> Result<Vec<VcfRecordNif>, String> {
    let variants = cyanea_io::parse_vcf(&path).map_err(to_nif_error)?;
    Ok(variants
        .into_iter()
        .map(|v| VcfRecordNif {
            chrom: v.chrom.clone(),
            position: v.position,
            ref_allele: String::from_utf8_lossy(&v.ref_allele).to_string(),
            alt_alleles: v.alt_alleles.iter().map(|a| String::from_utf8_lossy(a).to_string()).collect(),
            quality: v.quality,
            filter: format!("{:?}", v.filter),
        })
        .collect())
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn parse_bed(path: String) -> Result<Vec<BedRecordNif>, String> {
    let records = cyanea_io::parse_bed(&path).map_err(to_nif_error)?;
    Ok(records
        .into_iter()
        .map(|r| BedRecordNif {
            chrom: r.interval.chrom.clone(),
            start: r.interval.start,
            end: r.interval.end,
            name: r.name.clone(),
            score: r.score.map(|s| s as f64),
            strand: format!("{:?}", r.interval.strand),
        })
        .collect())
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn parse_gff3(path: String) -> Result<Vec<GffGeneNif>, String> {
    let genes = cyanea_io::parse_gff3(&path).map_err(to_nif_error)?;
    Ok(genes
        .into_iter()
        .map(|g| GffGeneNif {
            id: g.gene_id.clone(),
            symbol: g.gene_name.clone(),
            chrom: g.chrom.clone(),
            start: g.start,
            end: g.end,
            strand: format!("{:?}", g.strand),
            gene_type: format!("{:?}", g.gene_type),
            transcript_count: g.transcripts.len(),
        })
        .collect())
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn sam_stats(path: String) -> Result<SamStatsNif, String> {
    let records = cyanea_io::parse_sam(&path).map_err(to_nif_error)?;
    let stats = cyanea_io::sam_stats(&records);
    Ok(SamStatsNif {
        total_reads: stats.total_reads,
        mapped: stats.mapped,
        unmapped: stats.unmapped,
        avg_mapq: stats.avg_mapq,
        avg_length: stats.avg_length,
    })
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn bam_stats(path: String) -> Result<SamStatsNif, String> {
    let records = cyanea_io::parse_bam(&path).map_err(to_nif_error)?;
    let stats = cyanea_io::sam_stats(&records);
    Ok(SamStatsNif {
        total_reads: stats.total_reads,
        mapped: stats.mapped,
        unmapped: stats.unmapped,
        avg_mapq: stats.avg_mapq,
        avg_length: stats.avg_length,
    })
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn parse_sam(path: String) -> Result<Vec<SamRecordNif>, String> {
    let records = cyanea_io::parse_sam(&path).map_err(to_nif_error)?;
    Ok(records
        .into_iter()
        .map(|r| SamRecordNif {
            qname: r.qname.clone(),
            flag: r.flag,
            rname: r.rname.clone(),
            pos: r.pos,
            mapq: r.mapq,
            cigar: r.cigar.clone(),
            sequence: r.sequence.clone(),
            quality: r.quality.clone(),
        })
        .collect())
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn parse_bam(path: String) -> Result<Vec<SamRecordNif>, String> {
    let records = cyanea_io::parse_bam(&path).map_err(to_nif_error)?;
    Ok(records
        .into_iter()
        .map(|r| SamRecordNif {
            qname: r.qname.clone(),
            flag: r.flag,
            rname: r.rname.clone(),
            pos: r.pos,
            mapq: r.mapq,
            cigar: r.cigar.clone(),
            sequence: r.sequence.clone(),
            quality: r.quality.clone(),
        })
        .collect())
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn parse_bed_intervals(path: String) -> Result<Vec<GenomicIntervalNif>, String> {
    let records = cyanea_io::parse_bed(&path).map_err(to_nif_error)?;
    Ok(records
        .into_iter()
        .map(|r| GenomicIntervalNif {
            chrom: r.interval.chrom.clone(),
            start: r.interval.start,
            end: r.interval.end,
            strand: format!("{:?}", r.interval.strand),
        })
        .collect())
}

// ===========================================================================
// New format stats NIFs (Phase 10)
// ===========================================================================

#[rustler::nif(schedule = "DirtyCpu")]
pub fn parquet_stats(path: String) -> Result<ParquetStatsNif, String> {
    let info = cyanea_io::parquet_info(&path).map_err(to_nif_error)?;
    Ok(ParquetStatsNif {
        row_count: info.num_rows as u64,
        column_count: info.num_columns,
        columns: info.column_names,
        compression: info.created_by.unwrap_or_default(),
    })
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn genbank_stats(path: String) -> Result<GenbankStatsNif, String> {
    let records = cyanea_io::parse_genbank(&path).map_err(to_nif_error)?;
    let total_features: usize = records.iter().map(|r| r.features.len()).sum();
    let organism = records.first()
        .and_then(|r| r.organism.clone())
        .unwrap_or_default();
    let accession = records.first()
        .map(|r| r.accession.clone())
        .unwrap_or_default();
    let sequence_length: u64 = records.iter()
        .map(|r| r.sequence.len() as u64)
        .sum();
    Ok(GenbankStatsNif {
        feature_count: total_features,
        organism,
        accession,
        sequence_length,
    })
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn embl_stats(path: String) -> Result<EmblStatsNif, String> {
    let contents = std::fs::read_to_string(&path).map_err(|e| e.to_string())?;
    let records = cyanea_io::parse_embl(&contents).map_err(to_nif_error)?;
    let total_features: usize = records.iter().map(|r| r.features.len()).sum();
    let organism = String::new();
    let accession = records.first()
        .map(|r| r.accession.clone())
        .unwrap_or_default();
    let sequence_length: u64 = records.iter()
        .map(|r| r.sequence.len() as u64)
        .sum();
    Ok(EmblStatsNif {
        feature_count: total_features,
        organism,
        accession,
        sequence_length,
    })
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn newick_file_stats(path: String) -> Result<NewickFileStatsNif, String> {
    let contents = std::fs::read_to_string(&path).map_err(|e| e.to_string())?;
    let tree = cyanea_phylo::parse_newick(&contents).map_err(to_nif_error)?;
    let taxa_count = tree.leaf_count();
    let root_node = tree.get_node(tree.root()).ok_or_else(|| "invalid root node".to_string())?;
    let is_rooted = root_node.children.len() == 2;
    let has_branch_lengths = tree.nodes().iter().any(|n| n.branch_length.is_some());
    Ok(NewickFileStatsNif {
        taxa_count,
        is_rooted,
        has_branch_lengths,
    })
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn nexus_file_stats(path: String) -> Result<NexusFileStatsNif, String> {
    let contents = std::fs::read_to_string(&path).map_err(|e| e.to_string())?;
    let nexus = cyanea_phylo::nexus::parse(&contents).map_err(to_nif_error)?;
    let taxa_count = nexus.taxa.len();
    let tree_count = nexus.trees.len();
    let has_data_block = !nexus.taxa.is_empty();
    Ok(NexusFileStatsNif {
        taxa_count,
        tree_count,
        has_data_block,
    })
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn sdf_stats(path: String) -> Result<SdfStatsNif, String> {
    let contents = std::fs::read_to_string(&path).map_err(|e| e.to_string())?;
    let molecules = cyanea_chem::parse_sdf(&contents);
    let mut molecule_count: usize = 0;
    let mut total_atoms: usize = 0;
    let mut total_bonds: usize = 0;
    for mol_result in molecules {
        let mol = mol_result.map_err(to_nif_error)?;
        molecule_count += 1;
        total_atoms += mol.atom_count();
        total_bonds += mol.bond_count();
    }
    let avg_atoms = if molecule_count > 0 { total_atoms as f64 / molecule_count as f64 } else { 0.0 };
    let avg_bonds = if molecule_count > 0 { total_bonds as f64 / molecule_count as f64 } else { 0.0 };
    Ok(SdfStatsNif {
        molecule_count,
        avg_atoms,
        avg_bonds,
    })
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn pdb_file_stats(path: String) -> Result<PdbFileStatsNif, String> {
    let contents = std::fs::read_to_string(&path).map_err(|e| e.to_string())?;
    let structure = cyanea_struct::parse_pdb(&contents).map_err(to_nif_error)?;
    let resolution = extract_pdb_resolution(&contents);
    let method = extract_pdb_method(&contents);
    Ok(PdbFileStatsNif {
        chain_count: structure.chain_count(),
        residue_count: structure.residue_count(),
        resolution,
        method,
    })
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn mmcif_file_stats(path: String) -> Result<PdbFileStatsNif, String> {
    let contents = std::fs::read_to_string(&path).map_err(|e| e.to_string())?;
    let structure = cyanea_struct::parse_mmcif(&contents).map_err(to_nif_error)?;
    let resolution = extract_mmcif_resolution(&contents);
    let method = extract_mmcif_method(&contents);
    Ok(PdbFileStatsNif {
        chain_count: structure.chain_count(),
        residue_count: structure.residue_count(),
        resolution,
        method,
    })
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn stockholm_stats(path: String) -> Result<AlignmentStatsNif, String> {
    let contents = std::fs::read_to_string(&path).map_err(|e| e.to_string())?;
    let alignments = cyanea_io::parse_stockholm(&contents).map_err(to_nif_error)?;
    let (seq_count, aln_length) = if let Some(aln) = alignments.first() {
        let sc = aln.sequences.len();
        let al = aln.sequences.first().map(|(_, s)| s.len()).unwrap_or(0);
        (sc, al)
    } else {
        (0, 0)
    };
    Ok(AlignmentStatsNif {
        sequence_count: seq_count,
        alignment_length: aln_length,
    })
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn clustal_stats(path: String) -> Result<AlignmentStatsNif, String> {
    let contents = std::fs::read_to_string(&path).map_err(|e| e.to_string())?;
    let aln = cyanea_io::parse_clustal(&contents).map_err(to_nif_error)?;
    let seq_count = aln.sequences.len();
    let aln_length = aln.sequences.first().map(|(_, s)| s.len()).unwrap_or(0);
    Ok(AlignmentStatsNif {
        sequence_count: seq_count,
        alignment_length: aln_length,
    })
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn phylip_stats(path: String) -> Result<AlignmentStatsNif, String> {
    let contents = std::fs::read_to_string(&path).map_err(|e| e.to_string())?;
    let aln = cyanea_io::parse_phylip(&contents).map_err(to_nif_error)?;
    Ok(AlignmentStatsNif {
        sequence_count: aln.n_taxa,
        alignment_length: aln.n_sites,
    })
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn bigwig_stats(path: String) -> Result<BigWigStatsNif, String> {
    let header = cyanea_io::read_bigwig_header(&path).map_err(to_nif_error)?;
    Ok(BigWigStatsNif {
        chrom_count: header.chrom_count as usize,
        total_bases: header.total_summary.bases_covered,
    })
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn bedgraph_stats(path: String) -> Result<BedGraphStatsNif, String> {
    let contents = std::fs::read_to_string(&path).map_err(|e| e.to_string())?;
    let records = cyanea_io::parse_bedgraph_str(&contents).map_err(to_nif_error)?;
    let record_count = records.len();
    let chroms: HashSet<&str> = records.iter().map(|r| r.chrom.as_str()).collect();
    let chrom_count = chroms.len();
    Ok(BedGraphStatsNif {
        record_count,
        chrom_count,
    })
}

// ===========================================================================
// Helpers
// ===========================================================================

fn extract_pdb_resolution(text: &str) -> Option<f64> {
    for line in text.lines() {
        if line.starts_with("REMARK   2 RESOLUTION.") {
            let parts: Vec<&str> = line.split_whitespace().collect();
            if parts.len() >= 4 {
                if let Ok(val) = parts[3].parse::<f64>() {
                    return Some(val);
                }
            }
        }
    }
    None
}

fn extract_pdb_method(text: &str) -> Option<String> {
    for line in text.lines() {
        if line.starts_with("EXPDTA") {
            let method = line[6..].trim().to_string();
            if !method.is_empty() {
                return Some(method);
            }
        }
    }
    None
}

fn extract_mmcif_resolution(text: &str) -> Option<f64> {
    for line in text.lines() {
        let trimmed = line.trim();
        if trimmed.starts_with("_refine.ls_d_res_high") || trimmed.starts_with("_reflns.d_resolution_high") {
            let parts: Vec<&str> = trimmed.split_whitespace().collect();
            if parts.len() >= 2 {
                if let Ok(val) = parts[1].parse::<f64>() {
                    return Some(val);
                }
            }
        }
    }
    None
}

fn extract_mmcif_method(text: &str) -> Option<String> {
    for line in text.lines() {
        let trimmed = line.trim();
        if trimmed.starts_with("_exptl.method") {
            let parts: Vec<&str> = trimmed.splitn(2, char::is_whitespace).collect();
            if parts.len() >= 2 {
                let method = parts[1].trim().trim_matches('\'').trim_matches('"').to_string();
                if !method.is_empty() {
                    return Some(method);
                }
            }
        }
    }
    None
}
