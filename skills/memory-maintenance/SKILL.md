# SKILL.md — memory-maintenance

## Purpose
Keep Layer 0 bootstrap files lean to prevent compaction loops and session instability. Run when MEMORY.md, diary.md, or total Layer 0 exceeds size thresholds.

## Trigger Conditions
- `MEMORY.md` > 15KB
- `memory/diary.md` > 10KB
- Total Layer 0 (MEMORY.md + TODAY.md + AGENTS.md + SOUL.md + diary.md) > 50KB
- Bootstrap truncation warning in session (e.g. "12% removed")

## Layer 0 Size Targets
| File | Target | Hard Limit |
|------|--------|------------|
| MEMORY.md | <6KB | 10KB |
| diary.md | <5KB | 8KB |
| TODAY.md | <8KB | 12KB |
| AGENTS.md | <9KB | 12KB |
| SOUL.md | leave alone | — |
| **Total** | **<35KB** | **50KB** |

## Step 1 — Check current sizes
```bash
wc -c ~/.openclaw/workspace/MEMORY.md \
       ~/.openclaw/workspace/TODAY.md \
       ~/.openclaw/workspace/AGENTS.md \
       ~/.openclaw/workspace/SOUL.md \
       ~/.openclaw/workspace/memory/diary.md
```

## Step 2 — Trim diary.md
Keep only the last 2–3 diary entries (roughly last 3–5 days). Archive the rest.

```bash
# Archive full diary before trimming
cp ~/.openclaw/workspace/memory/diary.md \
   ~/.openclaw/workspace/memory/diary-archive-$(date +%Y-%m-%d).md
echo "Archived"
```

Then edit diary.md to keep:
- The `## 📦 Products Log` table (always keep — trim old rows if >15 entries)
- Last 2–3 narrative entries only
- Add a line at top: `*Archive of older entries: memory/diary-archive-YYYY-MM-DD.md*`

## Step 3 — Trim MEMORY.md
MEMORY.md should contain ONLY:
- Who I Am (4 lines)
- Topic Index table
- Quick Reference section (Key IDs, Daily Habits, Fleet table, SOPs, Key People)
- Recent Milestones — compact table only (one line per milestone, link to daily file for detail)
- Hard Rules

Do NOT include:
- Full milestone narratives (those belong in memory/YYYY-MM-DD.md)
- Duplicate information already in topic shards
- Historical context older than 2 weeks

Archive the full MEMORY.md before trimming:
```bash
cp ~/.openclaw/workspace/MEMORY.md \
   ~/.openclaw/workspace/memory/MEMORY-archive-$(date +%Y-%m-%d).md
```

## Step 4 — Verify
```bash
wc -c ~/.openclaw/workspace/MEMORY.md \
       ~/.openclaw/workspace/memory/diary.md
```
Both should be under their targets. Total Layer 0 should be under 50KB.

## Step 5 — Update Recent Milestones stub
MEMORY.md must have a `## Recent Milestones` section or the memory redundancy cron will flag it. Keep it as a compact table:

```markdown
## Recent Milestones
*Full detail in daily files: `memory/YYYY-MM-DD.md`*

| Date | Milestone |
|------|-----------|
| YYYY-MM-DD | One-line description |
```

## What NOT to touch
- `SOUL.md` — do not edit
- `AGENTS.md` — only edit if it has grown with redundant content
- Topic shards (memory/contacts.md, infrastructure.md, etc.) — managed separately

## Why This Matters
80KB of bootstrap context = session starts at 40%+ context before the first message. Under heavy tasks, compaction fires mid-execution → loop. Keeping Layer 0 under 35KB gives 2–3x more headroom before instability hits.

*Skill authored by Uvy 🦾 | 2026-04-07 — born from the Apr 6 compaction loop incident*
