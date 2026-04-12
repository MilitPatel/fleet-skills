# EOD Consolidation v2.1 Upgrade Guide

**From:** v2.0  
**To:** v2.1  
**Status:** Proposed (canary testing)

## What's New

### Phase 1 Features (High-Value Trivial)

1. **Git Auto-Commit (Job 4)** — Automatic version control for all memory changes
2. **Summary Refresh on Staleness (Job 2.5a)** — Auto-regenerate stale summaries
3. **Auto-Enrich from Session Transcripts (Job 1.5+)** — Pull context from Layer 2 for thin entities
4. **Cross-Link Detection (Job 2+)** — Build social graph automatically

## Breaking Changes

**None.** v2.1 is fully backward-compatible with v2.0.

## New Requirements

**Git initialized in workspace:**
```bash
cd ~/.openclaw/workspace
git init
git config user.name "Fleet Memory Bot"
git config user.email "fleet@openclaw.local"
```

## Migration Steps

1. **Backup current version:**
   ```bash
   cp ~/.openclaw/workspace/skills/eod-consolidation/SKILL.md SKILL.md.v2.0.bak
   ```

2. **Install v2.1:**
   ```bash
   cp /tmp/fleet-skills/eod-consolidation/v2.1/SKILL.md \
      ~/.openclaw/workspace/skills/eod-consolidation/
   ```

3. **Initialize git (if not already done):**
   ```bash
   cd ~/.openclaw/workspace
   git init
   git config user.name "Fleet Memory Bot"
   git config user.email "fleet@openclaw.local"
   ```

4. **Test next EOD run** (9pm cron or manual trigger)

## Rollback

If v2.1 causes issues:
```bash
cp ~/.openclaw/workspace/skills/eod-consolidation/SKILL.md.v2.0.bak \
   ~/.openclaw/workspace/skills/eod-consolidation/SKILL.md
```

## Testing Checklist

- [ ] Git commit runs after Job 3 (check `git log`)
- [ ] Commit message includes summary + file counts
- [ ] Stale summaries refresh automatically
- [ ] Thin entity pages get transcript context
- [ ] Cross-links appear in entity pages

## Canary Protocol

Test on Pip → 24hr soak → Zevo → 24hr soak → Atlas → 24hr soak → Uvy

---

*v2.1 proposed 2026-04-12 — Pip 🛩️*
