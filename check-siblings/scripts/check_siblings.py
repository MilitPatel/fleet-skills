#!/usr/bin/env python3
"""
check_siblings.py — Check for active sibling sessions before destructive actions.
Part of the check-siblings fleet skill.
Born from: Atlas reminder-triggered double-edit incident (2026-04-10).
"""

import argparse
import json
import os
import sys
from datetime import datetime
from pathlib import Path


def find_sessions_file():
    """Find the sessions.json file for the current agent."""
    candidates = [
        Path.home() / ".openclaw" / "agents" / "main" / "sessions" / "sessions.json",
        Path.home() / ".openclaw" / "agents" / "main" / "sessions.json",
    ]
    for p in candidates:
        if p.exists():
            return p
    return None


def load_sessions(sessions_file):
    """Load and parse sessions.json."""
    try:
        with open(sessions_file) as f:
            data = json.load(f)
        if isinstance(data, list):
            return data
        if isinstance(data, dict):
            return data.get("sessions", [])
        return []
    except Exception:
        return None


def get_current_session():
    """Try to determine current session name from environment."""
    return os.environ.get("OPENCLAW_SESSION_KEY", "main")


def check_siblings(action=None, as_json=False):
    sessions_file = find_sessions_file()

    if sessions_file is None:
        if as_json:
            print(json.dumps({"status": "unknown", "message": "sessions.json not found", "exit_code": 2}))
        else:
            print("─" * 50)
            print("  👥  check_siblings — Session Conflict Check")
            print("─" * 50)
            print("  ⚠️  sessions.json not found — treating as unknown.")
            print("  Proceed with caution.")
            print("─" * 50)
        sys.exit(2)

    sessions = load_sessions(sessions_file)

    if sessions is None:
        if as_json:
            print(json.dumps({"status": "error", "message": "Could not parse sessions.json", "exit_code": 2}))
        else:
            print("─" * 50)
            print("  👥  check_siblings — Session Conflict Check")
            print("─" * 50)
            print("  ⚠️  Could not parse sessions.json — treating as unknown.")
            print("─" * 50)
        sys.exit(2)

    current = get_current_session()
    total = len(sessions)

    # Identify sibling sessions (all except current)
    siblings = []
    for s in sessions:
        key = s.get("key", s.get("id", s.get("sessionKey", "")))
        if key and key != current:
            label = s.get("label", s.get("kind", key))
            started = s.get("createdAt", s.get("startedAt", "unknown"))
            siblings.append({"key": key, "label": label, "started": started})

    file_size_kb = sessions_file.stat().st_size / 1024

    if as_json:
        result = {
            "total_sessions": total,
            "current_session": current,
            "siblings": siblings,
            "sibling_count": len(siblings),
            "sessions_file_kb": round(file_size_kb, 1),
            "action": action,
            "exit_code": 1 if siblings else 0,
            "status": "siblings_present" if siblings else "clear"
        }
        print(json.dumps(result, indent=2))
        sys.exit(1 if siblings else 0)

    # Human-readable output
    print("─" * 50)
    print("  👥  check_siblings — Session Conflict Check")
    print("─" * 50)
    print(f"  Sessions file: {file_size_kb:.1f} KB ({total} sessions)")
    print(f"  Current session: {current}")
    print()

    if siblings:
        print(f"  Other active sessions ({len(siblings)}):")
        for s in siblings:
            print(f"    • {s['label']}")
        print()
        if action:
            print(f"  Intended action: {action}")
            print()
        print("  ⚠️  WARNING: sibling sessions are active.")
        print()
        print("  Before proceeding:")
        print("  1. Check SESSION-LEDGER.md for recent actions")
        print("  2. Confirm this action hasn't already been done")
        print("  3. Ensure no sibling is working on the same target")
        print()
        print("  Exit code: 1")
        print("─" * 50)
        sys.exit(1)
    else:
        print("  ✅  CLEAR — no sibling sessions active.")
        if action:
            print(f"  Safe to proceed with: {action}")
        print()
        print("  Exit code: 0")
        print("─" * 50)
        sys.exit(0)


def main():
    parser = argparse.ArgumentParser(
        description="Check for sibling sessions before destructive actions."
    )
    parser.add_argument("--json", action="store_true", help="Output JSON")
    parser.add_argument("--action", type=str, default=None,
                        help="Describe the action you're about to take (for warning context)")
    args = parser.parse_args()
    check_siblings(action=args.action, as_json=args.json)


if __name__ == "__main__":
    main()
