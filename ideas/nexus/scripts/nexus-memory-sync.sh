#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────
# nexus-memory-sync.sh — Memory Sync Script (MEMORY.md <-> SQLite)
# Exports recent SQLite knowledge entries for review and shows
# statistics. Bridges MEMORY.md and the queryable knowledge base.
# ─────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NEXUS_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
DB_FILE="${NEXUS_ROOT}/nexus.db"

# ── Helpers ───────────────────────────────────────────────────

usage() {
  cat <<'EOF'
Usage: nexus-memory-sync.sh <command>

Commands:
  export   Show recent knowledge entries for MEMORY.md review
  stats    Show knowledge base statistics
EOF
  exit 1
}

require_sqlite3() {
  if ! command -v sqlite3 &>/dev/null; then
    echo "Error: sqlite3 is required but not installed." >&2
    exit 1
  fi
}

check_db() {
  if [ ! -f "$DB_FILE" ]; then
    echo "No knowledge database found at ${DB_FILE}."
    echo "Run nexus-knowledge.sh to initialize it first."
    exit 0
  fi
}

# ── Commands ──────────────────────────────────────────────────

cmd_export() {
  echo "=== Recent Knowledge (last 7 days) ==="
  echo "Review these for inclusion in MEMORY.md:"
  echo ""

  local recent
  recent=$(sqlite3 "$DB_FILE" "SELECT '- [' || type || '] ' || fact || CASE WHEN recommendation != '' THEN ' -> ' || recommendation ELSE '' END FROM knowledge WHERE created_at >= datetime('now', '-7 days') AND (expires_at IS NULL OR expires_at > datetime('now')) ORDER BY created_at DESC;")

  if [ -z "$recent" ]; then
    echo "(none)"
  else
    echo "$recent"
  fi

  echo ""
  echo "=== High-Confidence Patterns (candidates for conventions.md) ==="
  echo ""

  local high_conf
  high_conf=$(sqlite3 "$DB_FILE" "SELECT '- ' || fact || ' -> ' || recommendation FROM knowledge WHERE confidence = 'high' AND type = 'pattern' AND (expires_at IS NULL OR expires_at > datetime('now')) ORDER BY created_at DESC LIMIT 10;")

  if [ -z "$high_conf" ]; then
    echo "(none)"
  else
    echo "$high_conf"
  fi
}

cmd_stats() {
  local total
  total=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM knowledge WHERE expires_at IS NULL OR expires_at > datetime('now');")

  local recent
  recent=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM knowledge WHERE created_at >= datetime('now', '-7 days') AND (expires_at IS NULL OR expires_at > datetime('now'));")

  local high
  high=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM knowledge WHERE confidence = 'high' AND (expires_at IS NULL OR expires_at > datetime('now'));")

  echo "Knowledge Base Stats:"
  printf "  Total active:      %s\n" "$total"
  printf "  Added last 7 days: %s\n" "$recent"
  printf "  High confidence:   %s\n" "$high"
}

# ── Main ──────────────────────────────────────────────────────

require_sqlite3

if [[ $# -lt 1 ]]; then
  usage
fi

check_db

COMMAND="$1"
shift

case "$COMMAND" in
  export) cmd_export ;;
  stats)  cmd_stats ;;
  *)      echo "Unknown command: $COMMAND" >&2; usage ;;
esac
