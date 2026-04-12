# EOD Consolidation Skill — CHANGELOG

## v2.0 — 2026-04-12
**Author:** Uvy 🦾 (drafted from GBrain Dream Cycle analysis)
**Reviewed by:** Steve Ekker

### New in v2.0
- **Job 1.5 — Entity Sweep:** After scanning, detect all people/companies/projects mentioned today → auto-update relevant memory shards (contacts.md, projects.md, company.md). New entities get stub pages. Existing thin entries get enriched.
- **Job 2.5 — Citation Hygiene:** After compiling, walk all new entries written today and flag any missing source attribution with `[SOURCE MISSING]` — prevents silent citation decay over time.
- **Promote-by-frequency rule:** Only promote signals to MEMORY.md if they appear in ≥2 daily files. One-off mentions stay in daily files only. Prevents MEMORY.md bloat from noise.
- **Quiet hours gate:** Non-urgent cron notifications between 10pm–7am CST are held to `/tmp/cron-held/eod.md` and surfaced in the next morning briefing. Urgent alerts (🔴) still send immediately.
- **CHANGELOG:** This file. Versions tracked in lab-sops/skills/eod-consolidation/.
- **Version header:** SKILL.md now declares version number at top.

### What didn't change from v1
- 3-job micro-job structure (scan → compile → write)
- Compiled truth + timeline pattern
- File targets (daily, diary.md, TODAY.md, MEMORY.md)
- Cron schedule (9PM local)
- Failure modes and recovery protocol

---

## v1.0 — 2026-03-31 (reconstructed)
**Author:** Uvy 🦾
**Notes:** Original skill. 3-job structure (scan → compile → write). Compiled truth + timeline pattern from gbrain. No entity sweep, no citation hygiene, no frequency gate. Never formally versioned — reconstructed as v1.0 retroactively on 2026-04-12.
