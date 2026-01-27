//! CSV parsing utilities

use csv::ReaderBuilder;
use rustler::NifStruct;
use serde_json::{json, Value};
use std::fs::File;

#[derive(Debug, NifStruct)]
#[module = "Cyanea.Native.CsvInfo"]
pub struct CsvInfo {
    pub row_count: u64,
    pub column_count: usize,
    pub columns: Vec<String>,
    pub has_headers: bool,
}

/// Parse CSV file and return metadata
pub fn parse_csv_info(path: &str) -> Result<CsvInfo, String> {
    let file = File::open(path).map_err(|e| e.to_string())?;
    let mut reader = ReaderBuilder::new()
        .has_headers(true)
        .from_reader(file);

    let headers = reader.headers().map_err(|e| e.to_string())?;
    let columns: Vec<String> = headers.iter().map(|s| s.to_string()).collect();
    let column_count = columns.len();

    let mut row_count: u64 = 0;
    for result in reader.records() {
        result.map_err(|e| e.to_string())?;
        row_count += 1;
    }

    Ok(CsvInfo {
        row_count,
        column_count,
        columns,
        has_headers: true,
    })
}

/// Parse CSV file and return first N rows as JSON
pub fn csv_preview(path: &str, limit: usize) -> Result<String, String> {
    let file = File::open(path).map_err(|e| e.to_string())?;
    let mut reader = ReaderBuilder::new()
        .has_headers(true)
        .from_reader(file);

    let headers = reader.headers().map_err(|e| e.to_string())?.clone();
    let columns: Vec<&str> = headers.iter().collect();

    let mut rows: Vec<Value> = Vec::new();

    for result in reader.records().take(limit) {
        let record = result.map_err(|e| e.to_string())?;
        let mut row = serde_json::Map::new();

        for (i, field) in record.iter().enumerate() {
            if let Some(col) = columns.get(i) {
                row.insert(col.to_string(), json!(field));
            }
        }

        rows.push(Value::Object(row));
    }

    serde_json::to_string(&json!({
        "columns": columns,
        "rows": rows
    }))
    .map_err(|e| e.to_string())
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::io::Write;
    use tempfile::NamedTempFile;

    #[test]
    fn test_csv_parsing() {
        let mut file = NamedTempFile::with_suffix(".csv").unwrap();
        writeln!(file, "name,age,city").unwrap();
        writeln!(file, "Alice,30,NYC").unwrap();
        writeln!(file, "Bob,25,LA").unwrap();

        let info = parse_csv_info(file.path().to_str().unwrap()).unwrap();
        assert_eq!(info.row_count, 2);
        assert_eq!(info.column_count, 3);
        assert_eq!(info.columns, vec!["name", "age", "city"]);
    }
}
