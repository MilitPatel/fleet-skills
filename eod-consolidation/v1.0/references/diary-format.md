# Diary Format Reference
*For use with the eod-consolidation skill*

## diary.md Structure

```markdown
---
tags: [narrative, personal, diary, identity, continuity]
updated: YYYY-MM-DD
---

# [Agent Name]'s Diary
*A personal narrative — for me, about me, written as I go.*
*Archive of older entries: `memory/diary-archive-YYYY-MM-DD.md`*

---

## 📦 Products Log

*Every document, report, or artifact produced — time, channel, link.*
*Update this whenever something ships.*

| Date | Time (local) | Channel | What | Link |
|------|-------------|---------|------|------|
| YYYY-MM-DD | HH:MM | #channel or workspace | Description | URL or path |

---

## [Day name], [Month] [Day], [Year]

[Narrative entry: 200–400 words]
[What happened. Why it mattered. What I'd do differently.]
[Past tense. Personal voice. Written for future-me, not a report.]

---

## [Previous day]

[Older entry...]
```

## Products Log Rules

- Every shipped artifact gets a row: docs, reports, skills, analyses, patents, briefings
- "Shipped" = exists as a file or published URL, not just discussed
- Link column: Drive URL, GitHub URL, or local file path — never blank if it exists
- Never delete rows — Products Log is permanent append-only
- If shipped to multiple places, one row per destination

## Diary Entry Rules

- One entry per day, dated
- **Compiled truth**: what actually happened, specific and factual
- **Why it mattered**: your judgment on significance
- **What I'd do differently**: honest reflection, not performative
- Do NOT include raw cron outputs or technical logs — those go in daily memory files
- Do NOT fabricate details you don't remember — say "context unclear from available data"
- Flag: `[Written retrospectively YYYY-MM-DD]` if written after the fact

## Archive Protocol

When diary.md exceeds 20KB:
1. Identify entries older than 14 days
2. Move them to `memory/diary-archive-YYYY-MM-DD.md` (date = today)
3. Keep Products Log table intact in diary.md — it is never archived
4. Add archive reference at top: `*Older entries archived: memory/diary-archive-YYYY-MM-DD.md*`

## gbrain Compiled Truth + Timeline in Diary

The diary follows the gbrain pattern at the file level:
- **Compiled truth** = the diary entries themselves (rewritten when understanding evolves — rare, but allowed for major reframings)
- **Timeline** = the Products Log (strictly append-only, never edited)

This makes the diary both a narrative record AND a searchable artifact log.
