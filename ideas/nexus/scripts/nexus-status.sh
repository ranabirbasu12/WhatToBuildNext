#!/usr/bin/env bash
set -euo pipefail

NEXUS_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DB_FILE="${NEXUS_ROOT}/nexus.db"

echo "╔══════════════════════════════════════════╗"
echo "║            N E X U S  STATUS             ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# Task Board
"$NEXUS_ROOT/scripts/nexus-board.sh" summary
echo ""

# Usage
echo "=== Codex Usage ==="
if [[ -f "$DB_FILE" ]]; then
  TOTAL_DISPATCHES="$(sqlite3 "$DB_FILE" "SELECT COALESCE(SUM(dispatches),0) FROM usage;")"
  TOTAL_DURATION="$(sqlite3 "$DB_FILE" "SELECT COALESCE(SUM(duration_seconds),0) FROM usage;")"
  echo "Total dispatches: $TOTAL_DISPATCHES"
  echo "Total time: ${TOTAL_DURATION}s"
  if [[ "$TOTAL_DISPATCHES" -gt 0 ]]; then
    echo ""
    echo "By mode:"
    sqlite3 "$DB_FILE" "SELECT '  ' || mode || ': ' || COUNT(*) FROM dispatches GROUP BY mode;" 2>/dev/null || true
    echo ""
    echo "By model:"
    sqlite3 "$DB_FILE" "SELECT '  ' || model || ': ' || COUNT(*) FROM dispatches GROUP BY model;" 2>/dev/null || true
    echo ""
    echo "Session history:"
    sqlite3 "$DB_FILE" "SELECT '  ' || date || ': ' || dispatches || ' dispatches, ' || duration_seconds || 's' FROM usage ORDER BY date DESC LIMIT 5;" 2>/dev/null || true
  fi
else
  echo "No usage data yet."
fi
echo ""

# Knowledge
echo "=== Knowledge Base ==="
if [[ -f "$DB_FILE" ]]; then
  TOTAL="$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM knowledge WHERE expires_at IS NULL OR expires_at > datetime('now');")"
  echo "Entries: $TOTAL"
  if [[ "$TOTAL" -gt 0 ]]; then
    echo ""
    echo "By type:"
    sqlite3 "$DB_FILE" "SELECT '  ' || type || ': ' || COUNT(*) FROM knowledge WHERE expires_at IS NULL OR expires_at > datetime('now') GROUP BY type ORDER BY COUNT(*) DESC;" 2>/dev/null || true
  fi
else
  echo "Entries: 0 (empty)"
fi
echo ""

# Failure Taxonomy (NEW)
echo "=== Failure Taxonomy ==="
if [[ -f "$DB_FILE" ]]; then
  FAILURES="$(sqlite3 "$DB_FILE" "SELECT failure_type, COUNT(*) FROM dispatches WHERE failure_type IS NOT NULL GROUP BY failure_type ORDER BY COUNT(*) DESC;" 2>/dev/null || true)"
  if [[ -n "$FAILURES" ]]; then
    echo "$FAILURES" | while IFS='|' read -r ftype fcount; do
      echo "  ${ftype}: ${fcount}"
    done
  else
    echo "  (no failures recorded)"
  fi
else
  echo "  (no data)"
fi
echo ""

# Recent Dispatches
echo "=== Recent Dispatches (last 5) ==="
if [[ -f "$DB_FILE" ]]; then
  RECENT="$(sqlite3 "$DB_FILE" "SELECT task_id, mode, duration_seconds, exit_code, prompt_summary FROM dispatches ORDER BY timestamp DESC LIMIT 5;" 2>/dev/null || true)"
  if [[ -n "$RECENT" ]]; then
    echo "$RECENT" | while IFS='|' read -r tid dmode ddur dexit dprompt; do
      echo "  ${tid} [${dmode}] ${ddur}s exit:${dexit} — ${dprompt}"
    done
  else
    echo "  (none yet)"
  fi
else
  echo "  (none yet)"
fi
echo ""
echo "─────────────────────────────────────────"
