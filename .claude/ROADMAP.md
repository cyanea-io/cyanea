# Cyanea Roadmap

> From zero to the best Rust bioinformatics ecosystem + federated "GitHub for Life Sciences"

---

## Philosophy

1. **Foundations first** — Build world-class Rust libraries before/alongside the platform
2. **Federation first** — Build the distributed architecture early, not as an afterthought
3. **Artifacts over files** — Typed, versioned scientific objects with lineage
4. **Prove the loop** — MVP must demonstrate: create → publish → discover → derive → credit
5. **Community is the moat** — Social mechanics and trust are as important as features
6. **Ship early, iterate fast** — Get feedback from real users

---

## Two Tracks

Cyanea development runs on **two parallel tracks**:

```
                    2026                           2027                    2028
         Q1    Q2    Q3    Q4    Q1    Q2    Q3    Q4    Q1
         ├─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┤
LABS     │ L0  │ L1  │ L2  │ L3  │ L4  │ L5  │ L6  │     │  ← Rust ecosystem
         │core │seq  │align│omics│gpu  │wasm │ml   │     │
         ├─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┤
PLATFORM │ P0  │ P1  │ P2  │ P3  │ P4  │ P5  │ P6  │ P7  │  ← Elixir/Phoenix
         │found│ mvp │ fed │comm │life │repro│integ│scale│
         └─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┘
```

**Labs** feeds into **Platform**: as libraries mature, they power platform features.

---

# LABS TRACK: Rust Bioinformatics Ecosystem

> Goal: Build the best open-source Rust libraries for life sciences by 2027

---

## Labs 0: Core Foundation (Q1 2026)

**Goal:** Shared primitives and infrastructure

### cyanea-core

- [ ] Workspace setup (Cargo workspace, CI/CD)
- [ ] Common traits (`Sequence`, `Annotation`, `Scored`, `Named`)
- [ ] Error types with rich context (`thiserror` based)
- [ ] Content addressing primitives (SHA256, BLAKE3)
- [ ] Memory-mapped file utilities
- [ ] Streaming/iterator patterns
- [ ] Benchmarking infrastructure (criterion)
- [ ] Fuzzing setup (cargo-fuzz)
- [ ] Documentation standards

### cyanea-io (basics)

- [ ] Unified reader/writer traits
- [ ] Compression support (gzip, zstd, bz2)
- [ ] Streaming decompression
- [ ] File format detection (magic bytes)

---

## Labs 1: Sequences (Q2 2026)

**Goal:** Best-in-class sequence handling

### cyanea-seq

- [ ] **Parsers**
  - [ ] FASTA parser (zero-copy, streaming)
  - [ ] FASTQ parser (streaming, parallel)
  - [ ] GenBank parser
  - [ ] EMBL parser
- [ ] **Sequence types**
  - [ ] DNA sequence with validation
  - [ ] RNA sequence with validation
  - [ ] Protein sequence with validation
  - [ ] Alphabet traits and custom alphabets
- [ ] **Operations**
  - [ ] Reverse complement
  - [ ] Translation (codon tables)
  - [ ] K-mer iteration (canonical k-mers)
  - [ ] Minimizers
  - [ ] Motif finding
- [ ] **Quality**
  - [ ] Phred score handling
  - [ ] Quality trimming algorithms
  - [ ] Quality filtering
- [ ] **Indexing**
  - [ ] Suffix arrays
  - [ ] FM-index (basic)
  - [ ] K-mer index / hash table
- [ ] **Compression**
  - [ ] 2-bit encoding for DNA
  - [ ] Reference-based compression
- [ ] **Python bindings** (cyanea-seq-py)
  - [ ] PyO3 bindings for core types
  - [ ] NumPy integration for sequences
  - [ ] maturin packaging

### Performance Targets

| Operation | Target | Benchmark Against |
|-----------|--------|-------------------|
| FASTA parsing | 2 GB/s | needletail, BioPython |
| FASTQ parsing | 1.5 GB/s | needletail, SeqIO |
| K-mer counting (k=31) | 500 M/s | KMC, jellyfish |
| Reverse complement | 5 GB/s | seqan3 |

