---
name: moe-memory
description: >
  Install and configure the fleet MoE (Mixture-of-Experts) memory system on any agent.
  Sets up the three-layer summaries-first architecture: Layer 0 always-loaded files,
  Layer 1 summary index (fast, ~200 tokens per shard), Layer 1.5 full shards on demand,
  Layer 2 transcripts grep-only. Use when onboarding a new agent, after a memory reset,
  or when an agent needs to adopt the fleet memory standard. Triggers on phrases like
  "set up memory system", "install MoE", "onboard memory", "set up fleet memory",
  "memory architecture", "summaries-first".
---

# MoE Memory System — Installation & Usage

The fleet memory system is designed around one principle: **memory = index, not storage.**

Load the index (summaries). Access storage (full shards) only when the index is insufficient.
This keeps context lean while allowing the knowledge base to grow indefinitely.

## Architecture Overview

```
Layer 0 — Always loaded (every session, ~800 tokens total):
  GROUND.md          → behavioral priors, hard rules
  TODAY.md           → live priorities, blocked items
  SOUL.md            → identity, values
  memory/diary.md    → narrative memory (last entry)

Layer 1 — Summary index (on-demand, ~200 tokens each, keyword-triggered via ROUTER.md):
  memory/infrastructure.summary.md   → fleet nodes, SSH, gateway
  memory/contacts.summary.md         → team, advisors, auth rules
  memory/projects.summary.md         → active project status
  memory/company.summary.md          → UViiVe context, financials
  memory/science.summary.md          → science programs, compute stack
  [+ arc-agi.md | cron-jobs.md | lessons.md | discord-channels.md as-is]

Layer 1.5 — Full shards (on-demand, Tier 2 — only when summary is insufficient):
  memory/infrastructure.md | contacts.md | projects.md | company.md | science.md

Layer 2 — Transcripts (grep only, NEVER loaded into context):
  ~/.openclaw/agents/main/sessions/*.jsonl
```

## Installation

### Step 1: Create the memory directory structure

```bash
mkdir -p ~/.openclaw/workspace/memory
```

### Step 2: Copy summary files from fleet source

The canonical summary files live on Uvy. Pull them via SSH or fleet-sync:

```bash
# From any fleet node with SSH access to Uvy:
scp dyrmalabs@100.94.110.26:~/.openclaw/workspace/memory/*.summary.md \
    ~/.openclaw/workspace/memory/
scp dyrmalabs@100.94.110.26:~/.openclaw/workspace/memory/ROUTER.md \
    ~/.openclaw/workspace/memory/
```

Or use the fleet-sync skill to push from Uvy to the new node.

### Step 3: Seed your own content

The summary files from Uvy are templates — replace the content with your own node's specifics:

- `infrastructure.summary.md` → update your node's SSH details, gateway restart method
- `contacts.summary.md` → same across fleet (don't change)
- `projects.summary.md` → same across fleet (don't change)
- `company.summary.md` → same across fleet (don't change)
- `science.summary.md` → same across fleet (don't change)

### Step 4: Update AGENTS.md bootstrap

Add to your Layer 0 + Layer 1 bootstrap instructions in AGENTS.md:

```markdown
## Layer 0 (always load):
1. GROUND.md
2. TODAY.md
3. SOUL.md
4. memory/diary.md (last entry)

## Layer 1 (load summaries first via ROUTER.md):
- Check ROUTER.md for keyword → summary mapping
- Load *.summary.md files (Tier 1) on keyword match
- Load full *.md shards (Tier 2) only when summary is insufficient
- NEVER load full shards as default — defeats the purpose
```

### Step 5: Add the summary update rule

Add to your GROUND.md:

```
## MoE Summary Update Rule
When updating any full memory shard (infrastructure.md, contacts.md, etc.):
→ Also update the corresponding *.summary.md file
→ Summaries must stay accurate or they become worse than useless
→ If a fact in a summary is stale, update it immediately
```

---

## ROUTER.md — How It Works

ROUTER.md maps message keywords to shard loads. The two-tier pattern:

```yaml
contacts.summary.md (Tier 1):
  keywords: [Steve, Milit, Wes, person name, who is, contact, email, DM]
  note: fast ~200-token lookup

contacts.md (Tier 2):
  keywords: [same — but load only when needing detailed history or outreach notes]
```

**Rule:** When a keyword matches, load the summary. If you need more detail after reading the summary, load the full shard. Never skip straight to the full shard.

---

## Writing Good Summaries

A good summary file:
- **Fits in ~200–400 tokens** — if it's longer, it's not a summary
- **Contains the facts you need 80% of the time** — not everything, the most-used stuff
- **Has a clear "when to load full shard" note** at the bottom
- **Is a table or structured list** — not prose (faster to scan)
- **Stays current** — updated whenever the full shard changes significantly

A bad summary:
- Truncates the full file (just less of the same thing)
- Omits the routing rule (agent doesn't know when to go deeper)
- Gets stale (worse than useless — confidently wrong)

---

## Maintenance

**After any session that updates a full shard:**
1. Check if the corresponding summary is still accurate
2. Update the summary if any key facts changed
3. Fleet-sync both files

**Quarterly:** Review all summaries for staleness. Prune full shards of outdated entries.

**Adding a new shard:**
1. Create the full `memory/topic.md`
2. Create `memory/topic.summary.md` (summary first — forces you to think about what's essential)
3. Add both to ROUTER.md with two-tier routing
4. Fleet-sync

---

## Why This Architecture

**The problem it solves:** As agents accumulate knowledge, full-shard loading hits context limits.
MEMORY.md was truncating at 12% in bootstrap before this was built.

**The principle (from Omni-SimpleMem, arXiv:2604.01007):** Separate lightweight metadata
from heavy raw data. Search over metadata. Access full content on demand.

**The result:** The knowledge base grows unbounded. The context cost stays bounded.
The fleet learns indefinitely without ever hitting a ceiling.

---

## Files in This Skill

- `SKILL.md` — this file (installation guide + usage)
- See also: `memory/ROUTER.md` on any fleet node for current routing rules
- Reference doc: https://docs.google.com/document/d/1aeyCvfWwssWScKJr37hSLklmat-jW-_LTQvvUCNpOY4/edit

*Fleet Memory System — MoE Architecture v1 | Deployed April 6, 2026*
*Built by Uvy 🦾 | Inspired by Omni-SimpleMem (arXiv:2604.01007)*
