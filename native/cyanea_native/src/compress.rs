//! Compression utilities (zstd, gzip)

use std::io::{Read, Write};

/// Compress data using zstd
pub fn zstd_compress(data: &[u8], level: i32) -> Result<Vec<u8>, String> {
    zstd::encode_all(data, level).map_err(|e| e.to_string())
}

/// Decompress zstd data
pub fn zstd_decompress(data: &[u8]) -> Result<Vec<u8>, String> {
    zstd::decode_all(data).map_err(|e| e.to_string())
}

/// Compress data using gzip
pub fn gzip_compress(data: &[u8], level: u32) -> Result<Vec<u8>, String> {
    use flate2::write::GzEncoder;
    use flate2::Compression;

    let mut encoder = GzEncoder::new(Vec::new(), Compression::new(level));
    encoder.write_all(data).map_err(|e| e.to_string())?;
    encoder.finish().map_err(|e| e.to_string())
}

/// Decompress gzip data
pub fn gzip_decompress(data: &[u8]) -> Result<Vec<u8>, String> {
    use flate2::read::GzDecoder;

    let mut decoder = GzDecoder::new(data);
    let mut decompressed = Vec::new();
    decoder.read_to_end(&mut decompressed).map_err(|e| e.to_string())?;
    Ok(decompressed)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_zstd_roundtrip() {
        let original = b"Hello, world! This is some test data for compression.";
        let compressed = zstd_compress(original, 3).unwrap();
        let decompressed = zstd_decompress(&compressed).unwrap();
        assert_eq!(original.to_vec(), decompressed);
    }
}
