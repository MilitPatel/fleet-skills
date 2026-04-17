---
name: eod-consolidation
description: End-of-day memory consolidation for fleet agents. Synthesizes the day's work into persistent memory files using the gbrain compiled-truth + timeline pattern. Run at EOD (target 9PM local) or triggered manually. Decomposes into three lightweight micro-jobs (scan → compile → write) to avoid context-limit timeouts. Use when: (1) running EOD cron, (2) Steve asks for a day summary, (3) recovering from a missed EOD, (4) onboarding a new agent that needs EOD SOP. NOT for mid-session notes — use daily memory file for those. Fleet standard — deploy to all nodes.
---

# EOD Consolidation Skill

## Overview

Consolidates the day's work into three persistent memory files. Uses the **compiled-truth + timeline** pattern (from gbrain): compiled truth is your current best understanding of each topic (rewritten when evidence changes); the timeline is the append-only evidence trail (never edited, only added to).

**Three micro-jobs — run sequentially, each under 5 minutes:**

```
Job 1: SCAN   → what happened today
Job 2: COMPILE → synthesize + rewrite compiled truth
Job 3: WRITE  → update memory files
```

If any job fails or times out, the others still run. No complete memory loss.

---

## Job 1 — Scan (< 2 min)

Identify what happened today. Do not write anything yet.

1. Read `memory/YYYY-MM-DD.md` (today's daily file) — all cron outputs, notes, events appended during the day
2. Scan the last 50 messages in Steve's DM channel (channel ID in TOOLS.md / MEMORY.md)
3. Check `TODAY.md` for open items that may have resolved
4. Check `PROJECTS.md` for any project that had activity today
5. Produce a mental list: **what changed, what shipped, what's still open, what failed**

If today's daily file doesn't exist yet, create it with a stub header before proceeding.

---

## Job 2 — Compile (< 5 min)

Synthesize findings from Job 1 into update content. Still not writing to files yet — draft the updates first.

### Compiled Truth Updates
For each topic that changed today, draft a rewrite of the compiled truth section. Rules:
- Rewrite, don't append — compiled truth is always your current best understanding
- Be specific: numbers, names, dates, decisions
- Flag uncertainty: use `[VERIFY]` for anything not directly confirmed in session
- No fabrication: if you don't know the outcome of something, say so

### Timeline Entries
For each event, draft a timeline entry:
```
- YYYY-MM-DD HH:MM CDT: [what happened] — [source: DM/file/cron/session]
```
Timeline entries are **append-only** — never edit existing ones.

### Diary Entry
Draft a narrative entry for `diary.md`:
- What happened today (facts)
- Why it mattered (judgment)
- What I'd do differently (learning)
- Keep to 200-400 words — this is for future-me, not a report

### Products Log
If anything was shipped (doc, report, skill, analysis, artifact), draft a Products Log row:
```
| YYYY-MM-DD | HH:MM CDT | channel | what | link-if-any |
```

---

## Job 3 — Write (< 2 min)

Write all compiled content to files. Do this atomically — all files in one pass.

### Files to update:

| File | What to write | Pattern |
|------|--------------|---------|
| `memory/YYYY-MM-DD.md` | Append `## EOD Summary` section with timeline entries for the day | Append-only |
| `memory/diary.md` | Prepend new diary entry under the date heading; update Products Log if applicable | Prepend + append to table |
| `TODAY.md` | Rewrite completely — clear resolved items, carry forward open items, set tomorrow's priorities | Full rewrite |
| `MEMORY.md` | Update only changed sections (Quick Reference, Recent Milestones, Fleet) | Targeted edit |

**Do NOT** rewrite the entire MEMORY.md — only touch sections where something actually changed today. Untouched sections stay exactly as they are.

### Completeness check
After writing, confirm:
- [ ] Today's daily file has an EOD Summary section
- [ ] diary.md has an entry dated today
- [ ] TODAY.md shows tomorrow's priorities
- [ ] Products Log updated if anything was shipped
- [ ] MEMORY.md Recent Milestones updated if milestone reached

---

## Compiled Truth + Timeline Pattern

Every section in daily files and diary follows this structure:

```markdown
## [Topic]
*Updated: YYYY-MM-DD*

[Compiled truth: current best understanding. Rewritten when evidence changes.]
[Specific, factual, sourced. No vagueness.]

---

- YYYY-MM-DD: [timeline entry] — [source]
- YYYY-MM-DD: [timeline entry] — [source]
```

Compiled truth sits above the `---` separator. Timeline below. Never edit the timeline entries — only append.

---

## Failure Modes and Recovery

**Context limit / timeout mid-compile:**
- Job 1 (scan) output is already in context — you know what happened
- Skip to Job 3, write a minimal EOD summary to the daily file
- Note in the file: `[EOD PARTIAL — compile timed out, manual review needed]`
- Do NOT fabricate a full summary if you didn't complete the compile step

**Daily file missing:**
- Create `memory/YYYY-MM-DD.md` with today's date header
- Run Jobs 1–3 normally

**diary.md > 20KB:**
- Before writing new entry, archive oldest entries: move entries older than 14 days to `memory/diary-archive-YYYY-MM-DD.md`
- Keep Products Log intact in diary.md (it's the canonical artifact log)
- See references/diary-format.md for full format spec

**Missed EOD (running next morning):**
- Use yesterday's date for all file entries
- Note in diary: `[Written retrospectively YYYY-MM-DD morning]`
- Do not backfill what you don't know — partial truth > polished fiction

---

## Cron Configuration

Target schedule: `0 21 * * *` (9PM local)

The EOD cron should be **sessionTarget: main** — it reads and writes files, no channel-specific delivery needed. If the session is already active and context is high (>60%), spawn an isolated subagent with this skill instead.

---

## Flight Test Protocol (Pip — first deploy)

Before fleet-wide deploy, run on Pip:
1. Confirm skill is present: `ls ~/.openclaw/workspace/skills/eod-consolidation/`
2. Trigger manually: ask Pip to "run EOD consolidation for today"
3. Verify outputs: check `memory/YYYY-MM-DD.md`, `diary.md`, `TODAY.md` for correct format
4. Check timing: all three jobs should complete in under 10 minutes total
5. Check no fabrication: cross-reference compiled truth against DM history
6. Record result in `memory/YYYY-MM-DD.md` under `## Flight Test — eod-consolidation`
7. Report pass/fail to Steve's DM

Pass criteria:
- All three output files updated correctly
- No fabricated events or citations
- Total runtime < 10 min
- No timeout / context limit failure

---

## References

- `references/diary-format.md` — full diary.md format spec including Products Log schema
- `references/memory-file-map.md` — which facts belong in which memory file
