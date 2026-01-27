# Cyanea

> GitHub for Life Sciences. Open source. Beautiful. Fast.

Cyanea is an open source research data platform where scientists can store datasets, protocols, experiments, and analyses. Version control everything. Collaborate within orgs/labs or publish openly. Own your data.

## Vision

**The anti-Benchling.** Where Benchling is enterprise bloat ($50k+/yr), Cyanea is fresh and fast. Where Benchling locks you in, Cyanea sets you free.

### Brand Values

| Value | What It Means |
|-------|---------------|
| **Open** | Open source. Open data. Open science. Publish by default. |
| **Fast** | Instant search. Snappy UI. No loading spinners. |
| **Beautiful** | Design matters. Scientists deserve good tools. |
| **Intuitive** | If you need a manual, we failed. |
| **Community** | Give back. Share datasets. Help each other. |

### Name Origin

Cyanea (Greek "kyanos" = dark blue). Genus of jellyfish (lion's mane) and Hawaiian plants. The jellyfish metaphor fits: distributed nervous system = networked research data.

---

## Tech Stack

| Layer | Technology | Why |
|-------|------------|-----|
| **Language** | Elixir 1.17+ | Concurrency, fault tolerance, LiveView |
| **Framework** | Phoenix 1.7+ | Real-time UI with LiveView |
| **Background Jobs** | Oban | Reliable, persistent, observable |
| **Database** | PostgreSQL 16 | JSONB, full-text search, proven |
| **File Storage** | S3-compatible | AWS S3, MinIO (self-hosted), R2 |
| **Search** | Meilisearch | Fast, typo-tolerant, self-hostable |
| **Performance** | Rust NIFs | FASTA parsing, checksums, compression |
| **Auth** | ORCID OAuth + Guardian | Researcher identity |

### Why Elixir/Phoenix?

- **Real-time collaboration** - Phoenix Channels/LiveView built for WebSockets
- **Concurrent uploads** - BEAM handles thousands of connections
- **Fault tolerance** - Supervisors restart failed processes
- **Hot code reloading** - Deploy without dropping connections

### Why Rust NIFs?

- **FASTA/FASTQ parsing** - GB-sized sequence files need native speed
- **CSV processing** - Large datasets, streaming parse
- **Checksums** - SHA256 for file integrity
- **Compression** - zstd for storage efficiency

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Browser                               │
│              Phoenix LiveView + Tailwind CSS                 │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Phoenix Application                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │  LiveView   │  │  Channels   │  │     REST API        │  │
│  │  (UI)       │  │  (Realtime) │  │  (Integrations)     │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
├─────────────────────────────────────────────────────────────┤
│                      Business Logic                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │  Contexts   │  │    Oban     │  │    Rust NIFs        │  │
│  │  (Domain)   │  │  (Jobs)     │  │  (Performance)      │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
├─────────────────────────────────────────────────────────────┤
│                       Data Layer                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │  Postgres   │  │    S3       │  │    Meilisearch      │  │
│  │  (Metadata) │  │  (Files)    │  │    (Search)         │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## Project Structure

```
cyanea/
├── lib/
│   ├── cyanea/                  # Business logic (contexts)
│   │   ├── accounts/            # Users, authentication
│   │   │   └── user.ex
│   │   ├── organizations/       # Orgs, teams, memberships
│   │   │   ├── organization.ex
│   │   │   └── membership.ex
│   │   ├── repositories/        # Repos, commits, branches
│   │   │   ├── repository.ex
│   │   │   └── commit.ex
│   │   ├── files/               # File storage, previews
│   │   │   └── file.ex
│   │   ├── search/              # Meilisearch integration
│   │   ├── application.ex       # OTP application
│   │   ├── repo.ex              # Ecto repo
│   │   └── native.ex            # Rust NIF bindings
│   └── cyanea_web/              # Web layer
│       ├── live/                # LiveView pages
│       ├── components/          # UI components
│       ├── controllers/         # API controllers
│       ├── endpoint.ex
│       └── router.ex
├── native/
│   └── cyanea_native/           # Rust NIFs
│       └── src/
│           ├── lib.rs           # NIF exports
│           ├── fasta.rs         # FASTA/FASTQ parsing
│           ├── csv_parser.rs    # CSV streaming
│           ├── hash.rs          # SHA256 checksums
│           └── compress.rs      # zstd compression
├── priv/
│   ├── repo/migrations/         # Database migrations
│   └── static/                  # Static assets
├── assets/                      # Frontend assets (Tailwind, JS)
├── config/                      # Configuration
└── test/                        # Tests
```

---

## Data Model

### Core Entities

```
User
├── id (UUID)
├── email
├── username
├── name
├── orcid_id
├── password_hash
└── timestamps

Organization
├── id (UUID)
├── name
├── slug (unique)
├── description
├── verified
└── timestamps

Membership
├── user_id → User
├── organization_id → Organization
├── role (owner | admin | member | viewer)
└── timestamps

Repository
├── id (UUID)
├── name
├── slug
├── description
├── visibility (public | private)
├── license
├── owner_id → User (nullable)
├── organization_id → Organization (nullable)
├── tags []
├── ontology_terms []
└── timestamps

Commit
├── id (UUID)
├── sha (40 chars)
├── message
├── parent_sha
├── repository_id → Repository
├── author_id → User
└── timestamps

File
├── id (UUID)
├── path
├── name
├── type (file | directory)
├── size
├── sha256
├── mime_type
├── s3_key
├── metadata (JSONB)
├── repository_id → Repository
├── commit_id → Commit
└── timestamps
```

---

## Development

### Prerequisites

- Elixir 1.17+
- PostgreSQL 16+
- Rust (for NIFs)
- Docker (optional, for MinIO/Meilisearch)

### Setup

```bash
# Start dependencies
docker compose up -d

# Install Elixir deps
mix deps.get

# Setup database
mix ecto.setup

# Start server
mix phx.server
```

### Useful Commands

```bash
# Run tests
mix test

# Format code
mix format

# Check code quality
mix credo --strict

# Generate migration
mix ecto.gen.migration add_something

# Build Rust NIFs
cd native/cyanea_native && cargo build --release
```

---

## Conventions

### Code Style

- Follow standard Elixir formatting (`mix format`)
- Use contexts for business logic (not in LiveViews)
- Keep LiveViews thin - delegate to contexts
- Use `with` for happy-path chaining
- Prefer pattern matching over conditionals

### Naming

- Contexts: singular (`Accounts`, not `Account`)
- Schemas: singular (`User`, not `Users`)
- Tables: plural (`users`, not `user`)
- LiveViews: `*Live` suffix (`RepositoryLive`)
- Components: `*Component` suffix or in `CoreComponents`

### Testing

- Unit tests for contexts
- Integration tests for LiveViews
- Use `Cyanea.DataCase` for database tests
- Use `CyaneaWeb.ConnCase` for web tests

---

## Oban Job Queues

| Queue | Purpose | Concurrency |
|-------|---------|-------------|
| `default` | Notifications, webhooks | 10 |
| `uploads` | File processing, checksums | 5 |
| `analysis` | Sequence analysis, validation | 3 |
| `exports` | Dataset exports, backups | 2 |
| `compliance` | Audit logs, reports | 5 |

---

## Environment Variables (Production)

| Variable | Description |
|----------|-------------|
| `DATABASE_URL` | PostgreSQL connection string |
| `SECRET_KEY_BASE` | Phoenix secret (64+ bytes) |
| `PHX_HOST` | Public hostname |
| `AWS_ACCESS_KEY_ID` | S3 access key |
| `AWS_SECRET_ACCESS_KEY` | S3 secret key |
| `S3_BUCKET` | S3 bucket name |
| `MEILISEARCH_URL` | Meilisearch endpoint |
| `MEILISEARCH_API_KEY` | Meilisearch API key |
| `ORCID_CLIENT_ID` | ORCID OAuth client ID |
| `ORCID_CLIENT_SECRET` | ORCID OAuth secret |

---

## Related Files

- [ROADMAP.md](.claude/ROADMAP.md) - Long-term development roadmap
- [README.md](../README.md) - Project overview
- [docker-compose.yml](../docker-compose.yml) - Local development services