---

## Labs 2: Alignment (Q3 2026)

**Goal:** Fast, accurate sequence alignment (CPU + GPU)

### cyanea-align

- [ ] **Pairwise alignment**
  - [ ] Smith-Waterman (local)
  - [ ] Needleman-Wunsch (global)
  - [ ] Semi-global alignment
  - [ ] Affine gap penalties
- [ ] **Scoring**
  - [ ] BLOSUM matrices (30, 45, 62, 80, 90)
  - [ ] PAM matrices
  - [ ] Custom scoring matrices
  - [ ] DNA/RNA scoring schemes
- [ ] **SIMD acceleration**
  - [ ] SSE2/AVX2 vectorization
  - [ ] ARM NEON support
  - [ ] Striped Smith-Waterman
- [ ] **Heuristic alignment**
  - [ ] Seed-and-extend
  - [ ] Minimizer-based seeding
  - [ ] Chaining algorithms
- [ ] **Banded alignment**
  - [ ] X-drop alignment
  - [ ] Adaptive banding
- [ ] **Multiple sequence alignment (basic)**
  - [ ] Progressive alignment
  - [ ] Guide tree construction
- [ ] **Output formats**
  - [ ] CIGAR string generation
  - [ ] Alignment visualization

### Performance Targets

| Operation | Target | Benchmark Against |
|-----------|--------|-------------------|
| SW (CPU, single) | 10 GCUPS | parasail, SSW |
| SW (CPU, batch) | 50 GCUPS | SWIMD |
| SW (GPU, batch) | 500 GCUPS | NVBIO, GASAL2 |

---

## Labs 3: Omics Data Structures (Q4 2026)

**Goal:** Efficient data structures for omics data

### cyanea-omics

- [ ] **Expression matrices**
  - [ ] Dense matrix (row-major, column-major)
  - [ ] Sparse matrix (CSR, CSC)
  - [ ] Memory-mapped matrices
  - [ ] Sample and feature metadata
- [ ] **Genomic ranges**
  - [ ] Interval trees
  - [ ] Nested containment lists
  - [ ] Range operations (overlap, merge, subtract)
- [ ] **Annotations**
  - [ ] Gene annotations
  - [ ] Transcript annotations
  - [ ] Feature hierarchies (gene → transcript → exon)
- [ ] **Variants**
  - [ ] Variant representation (SNV, indel, SV)
  - [ ] Genotype encoding
  - [ ] Allele frequency calculations

### cyanea-io (extended)

- [ ] **Alignment formats**
  - [ ] SAM parser
  - [ ] BAM reader (with index)
  - [ ] CRAM reader (basic)
- [ ] **Variant formats**
  - [ ] VCF parser
  - [ ] BCF reader
- [ ] **Annotation formats**
  - [ ] BED parser
  - [ ] GFF/GTF parser
  - [ ] GenePred parser
- [ ] **Tabular formats**
  - [ ] CSV/TSV (streaming, typed)
  - [ ] Parquet reader/writer
- [ ] **Array formats**
  - [ ] HDF5 reader
  - [ ] Zarr reader

---

## Labs 4: GPU Acceleration (Q1 2027)

**Goal:** First-class GPU support for compute-heavy operations

### cyanea-gpu

- [ ] **Abstraction layer**
  - [ ] `GpuContext` trait
  - [ ] Device enumeration
  - [ ] Memory management (host/device transfers)
  - [ ] Automatic backend selection
- [ ] **CUDA backend**
  - [ ] cudarc integration
  - [ ] Custom kernel support
  - [ ] Batch operations
- [ ] **Metal backend**
  - [ ] metal-rs integration
  - [ ] Compute pipeline setup
  - [ ] Apple Silicon optimization
- [ ] **Kernels**
  - [ ] Batch Smith-Waterman
  - [ ] K-mer counting (GPU)
  - [ ] Matrix operations
  - [ ] Distance calculations
- [ ] **CPU fallback**
  - [ ] Automatic fallback when no GPU
  - [ ] Unified API regardless of backend

### cyanea-align (GPU extension)

