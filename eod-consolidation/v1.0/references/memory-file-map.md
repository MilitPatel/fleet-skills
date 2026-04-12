# Memory File Map
*For use with the eod-consolidation skill*
*Which facts belong in which file*

## Quick Reference

| Type of information | File | Pattern |
|--------------------|------|---------|
| What happened today (events, crons, actions) | `memory/YYYY-MM-DD.md` | Append during day; EOD summary section added at EOD |
| Personal narrative + artifact log | `memory/diary.md` | Compiled truth (entries) + timeline (Products Log) |
| Live priorities, open items, next actions | `TODAY.md` | Full rewrite at EOD |
| Long-term facts: fleet, people, milestones, rules | `MEMORY.md` | Targeted edits only; stable sections never touched |
| Reasoning trajectories, metacognition | `memory/reasoning-journal.md` | Append-only entries after complex tasks |
| Project-specific state | `projects/*/NOTEBOOK.md` | Managed by project-ledger skill |

## What Goes Where — Decision Rules

**Something happened today (event, result, message, failure):**
→ Append to `memory/YYYY-MM-DD.md` immediately, or at EOD

**A thing was shipped (doc, skill, report, artifact):**
→ Products Log row in `diary.md` + entry in `memory/YYYY-MM-DD.md`

**A decision was made (fleet, product, science):**
→ `TODAY.md` if it affects immediate next actions
→ `MEMORY.md` Hard Rules or relevant section if it's permanent/fleet-wide

**A person's status or contact info changed:**
→ `memory/contacts.md` (shard, loaded on demand)

**A project milestone was reached:**
→ `MEMORY.md` Recent Milestones table + project NOTEBOOK.md

**A lesson was learned (corrected behavior, pattern recognized):**
→ `memory/lessons.md` (shard) + `memory/reasoning-journal.md` if metacognitive

**Fleet infrastructure changed (version, config, SSH):**
→ `memory/infrastructure.md` (shard) + `MEMORY.md` Fleet section

## TODAY.md Structure

TODAY.md is a full-rewrite file. At EOD, replace it entirely with:

```markdown
# TODAY.md
*Updated: YYYY-MM-DD HH:MM CDT*

## 🎯 Tomorrow's Priorities
1. [Most important thing — specific action]
2. [Second priority]
3. [Third priority]

## 🔴 Blocked / Waiting
- [Item]: waiting on [who/what] since [date]

## 📬 Open Threads
- [Person/channel]: [what's outstanding]

## ✅ Completed Today
- [Brief list of what was finished]

## ⚠️ Carry-Forwards
- [Anything that didn't get done that must happen tomorrow]
```

## MEMORY.md — What to Touch vs. Leave Alone

**Touch only these sections if they changed:**
- Quick Reference → Key IDs (if new IDs added)
- Fleet → version numbers, node status
- Recent Milestones → add new row if milestone reached
- Active Science → update if project status changed
- Hard Rules → add new rule if Steve issued one

**Never touch:**
- Existing Hard Rules (only add)
- Existing milestone rows (only add new ones at top)
- Key People quick lookup (update contacts.md shard instead)

## Daily File EOD Summary Format

```markdown
## EOD Summary — HH:MM CDT

### Compiled Truth (today's key facts)
- [Topic]: [what is true as of EOD]
- [Topic]: [what is true as of EOD]

### Timeline
- HH:MM CDT: [event] — [source: DM/file/session]
- HH:MM CDT: [event] — [source]

### Open Items Carried Forward
- [Item]: [why not resolved]

### Partial / Uncertain
- [Anything flagged [VERIFY] or incomplete]
```
