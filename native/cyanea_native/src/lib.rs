//! Cyanea Native - Rust NIFs for high-performance file processing
//!
//! This crate provides native Elixir functions for:
//! - FASTA/FASTQ parsing
//! - CSV streaming
//! - SHA256 checksums
//! - zstd compression

mod csv_parser;
mod fasta;
mod hash;
mod compress;

use rustler::{Env, Term};

rustler::init!("Elixir.Cyanea.Native");

/// Calculate SHA256 hash of binary data
#[rustler::nif]
fn sha256(data: Vec<u8>) -> String {
    hash::sha256(&data)
}

/// Calculate SHA256 hash of a file by path
#[rustler::nif]
fn sha256_file(path: String) -> Result<String, String> {
    hash::sha256_file(&path)
}

/// Compress data using zstd
#[rustler::nif]
fn zstd_compress(data: Vec<u8>, level: i32) -> Result<Vec<u8>, String> {
    compress::zstd_compress(&data, level)
}

/// Decompress zstd data
#[rustler::nif]
fn zstd_decompress(data: Vec<u8>) -> Result<Vec<u8>, String> {
    compress::zstd_decompress(&data)
}

/// Parse FASTA file and return sequence count and total bases
#[rustler::nif(schedule = "DirtyCpu")]
fn fasta_stats(path: String) -> Result<fasta::FastaStats, String> {
    fasta::parse_fasta_stats(&path)
}

/// Parse CSV file and return row count and column names
#[rustler::nif(schedule = "DirtyCpu")]
fn csv_info(path: String) -> Result<csv_parser::CsvInfo, String> {
    csv_parser::parse_csv_info(&path)
}

/// Parse CSV file and return first N rows as JSON
#[rustler::nif(schedule = "DirtyCpu")]
fn csv_preview(path: String, limit: usize) -> Result<String, String> {
    csv_parser::csv_preview(&path, limit)
}
