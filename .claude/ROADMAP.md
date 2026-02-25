# Cyanea Platform Roadmap

> Federated "Hugging Face + GitHub for Life Sciences"

---

## Vision

Cyanea is a platform where scientists share, version, discover, and collaborate on research artifacts — **Spaces, Notebooks, Protocols, and Datasets** — with the same ease that developers use GitHub for code. Open by default, private with a Pro license, and federation-ready from day one.

### Core Principles

1. **Scientists, not developers** — No git commands, no merge conflicts, no terminal required
2. **Open by default** — All content is public unless a Pro license enables private visibility
3. **Spaces are the unit** — Everything lives inside a Space; Spaces are owned by users or orgs
4. **Versioning without git** — Append-only revision history with content-addressed snapshots
5. **Datasets scale separately** — Large data lives in object storage (S3), metadata in Postgres
6. **Federation is built-in** — Nodes can operate standalone or publish to the network
7. **Beautiful and intuitive** — Scientists deserve tools as polished as the best consumer products

---

## What We're Building

### Spaces (the top-level container)

A **Space** is the fundamental organizational unit — similar to a GitHub repository but designed for research. Every Space belongs to either a **user** or an **organization**.

A Space contains:
- **Notebooks** — Rich documents mixing prose, code, and visualizations (like Jupyter/LiveBook)
- **Protocols** — Versioned experimental procedures (wet lab or computational)
- **Datasets** — References to or hosting of research data collections
- **Files** — Any supporting files (images, configs, scripts, etc.)

Spaces have:
- A landing page (README-like card)
- Visibility: **public** (default, free) or **private** (Pro license required)
- License (CC BY 4.0, MIT, Apache 2.0, etc.)
- Tags and ontology terms for discovery
- A full revision history (every save is an immutable snapshot)
- A URL pattern: `cyanea.bio/:owner/:space-slug`

### Users and Organizations

- **Users** authenticate via ORCID (researcher identity) or email/password
- Users have profiles with bio, affiliation, ORCID link, avatar
- **Organizations** represent labs, institutions, or teams
- Org membership has roles: owner, admin, member, viewer
- Both users and orgs can own Spaces
- URL: `cyanea.bio/:username` or `cyanea.bio/:org-slug`

### Pro Tier

- **Free**: Unlimited public Spaces, unlimited collaborators
- **Pro** (user or org): Private Spaces, private Datasets, priority support
- Without Pro, all content is open and must carry a license
- Pro is the only monetization lever — no feature gating beyond visibility

---

## Architecture

### Content Model

```
User / Organization
└── Space (visibility: public | private)
    ├── Notebooks[]     — Rich documents (prose + code + viz)
    ├── Protocols[]     — Versioned experimental procedures
    ├── Datasets[]      — Data collections (metadata + blob refs)
    ├── Files[]         — Supporting files (images, scripts, etc.)
    └── RevisionHistory — Append-only snapshots of space state
```

### Versioning Model: Content-Addressed Snapshots

**No git. No branches. No merge conflicts.** Instead:

1. Every **save** creates an immutable **Revision** (a snapshot of the Space state)
2. Each Revision is content-addressed (SHA-256 of the serialized state)
3. Revisions form a linear, append-only chain (like Conflux's operation log)
4. Users can browse history, compare revisions, and restore to any point
5. Each Revision records: author, timestamp, summary (auto or user-provided), content hash
6. **Forking** a Space creates a new Space with a `forked_from` pointer (lineage, not branches)

```
Revision chain (linear, append-only):
  R1 ──→ R2 ──→ R3 ──→ R4 ──→ R5 (current)
  │       │       │       │       │
  hash1   hash2   hash3   hash4   hash5

Fork creates a new Space:
  Original: R1 → R2 → R3 → R4 → R5
                                  │
  Fork:                           └──→ F1 → F2 → F3
  (forked_from: original@R5)
```

**Why this scales:**
- No merge conflicts (linear history)
- Content deduplication via SHA-256 (same blob = same hash = stored once)
- Revision metadata is tiny (Postgres); blob content is in S3
- Can evolve toward CRDT-based collaborative editing later without changing the storage model
- Federation is simple: sync revision chains between nodes

### Storage Architecture

```
┌──────────────────────────────────────────────────────────┐
│                     PostgreSQL                            │
│                                                          │
│  users, orgs, memberships, spaces, notebooks, protocols  │
│  datasets (metadata), revisions, stars, discussions       │
│  tags, licenses, federation_nodes, manifests              │
│                                                          │
│  Everything except file content lives here               │
└──────────────────────────────────────────────────────────┘
                          │
                          ▼
┌──────────────────────────────────────────────────────────┐
│              S3-Compatible Object Storage                 │
│              (MinIO / AWS S3 / Cloudflare R2)            │
│                                                          │
│  Content-addressed blobs:                                │
│    blobs/{sha256-prefix}/{sha256}                        │
│                                                          │
│  Dataset files, notebook attachments, protocol assets,   │
│  uploaded images, any file > 0 bytes                     │
│                                                          │
│  Deduplicated: same content = same hash = stored once    │
└──────────────────────────────────────────────────────────┘
                          │
                          ▼
┌──────────────────────────────────────────────────────────┐
│                    Meilisearch                            │
│                                                          │
│  Full-text search across:                                │
│    spaces, notebooks, protocols, datasets, users, orgs   │
│                                                          │
│  Faceted filtering by tags, organism, assay type, etc.   │
└──────────────────────────────────────────────────────────┘
```

### Dataset Storage Strategy

Datasets are the largest content type and need special handling:

1. **Metadata** lives in Postgres (name, description, schema, column info, tags, license, stats)
2. **Files** live in S3, content-addressed by SHA-256
3. **External references** supported — a Dataset can point to data hosted elsewhere (e.g., an S3 bucket, a public URL, an FTP server, another Cyanea node) without Cyanea storing the actual bytes
4. **Chunked uploads** for large files (multipart upload to S3)
5. **Streaming downloads** via presigned URLs (never proxy through the app server)
6. **Preview** — first N rows / summary statistics stored as metadata for instant rendering

### Background Processing (Oban)

| Queue | Purpose | Concurrency |
|-------|---------|-------------|
| `default` | Notifications, webhooks, emails | 10 |
| `uploads` | File processing, SHA-256 hashing, S3 upload, metadata extraction | 5 |
| `indexing` | Meilisearch indexing, dataset stats computation | 5 |
| `federation` | Sync, publish, mirror operations | 5 |
| `exports` | Dataset exports, DOI minting, zip generation | 2 |

---

## Data Model

### Core Entities

```
User
├── id (UUID)
├── email, username, display_name
├── orcid_id (optional)
├── password_hash
├── bio, affiliation, avatar_url, website
├── plan (free | pro)
├── confirmed_at
└── timestamps

Organization
├── id (UUID)
├── name, slug (unique)
├── description, avatar_url, website, location
├── plan (free | pro)
├── verified (institution verification)
└── timestamps

Membership
├── user_id → User
├── organization_id → Organization
├── role (owner | admin | member | viewer)
└── timestamps

Space
├── id (UUID)
├── name, slug
├── description
├── visibility (public | private)
├── license (spdx identifier)
├── tags[] (text array)
├── owner_type + owner_id (polymorphic: User or Organization)
├── forked_from_id → Space (nullable, for forks)
├── fork_count, star_count (counter cache)
├── current_revision_id → Revision
├── global_id (federation URI)
└── timestamps

Revision
├── id (UUID)
├── space_id → Space
├── parent_revision_id → Revision (nullable, first revision has none)
├── content_hash (SHA-256 of serialized state)
├── summary (user-provided or auto-generated)
├── author_id → User
├── number (sequential within space, for display: "v12")
└── created_at (immutable)

Notebook
├── id (UUID)
├── space_id → Space
├── title, slug
├── content (JSONB — cell array: markdown, code, output)
├── position (ordering within space)
└── timestamps

Protocol
├── id (UUID)
├── space_id → Space
├── title, slug
├── description
├── content (JSONB — structured steps, materials, equipment)
├── version (semver string)
├── position (ordering within space)
└── timestamps

Dataset
├── id (UUID)
├── space_id → Space
├── name, slug
├── description
├── storage_type (hosted | external)
├── external_url (for external datasets)
├── metadata (JSONB — schema, column info, row count, size, stats)
├── tags[]
├── position (ordering within space)
└── timestamps

DatasetFile (join: Dataset ↔ Blob)
├── dataset_id → Dataset
├── blob_id → Blob
├── path (file path within dataset)
├── size
└── timestamps

Blob (content-addressed, deduplicated)
├── id (UUID)
├── sha256 (unique)
├── size
├── mime_type
├── s3_key
└── created_at

SpaceFile (files directly in a Space, not in a Dataset)
├── id (UUID)
├── space_id → Space
├── blob_id → Blob
├── path
├── name
└── timestamps

Star
├── user_id → User
├── space_id → Space
├── unique(user_id, space_id)
└── created_at

Discussion
├── id (UUID)
├── space_id → Space
├── author_id → User
├── title
├── body (markdown)
├── status (open | closed)
└── timestamps

Comment
├── id (UUID)
├── discussion_id → Discussion
├── author_id → User
├── body (markdown)
├── parent_comment_id → Comment (nullable, for threading)
└── timestamps

ActivityEvent (append-only feed)
├── id (UUID)
├── actor_id → User
├── action (created_space | forked_space | starred | published_dataset | ...)
├── subject_type + subject_id (polymorphic)
├── metadata (JSONB)
└── created_at

FederationNode (existing, keep as-is)
Manifest (existing, keep as-is — adapted to reference Spaces instead of Artifacts)
SyncEntry (existing, keep as-is)
```

### Key Design Decisions

**Polymorphic ownership:** `Space.owner_type` + `Space.owner_id` replaces the XOR constraint on `owner_id` / `organization_id`. Simpler queries, same semantics.

**JSONB for structured content:** Notebook cells, Protocol steps, and Dataset metadata use JSONB columns. This avoids premature schema rigidity while keeping everything in Postgres for transactional consistency. We can add dedicated tables later if query patterns demand it.

**Blobs are deduplicated:** The `Blob` table is keyed by SHA-256. When a file is uploaded, we compute its hash; if a Blob with that hash exists, we reuse it. This is critical for forked Spaces and shared datasets.

**Counter caches:** `star_count` and `fork_count` on Space avoid COUNT queries. Updated via Ecto.Multi in the star/fork operations.

**Revisions are lightweight:** A Revision is just a pointer (content_hash) + metadata (author, timestamp, summary). The actual state is reconstructable from the current Notebooks, Protocols, Datasets, and Files belonging to the Space. For space-efficient history, revision snapshots store only what changed (delta compression is a future optimization).

---

## Phased Roadmap

### Current State (What's Already Built)

**Fully implemented:**
- User authentication (email/password + ORCID OAuth, Guardian JWT)
- Organization management with role-based access (owner/admin/member/viewer)
- Repository CRUD with file upload to S3 (to be renamed to Space)
- Artifact versioning with lineage tracking and event audit trail
- Federation schema (global IDs, manifests, sync entries)
- File storage (S3-compatible, content-addressed, presigned URLs)
- Search integration (Meilisearch with DB fallback)
- 14 LiveView pages (auth, dashboard, repo, artifact, org, explore, home)
- 200+ Rust NIF stubs (all documented, SHA-256 hashing active)
- Oban configured (5 queues, no workers yet)
- Docker Compose (Postgres, MinIO, Meilisearch)
- Dockerfile + fly.toml for production deployment

**What needs to change:**
- Rename "Repository" → "Space" throughout
- Replace "Artifact" with first-class Notebook, Protocol, Dataset types
- Replace git-like commit model with append-only revision history
- Add Pro tier and visibility enforcement
- Add community features (stars, forks, discussions, activity feed)
- Build Oban workers for background processing
- Build the notebook editor UI

---

### Phase 1: Spaces Foundation (v0.1)

> **Goal:** Replace the Repository/Artifact model with the Space-centric architecture. Get the core CRUD and ownership model working.

#### Database Migration

- [ ] Rename `repositories` table → `spaces`
- [ ] Add `owner_type` column (replace XOR constraint)
- [ ] Add `forked_from_id`, `fork_count`, `star_count` columns
- [ ] Add `current_revision_id` column
- [ ] Add `global_id` column
- [ ] Create `revisions` table (id, space_id, parent_revision_id, content_hash, summary, author_id, number, created_at)
- [ ] Create `notebooks` table (id, space_id, title, slug, content JSONB, position)
- [ ] Create `protocols` table (id, space_id, title, slug, description, content JSONB, version, position)
- [ ] Create `datasets` table (id, space_id, name, slug, description, storage_type, external_url, metadata JSONB, tags[], position)
- [ ] Create `dataset_files` join table
- [ ] Create `blobs` table (id, sha256 unique, size, mime_type, s3_key)
- [ ] Create `space_files` table (direct file attachments)
- [ ] Create `stars` table (user_id, space_id, unique)
- [ ] Drop or migrate `repositories`, `commits`, `artifacts`, `artifact_events`, `artifact_files` tables

#### Contexts

- [ ] `Spaces` context — CRUD, visibility filtering, ownership checks, fork, slug generation
- [ ] `Notebooks` context — CRUD within a Space, cell manipulation, ordering
- [ ] `Protocols` context — CRUD, versioning (semver bump), fork/adapt
- [ ] `Datasets` context — CRUD, hosted vs external, metadata management
- [ ] `Blobs` context — Content-addressed upload, deduplication, presigned URLs
- [ ] `Revisions` context — Create snapshot, list history, compare, restore
- [ ] `Stars` context — Star/unstar, list starred, count
- [ ] Update `Search` context for new entity types
- [ ] Update `Federation` context for Spaces (global IDs, manifests)

#### LiveViews

- [ ] `SpaceLive.Show` — Space landing page (README card, notebooks/protocols/datasets listing, file browser, star button, fork button)
- [ ] `SpaceLive.New` — Create Space form (name, slug, description, visibility, license, owner picker for orgs)
- [ ] `SpaceLive.Settings` — Edit Space metadata, transfer ownership, delete, visibility toggle (Pro gate)
- [ ] `DashboardLive` — Updated for Spaces (user's spaces + starred + org spaces)
- [ ] `ExploreLive` — Updated for Spaces, faceted search
- [ ] `UserLive.Show` — Updated profile (spaces, stars, activity)
- [ ] Rename all route paths from `/:username/:repo-slug` → `/:owner/:space-slug`

#### Background Workers (Oban)

- [ ] `BlobHashWorker` — Compute SHA-256 for uploaded files, deduplicate
- [ ] `SearchIndexWorker` — Index spaces, notebooks, protocols, datasets in Meilisearch
- [ ] `RevisionWorker` — Create revision snapshot after save operations
- [ ] `MetadataExtractionWorker` — Extract dataset stats (row count, columns, preview) from uploaded files via NIFs

---

### Phase 2: Content Types (v0.2)

> **Goal:** Build the notebook editor, protocol editor, and dataset management UI.

#### Notebooks

- [ ] Notebook editor LiveView — Rich cell-based editor
  - [ ] Markdown cells with live preview
  - [ ] Code cells with syntax highlighting (Elixir, Python, R, Rust)
  - [ ] Output cells (text, tables, images — view-only for MVP)
  - [ ] Cell reordering (drag-and-drop or up/down buttons)
  - [ ] Cell add/delete
  - [ ] Auto-save with revision creation
- [ ] Notebook viewer — Read-only rendered view for public notebooks
- [ ] Notebook forking — Fork a notebook into your own Space
- [ ] Export — Download as .ipynb (Jupyter) or .livemd (LiveBook)

#### Protocols

- [ ] Protocol editor LiveView — Structured editor
  - [ ] Title, description, version
  - [ ] Materials section (name, quantity, vendor, catalog number)
  - [ ] Equipment section (name, settings, calibration notes)
  - [ ] Steps section (ordered, with timing, temperature, notes, images)
  - [ ] Tips and troubleshooting section
- [ ] Protocol viewer — Beautiful rendered view
- [ ] Protocol versioning — Bump version, view diff between versions
- [ ] Protocol forking — Fork and adapt, with attribution to original

#### Datasets

- [ ] Dataset upload flow
  - [ ] Drag-and-drop file upload (chunked for large files)
  - [ ] Multi-file upload (zip or individual)
  - [ ] Progress indicator with cancel
  - [ ] Auto-detection of file format (CSV, TSV, FASTA, VCF, BED, etc.)
- [ ] Dataset metadata editor
  - [ ] Description, tags, license
  - [ ] Column descriptions (for tabular data)
  - [ ] Schema definition (types, constraints)
  - [ ] Known issues / caveats
- [ ] Dataset preview
  - [ ] Tabular preview (first 100 rows, sortable, filterable)
  - [ ] FASTA/FASTQ preview (sequence stats via NIF)
  - [ ] VCF preview (variant summary via NIF)
  - [ ] File listing with sizes and types
- [ ] External dataset references
  - [ ] URL-based reference (S3, HTTP, FTP)
  - [ ] Metadata-only card (no blob storage)
  - [ ] Availability checking (periodic health check)
- [ ] Dataset download
  - [ ] Individual file download (presigned URL)
  - [ ] Full dataset download (zip generation via Oban)

---

### Phase 3: Community & Discovery (v0.3)

> **Goal:** Social mechanics that make the platform feel alive and useful for discovery.

#### Stars & Forks

- [ ] Star a Space (toggle, counter cache update)
- [ ] Fork a Space (deep copy: notebooks, protocols, dataset refs, files)
- [ ] Fork count display
- [ ] "Forked from" attribution link
- [ ] List of forks on original Space
- [ ] Starred Spaces on user profile

#### Discussions

- [ ] Discussion list on Space page (tab)
- [ ] Create discussion (title + markdown body)
- [ ] Threaded comments (one level of nesting)
- [ ] Markdown with preview and @mentions
- [ ] Close/reopen discussions
- [ ] Discussion count badge on Space card

#### Activity Feed

- [ ] Global activity feed on Explore page
- [ ] Per-Space activity feed (tab)
- [ ] Per-User activity feed (profile page)
- [ ] Event types: created_space, forked_space, starred, created_notebook, updated_protocol, published_dataset, commented, etc.
- [ ] Pagination with infinite scroll

#### Discovery & Search

- [ ] Full-text search across all content types
- [ ] Faceted filtering: tags, organism, assay type, data modality, license
- [ ] Trending Spaces (by recent stars)
- [ ] Recently updated Spaces
- [ ] Featured/curated collections (admin-managed)
- [ ] "Similar Spaces" recommendations (tag overlap)
- [ ] Browse by organism taxonomy

#### Notifications

- [ ] In-app notification center
- [ ] Notification types: starred, forked, new discussion, new comment, mention
- [ ] Read/unread state
- [ ] Email notifications (configurable per-type)
- [ ] Watch/unwatch a Space

#### User Profiles

- [ ] Enhanced public profile page
- [ ] Contribution graph (activity heatmap)
- [ ] Pinned Spaces (user-selected highlights)
- [ ] Following users/orgs
- [ ] Follower/following counts

---

### Phase 4: Pro Tier & Billing (v0.4)

> **Goal:** Monetization through private visibility.

#### Subscription Model

- [ ] Pro tier for users ($9/month or $89/year — TBD)
- [ ] Pro tier for organizations ($25/month per seat or similar — TBD)
- [ ] Stripe integration (Checkout, Customer Portal, Webhooks)
- [ ] Plan field on User and Organization schemas
- [ ] Grace period on downgrade (Spaces become read-only, not deleted)

#### Visibility Enforcement

- [ ] Private Spaces require Pro plan on owner
- [ ] Visibility change (public → private) checks Pro status
- [ ] Downgrade handling: private Spaces become read-only until upgraded or made public
- [ ] "Upgrade to Pro" prompts in UI when trying to create private Space

#### Storage Quotas

- [ ] Free tier: 5 GB storage per user, 10 GB per org
- [ ] Pro tier: 50 GB per user, 200 GB per org (TBD)
- [ ] Usage tracking and dashboard
- [ ] Warning at 80%, block uploads at 100%

---

### Phase 5: Federation (v0.5)

> **Goal:** Full federation between Cyanea nodes and the public hub.

#### Publishing

- [ ] Publish a Space to the public network (one-click)
- [ ] Selective publishing (choose which notebooks/protocols/datasets to include)
- [ ] Unpublish / retract with reason
- [ ] Federation policy per Space (none | selective | full)
- [ ] Publishing creates a signed Manifest

#### Sync Protocol

- [ ] Incremental revision sync (send new revisions since last sync)
- [ ] Content-addressed blob sync (only transfer missing blobs)
- [ ] Manifest exchange for discovery (lightweight metadata)
- [ ] Sync status dashboard (per-node)
- [ ] Retry with exponential backoff on failure

#### Discovery Across Nodes

- [ ] Aggregate search across federated content
- [ ] Display remote Spaces with "View on origin" link
- [ ] Cross-node fork (fork a Space from another node)
- [ ] Cross-node lineage display

#### Node Administration

- [ ] Register/deregister federated nodes
- [ ] Node health monitoring
- [ ] Sync log and audit trail
- [ ] Bandwidth and storage metrics per node

---

### Phase 6: Life Sciences Features (v0.6)

> **Goal:** Domain-specific functionality powered by Cyanea Labs NIFs.

#### File Previews (NIF-Powered)

- [ ] FASTA/FASTQ viewer with stats (sequence count, GC%, quality distribution)
- [ ] VCF variant browser (summary stats, variant type breakdown)
- [ ] BED/GFF3 interval viewer (region browser)
- [ ] CSV/TSV explorer (sort, filter, paginate)
- [ ] PDB structure viewer (3D via WASM or embedded viewer)
- [ ] Image viewer (zoom, pan, gallery)
- [ ] PDF renderer
- [ ] Markdown with LaTeX (KaTeX)

#### Ontology Integration

- [ ] Tag Spaces with Gene Ontology terms
- [ ] NCBI Taxonomy organism picker
- [ ] EFO (experimental factors) tagging
- [ ] Autocomplete from ontology databases
- [ ] Ontology-aware search filtering

#### Citations & Attribution

- [ ] "Cite this Space" button (BibTeX, RIS, APA)
- [ ] DOI minting via DataCite (for published Spaces)
- [ ] Contributors list with ORCID links
- [ ] "Derived from" lineage graph explorer
- [ ] FAIR score indicator

---

### Phase 7: Advanced Notebooks (v0.7)

> **Goal:** Move from view+edit to interactive execution.

#### Browser Execution (WASM)

- [ ] Execute code cells client-side via cyanea-wasm
- [ ] Supported operations: sequence analysis, alignment, statistics, k-mer counting
- [ ] Output rendering: text, tables, basic charts
- [ ] Execution state management (cell dependencies)
- [ ] Performance: background execution via Web Workers

#### Server Execution (Future)

- [ ] Elixir code cell execution (sandboxed, via NIF bridge)
- [ ] Python cell execution (containerized, via Oban worker)
- [ ] Resource limits (CPU time, memory)
- [ ] Execution queue with priority

---

### Phase 8: API, CLI & Integrations (v0.8)

> **Goal:** Programmatic access and ecosystem connectivity.

#### REST API

- [ ] API v1 with OpenAPI spec
- [ ] API key management (per-user)
- [ ] Rate limiting (per-key)
- [ ] Endpoints: spaces, notebooks, protocols, datasets, users, orgs, search
- [ ] Webhooks for space events (created, updated, published, starred, forked)

#### CLI Tool

- [ ] `cyanea` CLI (Rust binary or Elixir escript)
- [ ] Login/auth flow (browser-based OAuth)
- [ ] Upload datasets from command line
- [ ] Download spaces/datasets
- [ ] Publish to network
- [ ] Search from terminal

#### External Integrations

- [ ] Zenodo sync (push datasets, receive DOI)
- [ ] ORCID profile sync (pull publications)
- [ ] PubMed/DOI linking on Spaces
- [ ] GitHub import (convert repo → Space)
- [ ] Jupyter notebook import (.ipynb → Cyanea notebook)

---

## Migration Strategy (Repository → Space)

The existing codebase has "Repositories" and "Artifacts." Here's how to migrate:

### Step 1: Rename in Code

- Rename `Cyanea.Repositories` context → `Cyanea.Spaces`
- Rename `Cyanea.Repositories.Repository` schema → `Cyanea.Spaces.Space`
- Rename all LiveViews: `RepositoryLive.*` → `SpaceLive.*`
- Update router paths: `/:username/:slug` routes point to SpaceLive
- Update templates and components

### Step 2: Database Migration

- Rename `repositories` table → `spaces` (ALTER TABLE RENAME)
- Add new columns (`owner_type`, `forked_from_id`, `fork_count`, `star_count`, `current_revision_id`, `global_id`)
- Create new tables (revisions, notebooks, protocols, datasets, blobs, stars, discussions, comments, activity_events)
- Migrate data from `artifacts` → appropriate new tables based on artifact type
- Drop old tables (artifacts, artifact_events, artifact_files, commits)

### Step 3: Context Rewrite

- `Spaces` context replaces `Repositories` + `Artifacts`
- New contexts: `Notebooks`, `Protocols`, `Datasets`, `Blobs`, `Revisions`, `Stars`, `Discussions`, `ActivityFeed`
- Update `Search` context for new entity types
- Update `Federation` context for Space-based global IDs

### Step 4: UI Update

- New Space landing page with tabs (Overview, Notebooks, Protocols, Datasets, Files, Discussions, Activity)
- New editors for Notebooks and Protocols
- Updated Dashboard (spaces, starred, activity)
- Updated Explore page (search across all content types)

---

## Notebook Content Schema (JSONB)

```json
{
  "cells": [
    {
      "id": "uuid",
      "type": "markdown",
      "source": "# Introduction\n\nThis notebook demonstrates..."
    },
    {
      "id": "uuid",
      "type": "code",
      "language": "python",
      "source": "import cyanea\nresult = cyanea.seq.gc_content('ATCGATCG')\nprint(result)",
      "outputs": [
        {
          "type": "text",
          "content": "0.5"
        }
      ]
    },
    {
      "id": "uuid",
      "type": "code",
      "language": "elixir",
      "source": "Cyanea.Native.dna_gc_content(\"ATCGATCG\")",
      "outputs": []
    }
  ]
}
```

## Protocol Content Schema (JSONB)

```json
{
  "materials": [
    {
      "name": "TRIzol Reagent",
      "quantity": "1 mL per 10^7 cells",
      "vendor": "Thermo Fisher",
      "catalog": "15596026"
    }
  ],
  "equipment": [
    {
      "name": "Centrifuge",
      "settings": "12,000 × g, 4°C"
    }
  ],
  "steps": [
    {
      "number": 1,
      "title": "Cell Lysis",
      "description": "Add 1 mL TRIzol per 10^7 cells. Pipet up and down to lyse.",
      "duration": "5 min",
      "temperature": "room temperature",
      "notes": "Work in a fume hood.",
      "images": []
    }
  ],
  "tips": [
    "Keep samples on ice between steps.",
    "Use RNase-free tubes and filter tips."
  ]
}
```

---

## URL Structure

```
/                                           → Home / landing
/explore                                    → Discover spaces, search
/dashboard                                  → User's spaces, starred, activity
/new                                        → Create new Space
/settings                                   → User settings
/notifications                              → Notification center

/:owner                                     → User or Org profile
/:owner/:space                              → Space landing page
/:owner/:space/notebooks/:slug              → Notebook viewer/editor
/:owner/:space/protocols/:slug              → Protocol viewer/editor
/:owner/:space/datasets/:slug               → Dataset viewer
/:owner/:space/files/*path                  → File browser / viewer
/:owner/:space/discussions                  → Discussions list
/:owner/:space/discussions/:id              → Discussion thread
/:owner/:space/history                      → Revision history
/:owner/:space/settings                     → Space settings
/:owner/:space/fork                         → Fork action

/organizations/new                          → Create org
/organizations/:slug/settings               → Org settings
/organizations/:slug/members                → Org member management

/auth/login                                 → Login
/auth/register                              → Register
/auth/orcid                                 → ORCID OAuth
```

---

## Tech Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Framework | Phoenix 1.8 + LiveView 1.0 | Real-time UI, server-rendered, no SPA complexity |
| Database | PostgreSQL 16 | JSONB for flexible schemas, proven reliability |
| Object storage | S3-compatible (ExAws) | MinIO for self-hosted, AWS S3 / R2 for cloud |
| Search | Meilisearch | Fast, typo-tolerant, self-hostable, faceted filtering |
| Background jobs | Oban | Reliable, persistent, observable, Elixir-native |
| Auth | ORCID OAuth + email/password + Guardian JWT | Researcher identity standard |
| Compute | Rustler NIFs (cyanea-native) | Parsing, hashing, alignment, stats — native speed |
| Browser compute | cyanea-wasm | Client-side file preview, notebook execution |
| Payments | Stripe | Checkout, subscriptions, customer portal |
| Email | Swoosh | Elixir-native, multiple adapters |
| Rich text | Markdown + LiveView | No WYSIWYG complexity, familiar to scientists |
| Deployment | Fly.io + Docker | Easy self-hosting, managed option |

---

## Success Metrics

### Phase 1-2 (Foundation + Content)

| Metric | Target |
|--------|--------|
| Registered users | 100 |
| Public Spaces | 200 |
| Active organizations | 20 |
| Notebooks created | 100 |
| Protocols shared | 50 |
| Datasets uploaded | 50 |
| Page load time | < 2s |

### Phase 3-4 (Community + Pro)

| Metric | Target |
|--------|--------|
| Registered users | 1,000 |
| Public Spaces | 2,000 |
| Forks created | 200 |
| Discussions | 500 |
| Pro subscribers | 50 |
| MRR | $500 |

### Phase 5-6 (Federation + Life Sciences)

| Metric | Target |
|--------|--------|
| Registered users | 5,000 |
| Federated nodes | 20 |
| Cross-node forks | 50 |
| DOIs minted | 10 |
| First academic citation | Yes |

---

## Non-Goals (Deliberate Exclusions)

| Non-Goal | Reason |
|----------|--------|
| Git as user-facing abstraction | Too technical for target audience |
| Real-time collaborative editing (Phase 1-4) | Too complex; revisit with CRDTs later |
| Full LIMS/ELN replacement | Focus on sharing and discovery, not inventory |
| Workflow orchestration engine | Wrap existing tools (Nextflow, Snakemake) |
| Mobile native apps | PWA is sufficient |
| Sequence editor | Use specialized tools (SnapGene, Benchling) |
| Central blob storage for all data | Support external references for large public datasets |
| Automated compliance | Provide tools and warnings, not magic |