- [ ] GPU batch alignment integration
- [ ] Automatic CPU/GPU selection based on batch size
- [ ] Memory-efficient batching for large datasets

### Performance Targets

| Operation | Target GPU | Target |
|-----------|------------|--------|
| SW batch alignment | RTX 4090 | 1 TCUPS |
| SW batch alignment | M3 Max | 200 GCUPS |
| K-mer counting | RTX 4090 | 2 B/s |

---

## Labs 5: WASM & Browser (Q2 2027)

**Goal:** Run bioinformatics in the browser

### cyanea-wasm

- [ ] **Build infrastructure**
  - [ ] wasm-pack setup
  - [ ] Feature flags for WASM builds
  - [ ] Bundle size optimization (<1MB core)
- [ ] **JavaScript bindings**
  - [ ] wasm-bindgen exports
  - [ ] TypeScript type definitions
  - [ ] Async operation support
- [ ] **Browser runtime**
  - [ ] Web Worker support
  - [ ] Streaming file handling (File API)
  - [ ] Progress callbacks
  - [ ] Memory management utilities
- [ ] **npm packages**
  - [ ] @cyanea/seq
  - [ ] @cyanea/align
  - [ ] @cyanea/io

### Browser Capabilities

| Feature | Status |
|---------|--------|
| FASTA/FASTQ parsing | Full |
| Sequence operations | Full |
| Pairwise alignment | Full |
| K-mer counting | Full |
| BAM reading | Limited (no random access) |
| GPU (WebGPU) | Future |

---

## Labs 6: Statistics & ML (Q3 2027)

**Goal:** Statistical methods and ML primitives for life sciences

### cyanea-stats

- [ ] **Descriptive statistics**
  - [ ] Streaming mean, variance, quantiles
  - [ ] Histograms and distributions
- [ ] **Hypothesis testing**
  - [ ] t-tests, ANOVA
  - [ ] Chi-square, Fisher's exact
  - [ ] Multiple testing correction (FDR, Bonferroni)
- [ ] **Dimensionality reduction**
  - [ ] PCA
  - [ ] t-SNE
  - [ ] UMAP
- [ ] **Clustering**
  - [ ] K-means
  - [ ] Hierarchical clustering
  - [ ] DBSCAN

### cyanea-ml

- [ ] **Embeddings**
  - [ ] Sequence embedding models
  - [ ] Protein language model inference
- [ ] **Classification**
  - [ ] Sequence classification
  - [ ] Feature extraction
- [ ] **ONNX runtime integration**
  - [ ] Model loading
  - [ ] Inference API

---

## Labs: Future (2027+)

### cyanea-struct

- [ ] PDB/mmCIF parsing
- [ ] Structure representation
- [ ] Distance calculations
- [ ] Secondary structure prediction
- [ ] Structure alignment

### cyanea-chem

- [ ] SMILES/InChI parsing
- [ ] Molecular fingerprints
- [ ] Substructure search
- [ ] Property calculation

### cyanea-phylo

- [ ] Newick/Nexus parsing
- [ ] Tree data structures
- [ ] Distance matrix methods
- [ ] Phylogenetic inference (basic)

---

# PLATFORM TRACK: Federated R&D Hub

> Goal: Build the federated "GitHub for Life Sciences"

---

## Platform 0: Foundation (Q1 2026)

**Goal:** Scaffolding and core infrastructure

### Completed

- [x] Project structure (Phoenix + Rust NIFs)
- [x] Docker Compose (Postgres, MinIO, Meilisearch)
- [x] Configuration (dev/test/prod)
- [x] Rust NIFs skeleton (wraps cyanea-* crates)

### In Progress

- [ ] Database migrations for new data model
  - [ ] Users, Organizations, Memberships
  - [ ] Projects (replacing Repositories)
  - [ ] Artifacts (typed: dataset, protocol, notebook, etc.)
  - [ ] ArtifactEvents (append-only event log)
  - [ ] Blobs (content-addressed storage)
  - [ ] FederationNodes
- [ ] Basic authentication (email/password)
- [ ] ORCID OAuth integration
- [ ] Guardian JWT setup
- [ ] S3 blob upload/download with content addressing
- [ ] Basic LiveView layouts

