# Cyanea

> GitHub for Life Sciences. Open source. Beautiful. Fast.

Cyanea is an open source research data platform for life sciences. Store datasets, protocols, experiments, and analyses. Version control everything. Collaborate openly.

## Features

- **Repositories** - Git-like versioning for research data
- **Organizations** - Labs, institutions, teams
- **Files** - Upload, preview, download datasets
- **Versioning** - Full commit history, diffs, restore
- **Search** - Full-text search across all content
- **ORCID** - Authenticate with your researcher identity

## Tech Stack

| Layer | Technology |
|-------|------------|
| Language | Elixir 1.17+ |
| Framework | Phoenix 1.7+ with LiveView |
| Database | PostgreSQL 16 |
| Background Jobs | Oban |
| File Storage | S3-compatible (AWS, MinIO, R2) |
| Search | Meilisearch |
| Performance | Rust NIFs (FASTA parsing, checksums, compression) |

## Development

### Prerequisites

- Elixir 1.17+
- PostgreSQL 16+
- Rust (for NIFs)
- MinIO (local S3)
- Meilisearch

### Setup

```bash
# Install dependencies
mix setup

# Start the server
mix phx.server
```

Now visit [`localhost:4000`](http://localhost:4000).

### Docker Compose (recommended)

```bash
docker compose up -d
mix setup
mix phx.server
```

## Project Structure

```
cyanea/
├── lib/
│   ├── cyanea/              # Business logic
│   │   ├── accounts/        # Users, authentication
│   │   ├── organizations/   # Orgs, memberships
│   │   ├── repositories/    # Repos, commits
│   │   ├── files/           # File storage
│   │   ├── search/          # Meilisearch integration
│   │   └── native.ex        # Rust NIF bindings
│   └── cyanea_web/          # Web layer
│       ├── live/            # LiveView pages
│       ├── components/      # UI components
│       └── controllers/     # API controllers
├── native/
│   └── cyanea_native/       # Rust NIFs
│       └── src/
│           ├── lib.rs
│           ├── fasta.rs     # FASTA/FASTQ parsing
│           ├── csv_parser.rs
│           ├── hash.rs      # SHA256
│           └── compress.rs  # zstd
├── priv/
│   ├── repo/migrations/     # Database migrations
│   └── static/              # Static assets
└── config/                  # Configuration
```

## License

MIT License - see [LICENSE.md](LICENSE.md)
