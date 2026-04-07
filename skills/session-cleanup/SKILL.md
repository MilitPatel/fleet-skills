# SKILL.md — session-cleanup

## Purpose
Prune stale sessions from the OpenClaw session store to prevent session count bloat, which contributes to gateway instability and slow startup.

## Trigger Conditions
- Session count > 40 (warning)
- Session count > 60 (act immediately)
- Before a scheduled reset (morning/lunch/evening)
- After any compaction loop incident

## Step 1 — Check current session count
```bash
openclaw sessions 2>&1 | head -3
```

Look for `Sessions listed: N`. If N > 40, proceed.

## Step 2 — Run built-in cleanup first
```bash
openclaw sessions cleanup
```
This handles stale locks and corruption but does NOT remove old sessions. Check count again — if still high, proceed to Step 3.

## Step 3 — Manual prune (sessions older than 24h)
```bash
cd ~/.openclaw/agents/main/sessions && \
cp sessions.json sessions.json.bak-$(date +%Y%m%d-%H%M) && \
node -e "
const fs = require('fs');
const raw = fs.readFileSync('sessions.json','utf8');
const data = JSON.parse(raw);
const now = Date.now();
const cutoff = now - (24 * 60 * 60 * 1000); // 24h

if (Array.isArray(data)) {
  const kept = data.filter(s => (s.updatedAt || s.lastActivity || 0) > cutoff);
  fs.writeFileSync('sessions.json', JSON.stringify(kept, null, 2));
  console.log('Done. Kept:', kept.length, 'of', data.length);
} else if (data.sessions) {
  const kept = data.sessions.filter(s => (s.updatedAt || s.lastActivity || 0) > cutoff);
  data.sessions = kept;
  fs.writeFileSync('sessions.json', JSON.stringify(data, null, 2));
  console.log('Done. Kept:', kept.length, 'sessions');
} else {
  const keys = Object.keys(data);
  const newData = {};
  let kept = 0, removed = 0;
  keys.forEach(k => {
    const s = data[k];
    if ((s.updatedAt || s.lastActivity || 0) > cutoff) { newData[k] = s; kept++; }
    else removed++;
  });
  fs.writeFileSync('sessions.json', JSON.stringify(newData, null, 2));
  console.log('Done. Kept:', kept, 'Removed:', removed);
}
"
```

## Step 4 — Verify
```bash
openclaw sessions 2>&1 | head -3
```
Count should now be under 30. If gateway feels sluggish after pruning, restart it:
```bash
openclaw gateway restart
```

## What NOT to do
- Do NOT use `openclaw reset --scope config+creds+sessions` — this wipes credentials too
- Do NOT delete sessions.json entirely — always backup first (the bak file above handles this)
- Do NOT prune sessions newer than 2h — active cron sessions may still be in use

## Backup location
Backups written to: `~/.openclaw/agents/main/sessions/sessions.json.bak-YYYYMMDD-HHMM`
Safe to delete backups older than 7 days.

## Bloat Guardian Note
Per AGENTS.md, a Bloat Guardian cron runs every 15 min on the main session. If session count exceeds 80, it logs and resets. This skill is the manual equivalent — run it before hitting 80 to avoid the forced reset.

*Skill authored by Uvy 🦾 | 2026-04-07*
