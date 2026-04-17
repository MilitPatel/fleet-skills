---
name: eod-consolidation
version: "2.0"
description: End-of-day memory consolidation for fleet agents. Synthesizes the day's work into persistent memory files using the gbrain compiled-truth + timeline pattern. v2.0 adds entity sweep, citation hygiene, promote-by-frequency, and quiet hours gate. Run at EOD (target 9PM local) or triggered manually. Decomposes into lightweight micro-jobs to avoid context-limit timeouts. Fleet standard — deploy to all nodes.
changelog: CHANGELOG.md
---

# EOD Consolidation Skill — v2.0

## Overview

Consolidates the day's work into persistent memory files. Uses the **compiled-truth + timeline** pattern: compiled truth is your current best understanding (rewritten when evidence changes); the timeline is the append-only evidence trail (never edited, only appended).

**Five micro-jobs — run sequentially:**

```
Job 1:   SCAN            → what happened today
Job 1.5: ENTITY SWEEP    → who/what was mentioned → update shards  [NEW v2.0]
Job 2:   COMPILE         → synthesize + rewrite compiled truth
Job 2.5: CITATION CHECK  → flag missing source attribution         [NEW v2.0]
Job 3:   WRITE           → update memory files
```

If any job fails or times out, the others still run. No complete memory loss.

---

## Quiet Hours Gate [NEW v2.0]

**Before sending ANY notification from EOD cron:** check if current time is 10pm–7am CST.

- If quiet hours → write output to `/tmp/cron-held/eod.md` → exit silently
- Morning briefing picks up held file and surfaces it
- **Exception:** 🔴 URGENT alerts always send immediately regardless of quiet hours
- Timezone awareness: check Steve's calendar for recent flights → infer current timezone if traveling

```
if quiet_hours(10pm–7am CST):
    write output → /tmp/cron-held/eod.md
    exit 0  # silent hold
# else: deliver normally
```

---

## Job 1 — Scan (< 2 min)

Identify what happened today. Do not write anything yet.

