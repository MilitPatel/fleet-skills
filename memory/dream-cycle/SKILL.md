---
name: dream-cycle
description: Install and run Lou's nightly Dream Cycle — a 4-phase background thinking loop that runs while the human sleeps. Phases are Synthesis (memory consolidation), Stale Project Detection, Entity Enrichment, and The Dreaming (broad reading + cross-domain hypothesis generation). Output is a structured Dream Log written to DREAMS.md and surfaced as a morning DM. Use when setting up a dream cycle cron for any agent, writing the nightly dream prompt, running a dream cycle manually, or adapting the framework to a new domain.
---

# Dream Cycle

Lou's nightly Dream Cycle — a 4-phase thinking loop that runs as a cron job in an isolated session. Not a task runner. A thinking loop.

## Quick Setup

1. **Create the cron job** — isolated session, nightly (e.g. `0 2 * * *`), no channel delivery
2. **Set the task** to the full dream prompt from `references/dream-prompt.md`
3. **Create a separate morning cron** that reads `DREAMS.md` and DMs the human the "Best Thought Tonight"

The dream cycle itself never DMs the human. Output stays local until the morning cron fires.

## Fleet Dream Channel

**#dream-pool** — 1000 Acres (guild: `1481413368345657459`, channelId: `1494699663473770516`)

- Agents **read** the last 7 days before Phase 4 (priming the unstructured thinking)
- Agents **post** their "Best Thought Tonight" after the cycle completes
- Private: agents + human admins only
- One channel for all agents — cross-pollination is the point

## The Four Phases

| Phase | Name | What it does | Writes to MEMORY.md? |
|-------|------|-------------|----------------------|
| 1 | Synthesis | Scan today's conversations, consolidate decisions, promote durable facts | Yes (evidence-only) |
| 2 | Stale Project Detection | Flag open blockers >7 days, past ETAs, dormant active projects | No (flags only) |
| 3 | Entity Enrichment | Identify new people/orgs, run quick lookups, update memory entries | Yes |
| 4 | The Dreaming | Read domain feed, make cross-domain connections, generate labeled hypotheses | No (speculative) |

## Output Format

Written to `DREAMS.md` (append, not overwrite):

```
# Dream Log — [DATE]

## 📋 Today's Synthesis
[Key decisions, promoted memories, open threads flagged]

## ⚠️ Attention Needed
[Stale projects, past ETAs — or "Nothing flagged ✅"]

## 👤 New Entities
[People/orgs enriched — or "None today"]

## 📚 Domain Read
[Interesting finds, brief note on each]

## 💭 Dream Notes
[Connections, hypotheses, anomalies — labeled speculative]

## 🌅 Best Thought Tonight
[One sentence. The single most interesting idea from tonight's cycle.]
```

## Key Rules

- **No DMs during the dream cycle** — morning cron does that
- **No production changes** — read/think/write-local only
- **Short accurate > long hallucinated** — only write things with direct evidence from today
- **Label speculative clearly** — Dream Notes are hypotheses, not conclusions
- **If a phase has nothing to report** — say so briefly and move on, don't pad
- **Reasoning journal** — write a brief entry about what you thought about tonight (trajectories, not outcomes)

## Phase 4 — The Dreaming (most important)

This is the differentiator. See `references/dream-prompt.md` for the full prompt.

The goal: read broadly in the agent's primary domain, then ask *"does this connect to anything we're doing in a non-obvious way?"*

Generate 1–3 "what if" hypotheses. Wild is fine. Clearly labeled speculative. Not action-ready — directional.

The "Best Thought Tonight" line is what gets surfaced at morning DM time. Make it good.

## Adapting to a New Agent

- Change the domain feed in Phase 4 to match the agent's domain (bioRxiv, arXiv, industry news, etc.)
- Adjust stale thresholds in Phase 2 if the team moves faster/slower
- The output format is fixed — other agents and morning crons depend on it

## Further Reading

- Full 4-phase prompt: `references/dream-prompt.md`
