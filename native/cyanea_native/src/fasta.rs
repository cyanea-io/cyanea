//! FASTA/FASTQ parsing using needletail

use needletail::parse_fastx_file;
use rustler::NifStruct;

#[derive(Debug, NifStruct)]
#[module = "Cyanea.Native.FastaStats"]
pub struct FastaStats {
    pub sequence_count: u64,
    pub total_bases: u64,
    pub gc_content: f64,
    pub avg_length: f64,
}

/// Parse a FASTA/FASTQ file and return statistics
pub fn parse_fasta_stats(path: &str) -> Result<FastaStats, String> {
    let mut reader = parse_fastx_file(path).map_err(|e| e.to_string())?;

    let mut sequence_count: u64 = 0;
    let mut total_bases: u64 = 0;
    let mut gc_count: u64 = 0;

    while let Some(record) = reader.next() {
        let record = record.map_err(|e| e.to_string())?;
        let seq = record.seq();

        sequence_count += 1;
        total_bases += seq.len() as u64;

        for &base in seq.iter() {
            match base {
                b'G' | b'g' | b'C' | b'c' => gc_count += 1,
                _ => {}
            }
        }
    }

    let gc_content = if total_bases > 0 {
        (gc_count as f64 / total_bases as f64) * 100.0
    } else {
        0.0
    };

    let avg_length = if sequence_count > 0 {
        total_bases as f64 / sequence_count as f64
    } else {
        0.0
    };

    Ok(FastaStats {
        sequence_count,
        total_bases,
        gc_content,
        avg_length,
    })
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::io::Write;
    use tempfile::NamedTempFile;

    #[test]
    fn test_fasta_parsing() {
        let mut file = NamedTempFile::new().unwrap();
        writeln!(file, ">seq1").unwrap();
        writeln!(file, "ATCGATCG").unwrap();
        writeln!(file, ">seq2").unwrap();
        writeln!(file, "GCGCGCGC").unwrap();

        let stats = parse_fasta_stats(file.path().to_str().unwrap()).unwrap();
        assert_eq!(stats.sequence_count, 2);
        assert_eq!(stats.total_bases, 16);
    }
}
