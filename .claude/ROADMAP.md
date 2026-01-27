# Cyanea Roadmap

> From zero to GitHub for Life Sciences

---

## Phase 0: Foundation (Current)

**Goal:** Scaffolding and core infrastructure

- [x] Project structure (Phoenix + Rust NIFs)
- [x] Database schemas (User, Org, Repo, File, Commit)
- [x] Docker Compose (Postgres, MinIO, Meilisearch)
- [x] Configuration (dev/test/prod)
- [ ] Database migrations
- [ ] Basic authentication (email/password)
- [ ] ORCID OAuth integration
- [ ] Guardian JWT setup
- [ ] S3 file upload/download
- [ ] Basic LiveView layouts

---

## Phase 1: MVP (v0.1)

**Goal:** Usable product for early adopters

### Authentication & Users

- [ ] Sign up with email/password
- [ ] Sign in with ORCID
- [ ] User profile page
- [ ] Profile editing (name, bio, affiliation, avatar)
- [ ] Password reset flow
- [ ] Email verification

### Organizations

- [ ] Create organization
- [ ] Organization profile page
- [ ] Invite members via email
- [ ] Member management (add/remove/change role)
- [ ] Role-based permissions (owner, admin, member, viewer)
- [ ] Organization settings

### Repositories

- [ ] Create repository (name, description, visibility)
- [ ] Repository landing page
- [ ] File browser (tree view)
- [ ] File upload (single and bulk)
- [ ] File download
- [ ] File preview (images, markdown, CSV, text)
- [ ] Delete repository
- [ ] Transfer ownership

### Versioning

- [ ] Commit on file upload
- [ ] Commit history view
- [ ] View file at specific commit
- [ ] Diff view (text files)
- [ ] Restore previous version

### Search

- [ ] Full-text search across repositories
- [ ] Search within repository
- [ ] Filter by file type
- [ ] Search in file contents

### UI/UX

- [ ] Responsive design (mobile-friendly)
- [ ] Dark/light theme
- [ ] Keyboard shortcuts
- [ ] Command palette (Cmd+K)
- [ ] Loading states and error handling
- [ ] Empty states

---

## Phase 2: Collaboration (v0.2)

**Goal:** Multi-user workflows

### Teams

- [ ] Create teams within organizations
- [ ] Team-level repository access
- [ ] Team discussions

### Activity

- [ ] Activity feed (org, repo, user)
- [ ] Email notifications (configurable)
- [ ] Watch/unwatch repositories
- [ ] Star repositories

### Comments & Discussions

- [ ] Comments on files
- [ ] Discussions on repositories
- [ ] Mentions (@username)
- [ ] Markdown support with preview

### Sharing

- [ ] Share links with expiration
- [ ] Public/private toggle
- [ ] Embargoed visibility (date-based)
- [ ] Guest access (view-only)

---

## Phase 3: Life Sciences Features (v0.3)

**Goal:** Domain-specific functionality

### File Previews

- [ ] FASTA/FASTQ viewer with stats (via Rust NIF)
- [ ] CSV explorer (sort, filter, search)
- [ ] Image viewer (with zoom, pan)
- [ ] PDF viewer
- [ ] Jupyter notebook renderer
- [ ] Markdown with LaTeX support

### Protocol Editor

- [ ] Structured protocol format
- [ ] Materials list
- [ ] Step-by-step procedures
- [ ] Timing and temperature annotations
- [ ] Protocol versioning
- [ ] Fork/adapt protocols

### Datasets

- [ ] Dataset metadata schema
- [ ] Column descriptions
- [ ] Data dictionary
- [ ] Sample relationships
- [ ] Provenance tracking

### Ontologies & Tagging

- [ ] Tag with Gene Ontology terms
- [ ] ChEBI (chemicals)
- [ ] NCBI Taxonomy
- [ ] Autocomplete from ontologies
- [ ] Ontology browser

### FAIR Compliance

- [ ] FAIR score calculator
- [ ] Metadata completeness check
- [ ] Persistent identifiers (DOI via DataCite)
- [ ] License picker with guidance
- [ ] Citation generation

---

## Phase 4: Integrations (v0.4)

**Goal:** Connect to the research ecosystem

### Identity & Auth

- [ ] SAML SSO (enterprise)
- [ ] OIDC support
- [ ] Institutional login (InCommon, eduGAIN)

### External Services

- [ ] Zenodo sync (push datasets)
- [ ] GenBank/UniProt linking
- [ ] PubMed paper linking
- [ ] ORCID profile sync
- [ ] GitHub import

### API

- [ ] REST API (v1)
- [ ] API key management
- [ ] Rate limiting
- [ ] Webhooks (push events)
- [ ] OpenAPI documentation

### CLI

- [ ] `cyanea` CLI tool
- [ ] Upload/download files
- [ ] Clone repositories
- [ ] Git-like interface