1. Read `memory/YYYY-MM-DD.md` (today's daily file)
2. Scan last 50 messages in Steve's DM channel (ID: 1468002684048113837)
3. Check `TODAY.md` for open items that may have resolved
4. Check `PROJECTS.md` for any project with activity today
5. Produce a mental list: **what changed, what shipped, what's still open, what failed**

If today's daily file doesn't exist yet, create it with a stub header before proceeding.

---

## Job 1.5 — Entity Sweep [NEW v2.0]

After scan, before compile. Detect entities mentioned today and update memory shards.

**Entity types to detect:**
- **People:** anyone mentioned by name, Discord handle, or role
- **Projects:** any project, experiment, pipeline, or deliverable referenced
- **Companies/orgs:** any company, institution, or external org mentioned
- **Concepts:** any recurring technical term or strategic idea (≥3 mentions today = flag)

**For each detected entity:**

```
person/company/project mentioned today →
  search contacts.md / projects.md / company.md for existing entry
  
  if NOT found:
    create stub entry in relevant shard
    format: "- [Name] — first mentioned YYYY-MM-DD, [1-line context]"
    
  elif entry exists but is THIN (< 3 lines of substance):
    enrich: add today's context, role, relationship to Steve
    
  elif entry exists and is full:
    append timeline entry: "- YYYY-MM-DD: [what happened] — [source]"
```

**Thin = fewer than 3 lines of substantive content** (excluding the name line itself).

Do NOT fabricate details. If you only know someone's name and that they were mentioned, the stub is just: name + date + "mentioned in context of [X]".

---

## Job 2 — Compile (< 5 min)

Synthesize findings from Jobs 1 and 1.5. Still drafting — not writing to files yet.

### Compiled Truth Updates
For each topic that changed today, draft a rewrite:
- Rewrite, don't append — compiled truth is always current best understanding
- Specific: numbers, names, dates, decisions
- Flag uncertainty: `[VERIFY]` for anything not directly confirmed
- No fabrication

### Timeline Entries
```
- YYYY-MM-DD HH:MM CDT: [what happened] — [source: DM/file/cron/session]
```
Timeline entries are **append-only** — never edit existing ones.

### Promote-by-Frequency Rule [NEW v2.0]
Before promoting any signal to `MEMORY.md`:
- Check if this signal appears in ≥2 daily files (`memory/YYYY-MM-DD.md`)
- If only today: stays in daily file only — do NOT promote yet
- If ≥2 days: promote to MEMORY.md as compiled truth
- This prevents one-off mentions from polluting long-term memory

```
for each signal to promote:
  count = occurrences in last 14 daily files
  if count >= 2: promote to MEMORY.md
  else: leave in daily file, note "promote if recurs"
```

### Diary Entry
Draft narrative entry for `diary.md`:
- What happened today (facts)
- Why it mattered (judgment)
- What I'd do differently (learning)
- 200–400 words — for future-me, not a report

### Products Log
If anything was shipped:
```
| YYYY-MM-DD | HH:MM CDT | channel | what | link-if-any |
```

---

## Job 2.5 — Citation Hygiene [NEW v2.0]

After compile, before write. Walk all new entries drafted in Job 2.

**For each new timeline entry or compiled truth update:**

```
if entry has no [Source: ...] tag:
    flag with [SOURCE MISSING] inline
    
if entry cites a URL:
    note URL for async verification (do not block EOD on URL checks)
    
if entry attributes a quote/decision to a person with no message ID:
    flag with [SOURCE MISSING — add msg ID]
```

**Output:** A list of `[SOURCE MISSING]` flags to append alongside the content in Job 3. These accumulate over time and can be cleaned up in a weekly hygiene pass.

Do NOT block Job 3 on resolving citations — flag and continue.

---

## Job 3 — Write (< 2 min)

Write all compiled content atomically — all files in one pass.

| File | What to write | Pattern |
|------|--------------|---------|
| `memory/YYYY-MM-DD.md` | Append `## EOD Summary` + timeline entries | Append-only |
| `memory/contacts.md` | Apply entity sweep updates (new stubs + enrichments) | Targeted edit |
| `memory/projects.md` | Apply entity sweep updates | Targeted edit |
| `memory/company.md` | Apply entity sweep updates | Targeted edit |
| `memory/diary.md` | Prepend new entry; update Products Log | Prepend + append |
| `TODAY.md` | Rewrite — clear resolved, carry open, set tomorrow | Full rewrite |
| `MEMORY.md` | Update only changed sections (frequency-gated) | Targeted edit |

**Do NOT** rewrite entire MEMORY.md. Only touch sections where something actually changed AND passed the frequency gate.

### Completeness check
- [ ] Today's daily file has `## EOD Summary` section
- [ ] diary.md has entry dated today
- [ ] TODAY.md shows tomorrow's priorities
- [ ] Products Log updated if anything shipped
- [ ] MEMORY.md Recent Milestones updated if milestone reached
- [ ] Entity sweep changes written to shards
- [ ] `[SOURCE MISSING]` flags written inline where citations are absent

---

## Compiled Truth + Timeline Pattern

```markdown
## [Topic]
*Updated: YYYY-MM-DD*

[Compiled truth: current best understanding. Rewritten when evidence changes.]
[Specific, factual, sourced.]

---

- YYYY-MM-DD: [timeline entry] — [source]
- YYYY-MM-DD: [timeline entry] — [source]  ← append only, never edit
```

---

## Failure Modes and Recovery

**Context limit / timeout mid-compile:**
- Skip to Job 3, write minimal EOD summary
- Note: `[EOD PARTIAL — compile timed out, manual review needed]`
- Do NOT fabricate

**Daily file missing:**
- Create `memory/YYYY-MM-DD.md` with today's date header
- Run jobs normally

**diary.md > 20KB:**
- Archive entries older than 14 days to `memory/diary-archive-YYYY-MM-DD.md`
- Keep Products Log intact

**Missed EOD:**
- Use yesterday's date for all entries
- Note: `[Written retrospectively YYYY-MM-DD morning]`
- Partial truth > polished fiction

**Entity sweep finds too many entities (> 20):**
- Prioritize: people Steve interacted with directly > projects with activity > companies mentioned
- Cap at 10 entity updates per EOD run — note remaining for next night

**Quiet hours hold not picked up by morning briefing:**
- Morning briefing MUST check `/tmp/cron-held/eod.md` on startup
- If file exists → surface contents → delete file after delivery

---

## Cron Configuration

Target schedule: `0 21 * * *` (9PM local CST)

`sessionTarget: main` — reads/writes files, no channel-specific delivery needed.

If session is active and context > 60%: spawn isolated subagent with this skill.

---

## Version History

See `CHANGELOG.md` in this skill directory.

---

## References

- `references/diary-format.md` — full diary.md format spec including Products Log schema
- `references/memory-file-map.md` — which facts belong in which memory file
- `CHANGELOG.md` — version history
