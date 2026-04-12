---
name: moe-memory
version: "2.1"
description: >
  Install and configure the fleet MoE (Mixture-of-Experts) memory system on any agent.
  v2.1 adds auto-remediation: file size gates with auto-archive for diary.md and
  reasoning-journal.md, enforced by the weekly memory-maintenance cron.
  v2.0 adds entity pages, brain-first lookup, thin page detection, summary staleness
  tracking, and orphan detection — inspired by GBrain Dream Cycle architecture.
  Three-layer summaries-first: Layer 0 always-loaded, Layer 1 summary index,
  Layer 1.5 full shards on demand, Layer 2 transcripts grep-only.
changelog: CHANGELOG.md
---

# MoE Memory System — v2.0

## Core Principle

**Memory = index, not storage.**

Load the index (summaries). Access storage (full shards) only when the index is insufficient.
The knowledge base grows unbounded. The context cost stays bounded.

**New in v2.0: Brain-first on every message.** Not just keyword-triggered — always check
the index before responding. ROUTER.md is a mandatory first stop.

---

## Architecture Overview

```
Layer 0 — Always loaded (every session, ~800 tokens):
  GROUND.md            → behavioral priors, hard rules
  TODAY.md             → live priorities, blocked items
  SOUL.md              → identity, values
  memory/diary.md      → narrative memory (last entry)
  memory/ROUTER.md     → routing index (always loaded — it IS the index)

Layer 1 — Summary index (on-demand, ~200 tokens each):
  memory/*.summary.md  → topic summaries (keyword-triggered via ROUTER.md)
  memory/people/       → entity pages for people        [NEW v2.0]
  memory/projects/     → entity pages for projects      [NEW v2.0]
  memory/companies/    → entity pages for companies     [NEW v2.0]

Layer 1.5 — Full shards (Tier 2 — only when summary is insufficient):
  memory/infrastructure.md | contacts.md | projects.md | company.md | science.md

Layer 2 — Transcripts (grep only, NEVER loaded into context):
  ~/.openclaw/agents/main/sessions/*.jsonl
```

---

## Brain-First Lookup Rule [NEW v2.0]

On **every** message — before responding:

```
1. Read ROUTER.md (always in Layer 0 — zero cost)
2. Identify entities mentioned: people, projects, companies, concepts
3. Load matching summary (Tier 1) for each entity
4. If summary is insufficient → load full shard (Tier 2)
5. Then respond
```

This is not optional on keyword match. It is mandatory on every message.
The cost is near-zero when ROUTER.md is in Layer 0 — you already have it.

---

## Entity Pages [NEW v2.0]

Each person, project, and company gets a **dedicated page**, not a row in a monolithic shard.

### Directory structure
```
memory/
  people/
    steve-ekker.md
    milit-patel.md
    wes-wierson.md
    [one file per person]
  projects/
    uviive-unburn.md
    b7h3-binders.md
    acad9-provisional.md
    [one file per project]
  companies/
    uviive.md
    perlara.md
    [one file per company/org]
```

### Entity page format
```markdown
# [Name]
*Type: person | project | company*
*Created: YYYY-MM-DD*
*Updated: YYYY-MM-DD*
*Fullness: thin | partial | full*  ← updated by EOD entity sweep

## Compiled Truth
[Current best understanding — rewritten when evidence changes]

## Timeline
- YYYY-MM-DD: [event] — [source]    ← append only
- YYYY-MM-DD: [event] — [source]
```

### When to create an entity page
- Person: mentioned ≥2 times in session OR has a direct relationship to Steve/Milit/Wes
- Project: any named project with >1 active session
- Company: any external org relevant to UViiVe (investor, partner, competitor, vendor)

### Fullness states
- **thin:** < 3 lines of substantive content → flagged for EOD enrichment
- **partial:** 3–10 lines → functional but could be richer
- **full:** > 10 lines with sourced timeline → no action needed

Entity pages are created/enriched automatically by EOD entity sweep (eod-consolidation v2.0).

---

## Summary Staleness Tracking [NEW v2.0]

Every `*.summary.md` file carries a staleness header:

```markdown
---
shard: contacts.md
updated: 2026-04-12
shard_updated: 2026-04-12
status: current   # current | stale | [STALE]
---
```

