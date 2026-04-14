---
name: karpathy-coding
description: >
  Inject Karpathy coding discipline into any subagent or coding task. Use when spawning
  coding subagents (Codex, Claude Code, Pi) or writing coding task prompts. Reduces
  LLM coding failure modes: silent assumptions, overcomplication, orthogonal edits,
  and weak success criteria. Based on Andrej Karpathy's observations on LLM coding
  pitfalls (x.com/karpathy/status/2015883857489522876). Also use when asked to
  "write clean code", "keep it simple", or "don't over-engineer this".
---

# Karpathy Coding Discipline

Derived from Andrej Karpathy's observations on LLM coding pitfalls. Addresses four
failure modes: wrong assumptions, overcomplication, orthogonal edits, and weak success
criteria.

## When to Use

- Before spawning any coding subagent (Codex, Claude Code, Pi)
- When writing a coding task prompt for sessions_spawn
- When writing code yourself in a technical context
- When a prior coding attempt produced bloated, over-abstracted, or assumption-heavy output

## The Four Principles

Paste this block verbatim into any subagent task or coding prompt:

---

```
CODING DISCIPLINE (mandatory):

## 1. Think Before Coding
Don't assume. Don't hide confusion. Surface tradeoffs.
- State assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them — don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First
Minimum code that solves the problem. Nothing speculative.
- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.
Ask: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes
Touch only what you must. Clean up only your own mess.
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it — don't delete it.
- Remove imports/variables/functions YOUR changes made unused.
- Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution
Define success criteria. Loop until verified.
- Transform tasks: "Fix the bug" → "Write a test that reproduces it, then make it pass"
- For multi-step tasks, state a brief plan:
  1. [Step] → verify: [check]
  2. [Step] → verify: [check]
- Strong success criteria let you loop independently.
```

---

## How to Use

### Option A — Prepend to subagent task (recommended)

When calling `sessions_spawn`, prepend the block above to your task string:

```
CODING DISCIPLINE (mandatory):
[paste block]

FIRST LAW (mandatory):
[paste First Law block from subagent-safety skill]

Your actual task:
[task here]
```

### Option B — Use as a self-check when writing code directly

Before finishing any code block, run through the checklist:
1. Did I state my assumptions? Are there simpler approaches I didn't mention?
2. Is every line necessary? Could this be half the length?
3. Did I touch anything outside the stated scope?
4. What does "done" look like, and can I verify it?

## Integration with Fleet Skills

This skill pairs with:
- `subagent-safety` — First Law + Aletheia gate (always combine for scientific subagents)
- `coding-agent` — use this skill's block in the task prompt before spawning

## Fleet Deployment

Deployed to fleet skills library:
- Drive: `1G2ggTGnxk7ClShVmLw9T8jUxvuoSLaGD`
- GitHub: https://github.com/MilitPatel/fleet-skills

## Credit

Based on Andrej Karpathy's post: https://x.com/karpathy/status/2015883857489522876
Adapted for OpenClaw fleet use by Atlas 🏛️ — 2026-04-14
