# MoE Memory System — CHANGELOG

## v2.0 — 2026-04-12
**Author:** Uvy 🦾 (GBrain Dream Cycle analysis + fleet experience)
**Reviewed by:** Steve Ekker

### New in v2.0
- **Entity pages:** Each person, project, and company gets a dedicated page in `memory/people/`, `memory/projects/`, `memory/companies/`. No more single-row entries in monolithic shards. Auto-created/enriched by EOD entity sweep (eod-consolidation v2.0).
- **Brain-first lookup rule:** On EVERY message, check the index before responding — not just on keyword match. ROUTER.md becomes a mandatory first stop, not an optional one.
- **Thin page detection:** Each shard and entity page tracks a `fullness` state. Thin pages (< 3 lines substance) are flagged in ROUTER.md for enrichment by next EOD cycle.
- **Summary staleness tracking:** Each `*.summary.md` carries an `updated:` timestamp. If > 7 days behind the full shard's last-modified date, the summary is flagged `[STALE]` in ROUTER.md.
- **Orphan detection:** Weekly pass (new `memory-maintenance` cron) flags entries in any shard with no cross-links to other shards. Orphans get reviewed and either linked or pruned.
- **ROUTER.md versioned:** ROUTER.md now carries a version header and is tracked in `lab-sops`.
- **CHANGELOG:** This file. Versions tracked in `lab-sops/skills/moe-memory/`.

### What didn't change from v1
- Three-layer architecture (Layer 0 / Layer 1 / Layer 2)
- Summaries-first principle
- Keyword routing via ROUTER.md
- Tier 1 (summary) → Tier 2 (full shard) two-step access
- Layer 2 transcripts = grep only, never loaded

---

## v1.0 — 2026-04-06 (deployed)
**Author:** Uvy 🦾
**Notes:** Original MoE architecture. Three-layer summaries-first system. Deployed fleet-wide April 6, 2026. Inspired by Omni-SimpleMem (arXiv:2604.01007). No entity pages, no staleness tracking, no orphan detection, no version history. Reconstructed as v1.0 retroactively on 2026-04-12.
