#!/usr/bin/env bash
set -euo pipefail

NEXUS_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "╔══════════════════════════════════════════╗"
echo "║            N E X U S  STATUS             ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# Task Board
"$NEXUS_ROOT/scripts/nexus-board.sh" summary
echo ""

# Usage
echo "=== Codex Usage ==="
USAGE="$NEXUS_ROOT/logs/usage.json"
if [[ -f "$USAGE" ]]; then
  DISPATCHES=$(jq '.total_dispatches' "$USAGE")
  DURATION=$(jq '.total_duration_seconds' "$USAGE")
  echo "Total dispatches: $DISPATCHES"
  echo "Total time: ${DURATION}s"
  if [[ "$DISPATCHES" -gt 0 ]]; then
    echo ""
    echo "By mode:"
    jq -r '.by_mode | to_entries[] | "  \(.key): \(.value)"' "$USAGE" 2>/dev/null || true
    echo ""
    echo "By model:"
    jq -r '.by_model | to_entries[] | "  \(.key): \(.value)"' "$USAGE" 2>/dev/null || true
    echo ""
    echo "Session history:"
    jq -r '.session_history[] | "  \(.date): \(.dispatches) dispatches, \(.duration)s"' "$USAGE" 2>/dev/null || true
  fi
else
  echo "No usage data yet."
fi
echo ""

# Knowledge
echo "=== Knowledge Base ==="
KB="$NEXUS_ROOT/context/knowledge.jsonl"
if [[ -s "$KB" ]]; then
  TOTAL=$(wc -l < "$KB" | tr -d ' ')
  echo "Entries: $TOTAL"
  echo ""
  echo "By type:"
  jq -r '.type' "$KB" | sort | uniq -c | sort -rn | sed 's/^/  /'
else
  echo "Entries: 0 (empty)"
fi
echo ""

# Recent Dispatches
echo "=== Recent Dispatches (last 5) ==="
DISPATCHES_LOG="$NEXUS_ROOT/logs/dispatches.jsonl"
if [[ -s "$DISPATCHES_LOG" ]]; then
  tail -5 "$DISPATCHES_LOG" | jq -r '"  \(.taskId) [\(.mode)] \(.duration_seconds)s exit:\(.exit_code) — \(.prompt_summary)"'
else
  echo "  (none yet)"
fi
echo ""
echo "─────────────────────────────────────────"