**Staleness rule:** If `updated` is > 7 days behind `shard_updated` → status becomes `[STALE]`.

ROUTER.md surfaces stale summaries:
```
contacts.summary.md [STALE — last updated 2026-04-05, shard updated 2026-04-11]
→ load full shard instead until summary is refreshed
```

**Who fixes stale summaries:** EOD v2.0 compile step checks for staleness and refreshes as part of Job 2.

---

## Thin Page Detection [NEW v2.0]

ROUTER.md tracks fullness state for all entity pages:

```yaml
# In ROUTER.md — entity page index
people/steve-ekker.md:       fullness: full
people/milit-patel.md:       fullness: full
people/ankit-sabharwal.md:   fullness: thin    ← flagged for EOD enrichment
projects/acad9-provisional:  fullness: partial
```

EOD entity sweep (Job 1.5) checks this index and enriches thin pages automatically.

---

## File Size Gates & Auto-Archive [NEW v2.1]

v2.0 detected bloat but didn't fix it. v2.1 adds **enforcement**.

### Size thresholds

| File | Soft limit | Hard limit | Action |
|------|-----------|-----------|--------|
| `memory/diary.md` | 4,000 tokens | 6,000 tokens | Archive oldest 30% to `memory/diary-archive-YYYY-MM-DD.md` |
| `memory/reasoning-journal.md` | 6,000 tokens | 10,000 tokens | Archive oldest 50% to `memory/reasoning-journal-archive-YYYY-MM-DD.md` |
| Any `*.summary.md` | 500 tokens | 800 tokens | Flag for rewrite — summary has become a shard |
| Any entity page | 2,000 tokens | 3,000 tokens | Split into `[name]-extended.md`, keep core in main page |

### Soft limit behavior
- Log warning to `memory/YYYY-MM-DD.md`: `⚠️ SIZE GATE: [file] at [N] tokens — approaching limit`
- No action yet

### Hard limit behavior
- **Auto-archive:** move oldest entries (by date prefix on timeline items) to archive file
- Archive filename: `memory/[basename]-archive-YYYY-MM-DD.md`
- Keep the most recent entries in the live file
- Log to daily memory: `📦 ARCHIVED: [N] entries from [file] → [archive-file]`
- Never silently delete — always archive

### Who runs the gates
**Weekly memory-maintenance cron** (Mondays 6AM) owns size gate checks and auto-archiving.
EOD v2.0 may flag soft-limit warnings but does NOT archive — that's the maintenance cron's job.

### Why weekly not nightly
Nightly archiving would fragment context too aggressively. Weekly gives files room to breathe
between EOD runs while still catching runaway growth before it impacts bootstrap.

---

## Orphan Detection [NEW v2.0]

**Weekly pass** (memory-maintenance cron, Mondays 6AM):

An **orphan** is any entry in a memory shard or entity page with:
- No cross-links to any other shard or page
- No source attribution (`[SOURCE MISSING]`)
- Not updated in > 30 days

Orphans are flagged in a `memory/orphan-report-YYYY-MM-DD.md` file for human review.
Options: link it, enrich it, or archive it. Never silently delete.

---

## ROUTER.md — v2.0 Structure

ROUTER.md is now **always in Layer 0** (small enough — ~300 tokens). It is the mandatory
first read on every session and every message.

Full routing structure (two-tier for all topic shards):

```yaml
# ROUTER.md v2.0
# Layer 0 — always loaded
# Updated: YYYY-MM-DD

## Entity Index (people/projects/companies)
[fullness states for all entity pages]

## Topic Shards — Two-Tier Routing
[Tier 1 summary → Tier 2 full shard for each topic]

## Staleness Flags
[any *.summary.md marked [STALE]]

## Orphan Flags
[any entries pending review from last orphan detection run]
```

---

## Installation

### Step 1: Directory structure
```bash
mkdir -p ~/.openclaw/workspace/memory/{people,projects,companies}
```

