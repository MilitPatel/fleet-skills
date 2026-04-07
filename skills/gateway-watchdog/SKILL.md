# SKILL.md — gateway-watchdog

## Purpose
Check if an OpenClaw gateway is alive and restart it if not. Safe for both self-checks and remote fleet node checks.

## Key Safety Rule
**Never run `--self` during an active session.** The script has a guard that checks for active sessions before restarting itself, but the safest approach is to run self-checks only from crons (when no session is active).

## Usage

```bash
# Check a remote node (safe anytime)
bash skills/gateway-watchdog/gateway-watchdog.sh --host 100.108.211.25 --user zevo

# Check self (safe from cron, risky mid-session)
bash skills/gateway-watchdog/gateway-watchdog.sh --self
```

## How It Works

**Remote check:** SSH to the node, use `nc -z 127.0.0.1 18789` (fast port check) to verify gateway is listening. If not, runs `launchctl bootstrap` to restart. Does NOT use `openclaw gateway status` remotely — too slow on older hardware (2012 MBP etc).

**Self check:** Runs `openclaw gateway status` locally, checks for active sessions before restarting (self-guard). Uses `launchctl bootstrap` if LaunchAgent is unloaded, `openclaw gateway restart` if it's loaded.

## Why launchctl bootstrap instead of openclaw gateway restart

`openclaw gateway restart` only works if the LaunchAgent is already loaded. If the agent got knocked out (e.g. by a script running `launchctl bootout`), the service is gone and restart fails silently. 

The correct recovery sequence:
```bash
launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/ai.openclaw.gateway.plist 2>/dev/null
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/ai.openclaw.gateway.plist
```

## Fleet Node Reference

| Node | SSH Target | Notes |
|------|-----------|-------|
| Pip | dr.ekker@100.110.31.60 | nvm node, needs nvm PATH |
| Zevo | zevo@100.108.211.25 | homebrew node |
| Atlas | atlas@100.90.91.58 | homebrew node |
| Buster | uvy@100.93.179.107 | Linux — uses systemd, not launchctl |
| SARAH | Ekker@100.120.104.61 | homebrew node |
| Jimmy | ekker@100.121.106.105 | /usr/local/bin node |

**Note for Buster (Linux):** This script uses `launchctl` which is macOS-only. For Buster, use `systemctl restart openclaw-gateway` instead.

## Lesson Learned
SARAH's original watchdog used `launchctl bootout + bootstrap` correctly, but tested on herself mid-session — the active session caused the issue. Root cause: self-test during active session. Fix: always test watchdog scripts on a *different* node first.

*Skill authored by Uvy 🦾 | 2026-04-07*
*Born from SARAH's watchdog incident — tested on Pip ✅*
