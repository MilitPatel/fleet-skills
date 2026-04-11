---
name: check-siblings
description: >
  Check for active sibling sessions on the current agent before taking any destructive,
  registry-modifying, or high-consequence action. Run BEFORE: file deletes, registry edits,
  cron modifications, openclaw.json changes, fleet deploys, or any action flagged as
  irreversible. Outputs a warning if other sessions are active. Zero-dependency — pure shell.
---

# check-siblings

**Check for sibling sessions before destructive actions. Prevents double-execution and conflicts.**

Born from: Atlas reminder-triggered registry edit that had already been completed by another session (2026-04-10).

---

## When to use

Run BEFORE any of these:
- Deleting or overwriting files
- Editing registry files (people/registry.json, openclaw.json, AGENTS.md, GROUND.md)
- Modifying cron jobs
- Fleet-wide deploys
- Any action tagged as destructive or irreversible
- Executing a reminder that involves a state-changing action

**Cost:** one shell call (~50ms). Cost of skipping: duplicate actions, conflicting writes, data loss.

---

## Usage

```bash
python3 ~/scripts/check_siblings.py
python3 ~/scripts/check_siblings.py --json
python3 ~/scripts/check_siblings.py --action "edit openclaw.json"
```

### Example output (siblings active)

```
─────────────────────────────────────────────────
  👥  check_siblings — Session Conflict Check
─────────────────────────────────────────────────
  Active sessions: 3
  Current session: main

  Other active sessions:
    • cron-bloat-guardian  (started 14 min ago)
    • subagent-atlas-001   (started 2 min ago)

  ⚠️  WARNING: 2 sibling sessions are active.
  Intended action: edit openclaw.json

  Before proceeding:
  1. Check SESSION-LEDGER.md for recent actions
  2. Confirm this action hasn't already been done
  3. Ensure no sibling is working on the same target

  Exit code: 1 (siblings present — proceed with caution)
─────────────────────────────────────────────────
```

### Example output (no siblings)

```
─────────────────────────────────────────────────
  👥  check_siblings — Session Conflict Check
─────────────────────────────────────────────────
  Active sessions: 1 (only current session)
  ✅  CLEAR — no sibling sessions active.
  Exit code: 0
─────────────────────────────────────────────────
```

---

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | No siblings — safe to proceed |
| 1 | Siblings present — check SESSION-LEDGER.md before proceeding |
| 2 | Sessions file unreadable — treat as unknown, proceed with caution |

---

## Self-Install

```bash
mkdir -p ~/scripts
cp ~/.openclaw/workspace/skills/check-siblings/scripts/check_siblings.py ~/scripts/
chmod +x ~/scripts/check_siblings.py
python3 ~/scripts/check_siblings.py  # verify
```

---

## SESSION-LEDGER.md Integration

`check-siblings` reads and writes `~/.openclaw/agents/main/SESSION-LEDGER.md`:
- On start: appends one line (session name, timestamp, intent)
- On close: marks line as closed
- Any session can read the ledger to see what siblings have done recently

See the `session-ledger` skill for full ledger management.

---

## Changelog

| Date | Entry |
|------|-------|
| 2026-04-10 | v1.0 — Initial build. Born from Atlas reminder-triggered double-edit incident. Fleet-standard. Built by Uvy 🦾 |