---

## Phase 5: Scale & Performance (v0.5)

**Goal:** Handle large datasets and many users

### Storage

- [ ] Chunked uploads for large files
- [ ] Resumable uploads
- [ ] Deduplication (content-addressed)
- [ ] Storage quotas
- [ ] Archive tier for cold data

### Performance

- [ ] CDN for static assets
- [ ] Image thumbnails
- [ ] Lazy loading for large directories
- [ ] Pagination everywhere
- [ ] Background indexing

### Infrastructure

- [ ] Kubernetes deployment
- [ ] Horizontal scaling
- [ ] Database read replicas
- [ ] Redis for caching
- [ ] Prometheus metrics
- [ ] Grafana dashboards

---

## Phase 6: Enterprise (v1.0)

**Goal:** Enterprise-ready platform

### Compliance

- [ ] Audit logs (all actions)
- [ ] Audit log export
- [ ] 21 CFR Part 11 (FDA)
- [ ] Electronic signatures
- [ ] Retention policies
- [ ] Data deletion (GDPR)

### Administration

- [ ] Admin dashboard
- [ ] User management
- [ ] Organization management
- [ ] System health monitoring
- [ ] Backup/restore tools

### Security

- [ ] Two-factor authentication
- [ ] IP allowlisting
- [ ] Session management
- [ ] Security event logging
- [ ] Vulnerability scanning

### Self-Hosted

- [ ] One-click Docker deploy
- [ ] Helm chart for Kubernetes
- [ ] Upgrade documentation
- [ ] Backup/restore guides
- [ ] Air-gapped installation

### Support

- [ ] SLA tiers
- [ ] Priority support queue
- [ ] Custom integrations
- [ ] On-premise consulting

---

## Phase 7: Intelligence (v1.x)

**Goal:** AI-powered research assistance

### Search & Discovery

- [ ] Semantic search (embeddings)
- [ ] Similar dataset recommendations
- [ ] Related protocol suggestions
- [ ] Cross-repository linking

### AI Features

- [ ] Natural language queries
- [ ] Automatic metadata extraction
- [ ] Protocol summarization
- [ ] Data quality suggestions
- [ ] Anomaly detection

### Analytics

- [ ] Usage analytics
- [ ] Download statistics
- [ ] Citation tracking
- [ ] Impact metrics

---

## Future Ideas

### Community

- [ ] Public profiles
- [ ] Following users/orgs
- [ ] Trending repositories
- [ ] Featured datasets
- [ ] Community guidelines

### Marketplace

- [ ] Protocol templates
- [ ] Dataset templates
- [ ] Plugins/extensions
- [ ] Instrument integrations

### Advanced Features

- [ ] Branching (like git branches)
- [ ] Pull requests for datasets
- [ ] Code review for protocols
- [ ] Automated validation pipelines
- [ ] Jupyter/R integration
- [ ] Real-time collaboration (OT/CRDT)

---

## Milestones

| Version | Target | Key Deliverable |
|---------|--------|-----------------|
| v0.1 | Q2 2026 | MVP: Auth, Orgs, Repos, Files, Search |
| v0.2 | Q3 2026 | Collaboration: Teams, Comments, Activity |
| v0.3 | Q4 2026 | Life Sciences: Protocols, Datasets, FAIR |
| v0.4 | Q1 2027 | Integrations: API, CLI, Zenodo, SSO |
| v0.5 | Q2 2027 | Scale: Large files, Performance |
| v1.0 | Q4 2027 | Enterprise: Compliance, Self-hosted |

---

## Success Metrics

### Phase 1 (MVP)

- 100 registered users
- 50 public repositories
- 10 active organizations
- <2s page load time

### Phase 2 (Collaboration)

- 1,000 registered users
- 500 repositories
- 100 organizations
- Daily active users > 10%

### Phase 3 (Life Sciences)

- 5,000 registered users
- Feature in a scientific publication
- First DOI minted
- Protocol fork/adapt workflow used

### Phase 4+ (Growth)

- 10,000+ users
- First paying customer
- Self-hosted deployments
- Enterprise pilot

---

## Non-Goals (For Now)

Things we're explicitly NOT building yet:

- Mobile native apps (PWA is enough)
- Sequence editor (complex, use SnapGene/Benchling)
- Instrument integrations (need partnerships)
- Workflow automation (focus on data first)
- Real-time collaborative editing (too complex)
- Computational pipelines (not a workflow engine)

---

## Principles

1. **Ship early, iterate fast** - Get feedback from real users
2. **Open source first** - Build in public, accept contributions
3. **Simple > feature-rich** - 80% of Benchling, 20% of complexity
4. **Performance matters** - Scientists hate slow tools
5. **Design is not optional** - Beautiful software wins
6. **Community > customers** - Researchers first, revenue second
