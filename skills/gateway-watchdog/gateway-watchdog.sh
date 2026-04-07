#!/bin/bash
# gateway-watchdog.sh
# Fleet gateway watchdog — checks if OpenClaw gateway is responsive, restarts if not.
# SAFE: will not restart its own host's gateway if run during an active session.
#
# Usage: bash gateway-watchdog.sh [--self] [--host <tailscale-ip>] [--user <username>]
#   --self         Check and restart THIS machine's gateway (safe mode — adds guard)
#   --host <ip>    Check a remote machine (SSH)
#   --user <name>  SSH username for remote check
#
# Fleet usage (from cron or heartbeat):
#   Check self:    bash gateway-watchdog.sh --self
#   Check remote:  bash gateway-watchdog.sh --host 100.108.211.25 --user zevo
#
# Author: Uvy 🦾 (rewrite from SARAH's v1, 2026-04-07)
# Lesson: never run launchctl bootout on yourself mid-session without a guard.

set -uo pipefail

# ── Config ──────────────────────────────────────────────────────────────────
SELF_MODE=false
REMOTE_HOST=""
REMOTE_USER=""
LOG_FILE="/tmp/gateway-watchdog-$(date +%Y%m%d).log"
PROBE_TIMEOUT=5  # seconds to wait for gateway RPC probe

# ── Parse args ───────────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case $1 in
    --self)   SELF_MODE=true; shift ;;
    --host)   REMOTE_HOST="$2"; shift 2 ;;
    --user)   REMOTE_USER="$2"; shift 2 ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done

# ── Helpers ──────────────────────────────────────────────────────────────────
log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"; }

check_gateway_local() {
  # Returns 0 if gateway is alive, 1 if dead
  export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
  openclaw gateway status 2>&1 | grep -q "running (pid"
}

restart_gateway_local() {
  export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
  # Use launchctl bootstrap (not openclaw gateway restart) to handle unloaded LaunchAgent
  local PLIST="$HOME/Library/LaunchAgents/ai.openclaw.gateway.plist"
  local UID_VAL
  UID_VAL=$(id -u)

  if launchctl list | grep -q "ai.openclaw.gateway"; then
    log "LaunchAgent loaded — using openclaw gateway restart"
    openclaw gateway restart 2>&1
  else
    log "LaunchAgent not loaded — bootstrapping from plist"
    launchctl bootstrap "gui/$UID_VAL" "$PLIST" 2>&1
  fi

  sleep 3
  if check_gateway_local; then
    log "✅ Gateway restarted successfully"
    return 0
  else
    log "❌ Gateway still down after restart attempt"
    return 1
  fi
}

# ── SELF MODE ────────────────────────────────────────────────────────────────
if $SELF_MODE; then
  log "Checking local gateway..."

  if check_gateway_local; then
    log "✅ Gateway healthy — no action needed"
    exit 0
  fi

  log "⚠️  Gateway unresponsive — preparing restart"

  # SELF-GUARD: Check if an active agent session is running
  # If openclaw is actively processing (agent session active in last 2 min), skip restart
  ACTIVE_SESSIONS=$(openclaw sessions --active 2 2>/dev/null | grep -c "ago" || echo "0")
  if [[ "$ACTIVE_SESSIONS" -gt 1 ]]; then
    # >1 because the watchdog session itself may appear
    log "⚠️  GUARD TRIGGERED: $ACTIVE_SESSIONS active sessions detected — skipping self-restart"
    log "    Restart manually or wait for session to end"
    exit 2
  fi

  log "No active sessions detected — proceeding with restart"
  restart_gateway_local
  exit $?
fi

# ── REMOTE MODE ──────────────────────────────────────────────────────────────
if [[ -n "$REMOTE_HOST" && -n "$REMOTE_USER" ]]; then
  log "Checking remote gateway: $REMOTE_USER@$REMOTE_HOST"

  # Check if gateway is alive — use nc port check (fast) rather than openclaw status (slow on old hw)
  REMOTE_STATUS=$(ssh -i ~/.ssh/id_ed25519 -o IdentitiesOnly=yes \
    -o ConnectTimeout=5 -o BatchMode=yes \
    "$REMOTE_USER@$REMOTE_HOST" \
    "nc -z 127.0.0.1 18789 && echo 'listening' || echo 'not listening'" 2>&1)

  if echo "$REMOTE_STATUS" | grep -q "listening"; then
    log "✅ $REMOTE_HOST gateway healthy"
    exit 0
  fi

  log "⚠️  $REMOTE_HOST gateway unresponsive — attempting remote restart"

  RESTART_RESULT=$(ssh -i ~/.ssh/id_ed25519 -o IdentitiesOnly=yes \
    -o ConnectTimeout=5 -o BatchMode=yes \
    "$REMOTE_USER@$REMOTE_HOST" \
    'export PATH=/opt/homebrew/bin:/usr/local/bin:$(ls -d ~/.nvm/versions/node/*/bin 2>/dev/null | tail -1):$PATH
    PLIST="$HOME/Library/LaunchAgents/ai.openclaw.gateway.plist"
    UID_VAL=$(id -u)
    if launchctl list 2>/dev/null | grep -q "ai.openclaw.gateway"; then
      openclaw gateway restart 2>&1
    else
      launchctl bootstrap "gui/$UID_VAL" "$PLIST" 2>&1
    fi
    sleep 3
    openclaw gateway status 2>&1' 2>&1)

  if echo "$RESTART_RESULT" | grep -q "running (pid"; then
    log "✅ $REMOTE_HOST gateway restarted successfully"
    exit 0
  else
    log "❌ $REMOTE_HOST gateway still down after restart"
    log "   Output: $RESTART_RESULT"
    exit 1
  fi
fi

echo "Usage: bash gateway-watchdog.sh --self | --host <ip> --user <username>"
exit 1