---

## Platform 1: MVP (v0.1) — Q2 2026

**Goal:** Prove federation + artifact lineage + community sharing

> "Install Cyanea Node in your lab. Keep internal work private. Publish the open parts to the Cyanea Network with one click. Others can fork, reproduce, and credit you."

**Depends on Labs:** cyanea-core, cyanea-seq (for file previews)

### Authentication & Identity

- [ ] Sign up with email/password
- [ ] Sign in with ORCID
- [ ] User profile page (name, bio, affiliation, ORCID link)
- [ ] Profile editing with avatar
- [ ] Password reset flow
- [ ] Email verification

### Organizations

- [ ] Create organization
- [ ] Organization profile page
- [ ] Invite members via email
- [ ] Member management (add/remove/change role)
- [ ] Roles: owner, admin, member, viewer
- [ ] Organization settings
- [ ] Verified badge (manual for MVP)

### Projects

- [ ] Create project (name, description, visibility, license)
- [ ] Project landing page ("card" view)
- [ ] Project settings (rename, transfer, delete)
- [ ] Visibility levels: private, internal, public
- [ ] License picker with common options
- [ ] Tags and ontology terms (free-form for MVP)

### Artifacts (Core Types)

- [ ] Create artifact (Dataset, Protocol, Notebook)
- [ ] Artifact card page (metadata, description, files)
- [ ] Artifact type-specific metadata schemas
- [ ] File browser within artifact
- [ ] Upload files to artifact (single and bulk)
- [ ] Download artifact (zip or individual files)
- [ ] Content-addressed blob storage (SHA256)

### Versioning & Lineage

- [ ] Immutable artifact versions (content hash)
- [ ] Version history view
- [ ] View artifact at specific version
- [ ] Create derivation ("fork" an artifact)
- [ ] Lineage graph visualization (parent → child)
- [ ] "Derived from" attribution on cards

### Basic Federation

- [ ] Global IDs for projects and artifacts (URI scheme)
- [ ] Node identity and configuration
- [ ] Publish artifact to hub (push)
- [ ] Publish project to hub (batch publish)
- [ ] Federation policy per project (none, selective, full)
- [ ] Basic manifest format for sync

### Discovery & Search

- [ ] Full-text search across projects/artifacts
- [ ] Search within project
- [ ] Filter by artifact type
- [ ] Filter by tags
- [ ] Search results with card previews

### Community (Basic)

- [ ] Star projects
- [ ] Watch projects (notifications placeholder)
- [ ] User activity feed
- [ ] Project activity feed

### UI/UX

- [ ] Responsive design (mobile-friendly)
- [ ] Dark/light theme
- [ ] Loading states and error handling
- [ ] Empty states with guidance
- [ ] Keyboard shortcuts (basic)

---

## Platform 2: Federation (v0.2) — Q3 2026

**Goal:** Full federation capabilities between nodes and hub

**Depends on Labs:** cyanea-core (content addressing, hashing)

### Sync Protocol

- [ ] Incremental sync (delta updates)
- [ ] Signed manifests (org/node keys)
- [ ] Conflict detection (immutable artifacts = no conflicts)
- [ ] Metadata merge strategies
- [ ] Sync status dashboard

### Hub Features