### Step 2: Pull summary files + ROUTER.md from Uvy
```bash
scp dyrmalabs@100.94.110.26:~/.openclaw/workspace/memory/*.summary.md \
    ~/.openclaw/workspace/memory/
scp dyrmalabs@100.94.110.26:~/.openclaw/workspace/memory/ROUTER.md \
    ~/.openclaw/workspace/memory/
# Entity pages — pull the whole directory
scp -r dyrmalabs@100.94.110.26:~/.openclaw/workspace/memory/people/ \
    ~/.openclaw/workspace/memory/
scp -r dyrmalabs@100.94.110.26:~/.openclaw/workspace/memory/projects/ \
    ~/.openclaw/workspace/memory/
scp -r dyrmalabs@100.94.110.26:~/.openclaw/workspace/memory/companies/ \
    ~/.openclaw/workspace/memory/
```

Or use fleet-sync skill to push from Uvy.

### Step 3: Update AGENTS.md bootstrap

Layer 0 must include `memory/ROUTER.md`:

```markdown
## Layer 0 (always load — every session):
1. GROUND.md
2. TODAY.md
3. SOUL.md
4. memory/diary.md (last entry)
5. memory/ROUTER.md   ← NEW v2.0 — always loaded

## Layer 1 (brain-first on every message):
- On every message: check ROUTER.md → load matching summaries
- Load *.summary.md (Tier 1) → full *.md shards (Tier 2) only if needed
- Load entity pages for people/projects/companies mentioned
- NEVER load full shards as default
```

### Step 4: Add summary update rule to GROUND.md
```
## MoE Summary Update Rule (v2.0)
When updating any full memory shard:
→ Update the corresponding *.summary.md AND its staleness header
→ Update fullness state in ROUTER.md for any entity pages touched
→ Summaries stale > 7 days → load full shard instead, flag for refresh
```

### Step 5: Add memory-maintenance cron
Weekly orphan detection + embed stale summaries:
`0 6 * * 1` (Mondays 6AM) — `sessionTarget: isolated`

---

## Writing Good Summaries (unchanged from v1)

- **~200–400 tokens** — if longer, it's not a summary
- **80% coverage** — the facts you need most of the time
- **"When to load full shard"** note at bottom
- **Table or structured list** — not prose
- **Staleness header** — always include, always update

---

## Maintenance

**After any session updating a full shard:**
1. Update corresponding `*.summary.md` staleness header
2. Update fullness state in ROUTER.md for touched entity pages
3. Fleet-sync both files

**EOD v2.0 (automatic):**
- Entity sweep creates/enriches thin entity pages
- Citation hygiene flags `[SOURCE MISSING]` entries

**Weekly (memory-maintenance cron):**
- Orphan detection → `memory/orphan-report-YYYY-MM-DD.md`
- Summary staleness check
- `gbrain embed --stale` (if GBrain installed)

**Quarterly:**
- Review all summaries for staleness
- Prune full shards of outdated entries
- Archive entity pages for people/projects no longer active

---

## Why This Architecture

**The problem:** Full-shard loading hits context limits as knowledge accumulates.
MEMORY.md was truncating at 12% in bootstrap before v1 was built.

**v1 solution:** Summaries-first, keyword routing, two-tier access.

**v2.0 gap closed:** v1 had no entity-level granularity, no staleness tracking, no
auto-enrichment. Knowledge could only grow via manual updates. GBrain showed that
the brain should compound automatically — every conversation adds to it.

**v2.1 gap closed:** v2.0 detected problems (size, staleness, orphans) but didn't fix them.
Detection without remediation just creates noise. v2.1 adds enforcement: size gates with
auto-archive ensure files can't grow unbounded regardless of agent discipline.

**The principle (Omni-SimpleMem, arXiv:2604.01007):** Separate lightweight metadata
from heavy raw data. Search metadata. Access full content on demand.

**v2.1 result:** Entity pages compound from EOD entity sweep. Summaries self-report
staleness. Orphans surface for pruning. Files enforce their own size limits.
The knowledge base maintains itself — and stays lean.

---

## Files in This Skill
- `SKILL.md` — this file
- `CHANGELOG.md` — version history
- See also: `memory/ROUTER.md` on any fleet node for current routing rules

*MoE Memory System v2.1 | 2026-04-12*
*Built by Uvy 🦾 | Inspired by GBrain (Garry Tan) + Omni-SimpleMem (arXiv:2604.01007)*
