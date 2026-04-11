---
name: session-ledger
description: >
  Lightweight shared append-only log that sibling sessions write to on start and close.
  Any session can read it to see what other sessions have recently done — preventing
  double-execution, conflicting writes, and reminder-triggered duplicate actions.
  Used by check-siblings skill. Write one line on session start; update on close.
  Survives restarts. No inter-session communication required — just a shared file.
---

# session-ledger

**Shared append-only log for sibling session awareness. Prevents double-execution.**

Born from: Atlas reminder-triggered registry edit that had already been completed by another session (2026-04-10).

---

## The Problem It Solves

When multiple sessions run on the same agent (main + cron + subagent), they have no awareness of each other. A reminder fires → session executes the action → but it was already done by a sibling 2 minutes ago. Result: duplicate writes, conflicting edits, data corruption.

The SESSION-LEDGER is the fix: a single file every session reads and writes. No IPC needed.

---

## File Location

```
~/.openclaw/agents/main/SESSION-LEDGER.md
```

---

## Format

```markdown
# SESSION-LEDGER
*Append-only. Each session writes one line on start, updates on close.*

| Timestamp | Session | Intent | Status |
|-----------|---------|--------|--------|
| 2026-04-10 19:05 CDT | main | General assistant session | 🟢 ACTIVE |
| 2026-04-10 18:55 CDT | cron-bloat-guardian | Session count check | ✅ DONE |
| 2026-04-10 18:52 CDT | subagent-audit-batch2 | Science audits NVDA/NTRA/UBX/DNA/TWST/PACB/ATAI | ✅ DONE |
| 2026-04-10 17:56 CDT | main | Cleared Pip sessions.json | ✅ DONE |
```

---

## Usage

### On session start — write your entry
```bash
python3 ~/scripts/session_ledger.py --start --intent "Science audit batch 3"
```

### On session close — mark done
```bash
python3 ~/scripts/session_ledger.py --close
```

### Read ledger (check what siblings have done)
```bash
python3 ~/scripts/session_ledger.py --read
python3 ~/scripts/session_ledger.py --read --last 10
```

### Check if an action was recently done
```bash
python3 ~/scripts/session_ledger.py --check "edit openclaw.json"
# Returns: FOUND (done X min ago by session Y) or NOT_FOUND
```

---

## Agent Behavior Rules

**On every session start:**
1. Run `check_siblings.py` — see who else is active
2. Write to SESSION-LEDGER with your intent
3. Read last 10 lines to see recent sibling actions

**Before any destructive action:**
1. Run `check_siblings.py --action "describe what you're about to do"`
2. If siblings present: read SESSION-LEDGER, confirm action not already done
3. Proceed only if clear

**On session close:**
1. Update your SESSION-LEDGER entry to ✅ DONE
2. Note any incomplete actions for handoff

---

## Self-Install

```bash
mkdir -p ~/scripts
cp ~/.openclaw/workspace/skills/session-ledger/scripts/session_ledger.py ~/scripts/
chmod +x ~/scripts/session_ledger.py

# Initialize ledger if it doesn't exist
python3 ~/scripts/session_ledger.py --init
```

---

## Integration with check-siblings

`check-siblings` automatically reads SESSION-LEDGER when siblings are detected.
The two skills are designed to work together:

```
Before destructive action:
  check_siblings.py --action "X"
    → siblings present?
      → read SESSION-LEDGER (last 20 entries)
      → confirm X not already done
      → proceed or abort
    → no siblings?
      → proceed (log in SESSION-LEDGER)
```

---

## Changelog

| Date | Entry |
|------|-------|
| 2026-04-10 | v1.0 — Initial design. Born from Atlas double-edit incident. Fleet-standard. Built by Uvy 🦾 |