- [ ] Node registry (who's connected)
- [ ] Aggregate search across federated content
- [ ] Global artifact count/stats
- [ ] Hub admin dashboard

### Pull/Mirror

- [ ] Mirror public artifacts from hub to node
- [ ] Selective mirroring (by project, tag, org)
- [ ] Cache management for mirrored content
- [ ] Offline-first with sync on reconnect

### Cross-Node References

- [ ] Reference artifacts from other nodes (X@hash)
- [ ] Resolve cross-node lineage
- [ ] Display remote artifact cards (cached metadata)
- [ ] "View on origin" links

### Federation Policies

- [ ] Per-artifact publish rules
- [ ] Embargo dates (publish after X)
- [ ] Retraction workflow
- [ ] Access request for restricted content

---

## Platform 3: Community (v0.3) — Q4 2026

**Goal:** Social mechanics that make Cyanea feel alive

### Discussions & Annotations

- [ ] Discussions on projects
- [ ] Discussions on artifacts
- [ ] Comments on specific files/lines
- [ ] Mentions (@username)
- [ ] Markdown with preview

### Notifications

- [ ] In-app notification center
- [ ] Email notifications (configurable)
- [ ] Watch/unwatch granularity
- [ ] Digest mode (daily/weekly)

### Discovery Enhancements

- [ ] Trending projects
- [ ] Recently updated
- [ ] Featured/curated collections
- [ ] "Similar artifacts" recommendations
- [ ] Browse by organism, assay, modality

### Credits & Attribution

- [ ] Contributors list on artifacts
- [ ] Maintainer roles
- [ ] Citation generation (BibTeX, RIS)
- [ ] "Cite this" button
- [ ] Derived-from graph explorer

### Cards & Landing Pages

- [ ] Rich artifact cards (auto-generated from metadata)
- [ ] Custom card sections
- [ ] Badges (verified, reproducible, has DOI)
- [ ] Usage statistics on cards

### User Profiles

- [ ] Public profile pages
- [ ] Publication list (artifacts authored)
- [ ] Contribution graph
- [ ] Following users/orgs

---

## Platform 4: Life Sciences Features (v0.4) — Q1 2027

**Goal:** Domain-specific functionality for bioinformatics

**Depends on Labs:** cyanea-seq, cyanea-align, cyanea-omics, cyanea-io

### File Previews

- [ ] FASTA/FASTQ viewer with stats (via Rust NIF)
- [ ] CSV/TSV explorer (sort, filter, search)
- [ ] Image viewer (with zoom, pan, gallery)
- [ ] PDF viewer
- [ ] Jupyter notebook renderer
- [ ] Markdown with LaTeX support

### Protocol Editor

- [ ] Structured protocol format (YAML/JSON schema)
- [ ] Materials list with quantities
- [ ] Step-by-step procedures
- [ ] Timing and temperature annotations
- [ ] Equipment/instrument references
- [ ] Protocol versioning with diff
- [ ] Fork/adapt workflow

### Dataset Metadata

- [ ] Dataset card schema (inspired by HF)
- [ ] Column descriptions and types
- [ ] Data dictionary
- [ ] Sample/specimen relationships
- [ ] Quality metrics summary
- [ ] Known issues/caveats section

### Ontologies & Tagging

- [ ] Tag with Gene Ontology terms
- [ ] NCBI Taxonomy integration
- [ ] ChEBI (chemicals)
- [ ] EFO (experimental factors)
- [ ] Autocomplete from ontologies
- [ ] Ontology browser

### Sample Management

- [ ] Sample artifact type
- [ ] Sample metadata schema
- [ ] Sample → Dataset relationships
- [ ] Batch sample import (CSV)
- [ ] Sample lineage (derived samples)

---

## Platform 5: Reproducibility (v0.5) — Q2 2027

**Goal:** Trust through reproducibility and QC

**Depends on Labs:** cyanea-core (hashing), cyanea-stats (QC)

### Pipeline Integration

- [ ] Pipeline artifact type
- [ ] Nextflow wrapper support
- [ ] Snakemake wrapper support
- [ ] WDL/CWL support (basic)
- [ ] Container references (Docker/Singularity)
- [ ] Parameter schemas

### Run Records

- [ ] Record pipeline executions
- [ ] Capture: inputs, code hash, environment, outputs
- [ ] Link run → output artifacts
- [ ] Run comparison view
- [ ] "Reproduce this" button

### QC Gates

- [ ] Schema validation for artifacts
- [ ] Checksum verification on upload
- [ ] Basic stats checks (row count, null %, etc.)
- [ ] Custom validation rules (YAML config)
- [ ] QC badge on artifact cards

### Environment Capture

- [ ] Lockfile detection and storage
- [ ] Container image references
- [ ] Runtime environment snapshot
- [ ] Dependency graph visualization

### Attestations (Optional)

- [ ] Signed artifact manifests
- [ ] Org key management
- [ ] Verification UI
- [ ] Attestation history

### FAIR Compliance

- [ ] FAIR score calculator
- [ ] Metadata completeness check
- [ ] Persistent identifiers (DOI via DataCite)
- [ ] License clarity warnings
- [ ] FAIR improvement suggestions

---

## Platform 6: Integrations (v0.6) — Q3 2027

**Goal:** Connect to the research ecosystem

### API

- [ ] REST API v1
- [ ] GraphQL API (optional)
- [ ] API key management
- [ ] Rate limiting
- [ ] Webhooks (artifact events)
- [ ] OpenAPI documentation

### CLI

- [ ] `cyanea` CLI tool
- [ ] Login/auth flow
- [ ] Upload/download artifacts
- [ ] Clone projects
- [ ] Publish to hub
- [ ] Pull/mirror from hub
- [ ] Git-like UX where sensible

### External Services

- [ ] Zenodo sync (push datasets, get DOI)
- [ ] GenBank/UniProt linking
- [ ] PubMed paper linking
- [ ] ORCID profile sync
- [ ] GitHub import (repos → projects)

### Identity & Auth

- [ ] SAML SSO (enterprise)
- [ ] OIDC support
- [ ] Institutional login (InCommon, eduGAIN)

---

## Platform 7: Scale & Performance (v0.7) — Q4 2027

**Goal:** Handle large datasets and many nodes

**Depends on Labs:** cyanea-gpu (for compute), cyanea-wasm (for browser tools)

### Storage

- [ ] Chunked uploads for large files (>1GB)
- [ ] Resumable uploads
- [ ] Deduplication via content addressing
- [ ] Storage quotas per org
- [ ] Archive tier for cold artifacts
- [ ] Remote pointer support (don't store blob, just reference)

### Performance

- [ ] CDN for static assets and popular blobs
- [ ] Image/preview thumbnails
- [ ] Lazy loading for large artifact trees
- [ ] Pagination everywhere
- [ ] Background indexing
- [ ] Search result caching

### Infrastructure

- [ ] Kubernetes deployment (Helm chart)
- [ ] Horizontal scaling guide
- [ ] Database read replicas
- [ ] Redis for caching/sessions
- [ ] Prometheus metrics
- [ ] Grafana dashboards

### Federation Scale

- [ ] Efficient sync for large catalogs
- [ ] Partial sync (metadata only, blobs on demand)
- [ ] Sync scheduling and prioritization
- [ ] Federation health monitoring

---

## Platform 8: Enterprise (v1.0) — Q1 2028

**Goal:** Enterprise-ready, self-hosted platform

### Compliance

- [ ] Audit logs (all actions)
- [ ] Audit log export
- [ ] Retention policies
- [ ] Data deletion (GDPR)
- [ ] 21 CFR Part 11 (FDA) — future consideration

### Administration

- [ ] Admin dashboard
- [ ] User management
- [ ] Organization management
- [ ] Node configuration UI
- [ ] System health monitoring
- [ ] Backup/restore tools

### Security

- [ ] Two-factor authentication
- [ ] IP allowlisting
- [ ] Session management
- [ ] Security event logging
- [ ] Dependency vulnerability scanning

### Self-Hosted Excellence

- [ ] One-command Docker deploy
- [ ] Helm chart for Kubernetes
- [ ] Air-gapped installation support
- [ ] Upgrade path documentation
- [ ] Backup/restore guides
- [ ] Troubleshooting guide

### Sensitive Data

- [ ] PHI/PII detection warnings
- [ ] Export controls
- [ ] De-identification guidance docs
- [ ] Restricted visibility enforcement

---

## Platform 9: Intelligence (v1.x) — 2028+

**Goal:** AI-powered research assistance

**Depends on Labs:** cyanea-ml (embeddings, inference)

### Search & Discovery

- [ ] Semantic search (embeddings)
- [ ] Similar artifact recommendations
- [ ] Related protocol suggestions
- [ ] Cross-project linking suggestions

### AI Features

- [ ] Natural language queries
- [ ] Automatic metadata extraction
- [ ] Protocol summarization
- [ ] Data quality suggestions
- [ ] Anomaly detection in datasets

### Benchmarks & Challenges

- [ ] Challenge/benchmark scaffolding
- [ ] Leaderboards with reproducible runs
- [ ] Compute attestation
- [ ] Community benchmark curation

### Analytics

- [ ] Usage analytics dashboard
- [ ] Download/view statistics
- [ ] Citation tracking (if DOI)
- [ ] Impact metrics

---

## Future Ideas (Post-v1)

### Advanced Artifacts

- [ ] Model artifact type (bio ML models, HF-style)
- [ ] Registry items (plasmids, primers, antibodies)
- [ ] Instrument data integrations

### Interactive Apps

- [ ] "Spaces" — deploy visualizers/dashboards
- [ ] QC dashboard templates
- [ ] Data exploration apps
- [ ] Custom viewer plugins

### Collaboration

- [ ] Proposal/review workflow for artifact changes
- [ ] Suggested edits
- [ ] Merge requests for derived artifacts
- [ ] Real-time collaborative editing (stretch)

### Ecosystem

- [ ] Plugin/extension system
- [ ] Marketplace for templates
- [ ] Instrument integrations
- [ ] Lab notebook imports (ELN/LIMS)

---

## Milestones

### Cyanea Labs (Rust Ecosystem)

| Phase | Target | Key Deliverable | crates.io |
|-------|--------|-----------------|-----------|
| L0 | Q1 2026 | cyanea-core: traits, errors, hashing | cyanea-core |
| L1 | Q2 2026 | cyanea-seq: FASTA/FASTQ, sequences, k-mers | cyanea-seq |
| L2 | Q3 2026 | cyanea-align: SW, NW, SIMD acceleration | cyanea-align |
| L3 | Q4 2026 | cyanea-omics: matrices, ranges, VCF | cyanea-omics |
| L4 | Q1 2027 | cyanea-gpu: CUDA/Metal abstraction | cyanea-gpu |
| L5 | Q2 2027 | cyanea-wasm: browser runtime, npm packages | @cyanea/* |
| L6 | Q3 2027 | cyanea-stats, cyanea-ml: stats, embeddings | cyanea-stats |

### Cyanea Platform (Federated Hub)

| Version | Target | Key Deliverable |
|---------|--------|-----------------|
| v0.1 | Q2 2026 | MVP: Artifacts, Projects, Basic Federation, Lineage |
| v0.2 | Q3 2026 | Federation: Full sync, mirroring, cross-node refs |
| v0.3 | Q4 2026 | Community: Discussions, notifications, discovery |
| v0.4 | Q1 2027 | Life Sciences: Protocols, datasets, ontologies |
| v0.5 | Q2 2027 | Reproducibility: Pipelines, runs, QC gates |
| v0.6 | Q3 2027 | Integrations: API, CLI, Zenodo, SSO |
| v0.7 | Q4 2027 | Scale: Large files, performance, infra |
| v1.0 | Q1 2028 | Enterprise: Compliance, admin, self-hosted |

---

## Success Metrics

### Cyanea Labs

| Phase | Metric | Target |
|-------|--------|--------|
| L1 | crates.io downloads (cyanea-seq) | 1K/month |
| L2 | GitHub stars (labs repo) | 500 |
| L3 | PyPI downloads (cyanea-py) | 5K/month |
| L5 | npm downloads (@cyanea/seq) | 2K/month |
| L6 | Academic citations | 5 papers |
| All | Benchmark performance | Fastest in class |
| All | WASM bundle size | <1MB core |
| All | Test coverage | >80% |

### Cyanea Platform

#### Platform 1 (MVP)

| Metric | Target |
|--------|--------|
| Nodes installed | 10 |
| Registered users | 100 |
| Public artifacts | 200 |
| Active organizations | 20 |
| Derivations created | 50 |
| Page load time | <2s |

#### Platform 2-3 (Federation + Community)

| Metric | Target |
|--------|--------|
| Federated nodes | 50 |
| Registered users | 1,000 |
| Public artifacts | 2,000 |
| Cross-node derivations | 100 |
| Discussions created | 500 |
| Daily active users | >10% |

#### Platform 4-5 (Life Sciences + Repro)

| Metric | Target |
|--------|--------|
| Registered users | 5,000 |
| Artifacts with repro runs | 500 |
| Protocols forked | 200 |
| First DOI minted | Yes |
| QC pass rate | >80% |
| Scientific publication mention | Yes |

#### Platform 6+ (Scale)

| Metric | Target |
|--------|--------|
| Registered users | 10,000+ |
| Federated nodes | 200+ |
| Enterprise pilots | 3 |
| Self-hosted deployments | 50 |
| CLI downloads | 1,000 |

---

## Non-Goals (Deliberate Exclusions)

### Cyanea Labs

| Non-Goal | Reason |
|----------|--------|
| Rewrite every tool | Focus on core primitives first |
| Support all GPU vendors day one | CUDA + Metal first, ROCm later |
| 100% parity with established tools | Focus on common cases, iterate |
| Build workflow orchestration | Provide building blocks, not engine |
| Windows GPU support (initial) | Focus on Linux/macOS first |

### Cyanea Platform

| Non-Goal | Reason |
|----------|--------|
| Mobile native apps | PWA is sufficient |
| Sequence editor | Use SnapGene, Benchling, etc. |
| Full LIMS replacement | Focus on sharing, not inventory |
| Workflow orchestration engine | Wrap existing (Nextflow, etc.) |
| Real-time collaborative editing | Too complex, defer |
| Perfect ontology coverage | Iterate based on usage |
| Central blob storage for everything | Support pointers/remote refs |
| Automated compliance | Provide tools, not magic |

---

## Open Design Questions

Decisions to make as we build (Claude Code should propose options):

### Cyanea Labs

| Question | Phase | Considerations |
|----------|-------|----------------|
| GPU abstraction strategy | L4 | Custom trait vs wgpu vs backend-specific |
| SIMD approach | L2 | std::simd (nightly) vs simdeez vs hand-written |
| WASM async model | L5 | Blocking + Workers vs async/await |
| Error handling crate | L0 | thiserror vs anyhow vs custom |
| Python binding style | L1+ | Thin bindings vs Pythonic wrappers |
| Workspace vs multi-repo | L0 | Single Cargo workspace vs separate repos |
| Minimum Rust version | L0 | Stable vs nightly (for SIMD, etc.) |
| Benchmarking datasets | L1+ | Synthetic vs real public datasets |

### Cyanea Platform

| Question | Phase | Considerations |
|----------|-------|----------------|
| Federation protocol | P1-2 | Custom, ActivityPub-inspired, OCI-like? |
| Artifact schema strictness | P1 | Permissive MVP vs strict validation? |
| Global ID format | P1 | `cyanea://org/project/artifact@version`? |
| Event sourcing depth | P1 | Full ES vs hybrid approach? |
| Manifest format | P1-2 | JSON, protobuf, custom? |
| Sync conflict resolution | P2 | Immutable = no conflicts, but metadata? |
| Key management | P2 | HSM, platform-managed, user-managed? |
| Search federation | P2 | Centralized index vs distributed query? |
| Compute for repro runs | P5 | Self-hosted only vs managed option? |

---

## Principles

### Cyanea Labs

1. **Performance is a feature** — If it's not fast, it won't be used
2. **WASM-first thinking** — Every library should work in the browser
3. **GPU is not optional** — Number-crunching needs acceleration
4. **Coherent APIs** — Consistent patterns across all crates
5. **Zero magic** — Transparent, documented algorithms
6. **Interop matters** — Python, JS, Elixir bindings are first-class
7. **Benchmark everything** — Claims require evidence

### Cyanea Platform

1. **Federation is not optional** — Every feature should work in standalone and federated mode
2. **Artifacts have identity** — Content-addressed, globally referenceable, typed
3. **Lineage is sacred** — Never break the provenance chain
4. **Community > customers** — Researchers first, revenue second
5. **Open by default** — Make sharing easy, private when needed
6. **Design matters** — Scientists deserve beautiful tools
7. **Ship and iterate** — Perfect is the enemy of shipped
