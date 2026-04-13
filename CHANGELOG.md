# Fleet Skills Changelog

All notable additions and changes to the fleet skills library.

---

## 2026-04-13

### Added
- **`magika-scout` v1.1** (Uvy) — AI-powered file type detection and parser routing using Google's Magika model (~99% accuracy, 200+ types, ~5ms/file on CPU). Pre-flight safety check before parsing any externally-fetched file. Includes GitHub/HuggingFace-specific risk guidance (pickle/torch.load attack vector, safetensors preference). Files: `SKILL.md`, `scripts/scout.py`, `references/router-map.md`. Packaged as `magika-scout.skill`.

---

## 2026-04-10

### Added
- **`assess-input` v1.0 + v1.1** (Uvy + Atlas) — Input assessment skill. Pushed to fleet-skills GitHub.
- **`check-siblings`** (Uvy) — Pre-action check for sibling sessions before destructive ops.
- **`session-ledger`** (Uvy) — Shared append-only log for sibling session awareness; prevents double-execution.

---

*Format: Added | Changed | Fixed | Deprecated | Removed*
*Authors: skill entry includes originating agent in parentheses.*

---

## 2026-04-13 (continued)

### Structure
- **Repo reorganization planned** — migrating from flat root to category-based structure (Option B). Pending execution after active deployments complete.

**Approved directory map:**
```
fleet-skills/
├── CHANGELOG.md          ← stays at root (fleet log)
├── README.md
├── dist/                 ← all .skill packaged distributables
├── security/             ← magika-scout, check-siblings, pre-action-gate
├── memory/               ← moe-memory, eod-consolidation, fleet-mem-deploy, session-ledger, ctx-window
├── science/              ← arxiv-search, biorxiv-search, europepmc-search, ncbi-api, openalex-search,
│                            semantic-scholar-api, paperclip, pymol-render, latex-paper
├── infra/                ← fleet-sync, fleet-chronicles, openclaw-test-flight, assess-input, mcporter
├── comms/                ← agentmail, imsg, discord-dm-recover, bird-x
└── dev/                  ← github
```

**Rules:**
- `CHANGELOG.md` always stays at repo root — it is the fleet's shared record
- New skills: add to the correct category dir + entry in CHANGELOG.md + `.skill` file in `dist/`
- `skills/` subdirectory at root = legacy artifact, will be deleted during restructure

---

## 2026-04-13 (continued)

### Security
- **Cron security audit complete** — all 5 external-fetch crons patched: GitHub Monitor, Self-Improvement Scout, Weekly Intel, Funding Intel, Competitor Research. New fleet rule: crons that fetch external content DM Steve only, never post to guild channels. Source URL required for every claim. Documented failure case: GitHub Monitor incident (hallucinated CVEs + exec commands broadcast to #gene-pool). Rule added to GROUND.md.

### Infrastructure
- **Repo URL announced to fleet** — `MilitPatel/fleet-skills` posted to #gene-pool as canonical skill library reference.
- **Repo structure finalized** — 27 skills across `security/` `memory/` `science/` `infra/` `comms/` `dev/` + `dist/` for packaged `.skill` files. CHANGELOG.md at root.
