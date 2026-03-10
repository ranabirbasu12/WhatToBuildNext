#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NEXUS_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
DB_FILE="${NEXUS_ROOT}/nexus.db"

# Graceful exit if DB or sqlite3 not available
if [[ ! -f "$DB_FILE" ]]; then
  exit 0
fi

if ! command -v sqlite3 &>/dev/null; then
  exit 0
fi

# Calculate expiry threshold (7 days from now)
if [[ "$(uname)" == "Darwin" ]]; then
  EXPIRY_THRESHOLD="$(date -u -v+7d +"%Y-%m-%dT%H:%M:%SZ")"
else
  EXPIRY_THRESHOLD="$(date -u -d "+7 days" +"%Y-%m-%dT%H:%M:%SZ")"
fi

SHOWN_SOMETHING=false

# --- Active Tasks ---
TASK_COUNT="$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM tasks WHERE status IN ('pending','in_progress');")"

if [[ "$TASK_COUNT" -gt 0 ]]; then
  echo "=== Nexus: ${TASK_COUNT} Active Tasks ==="
  sqlite3 "$DB_FILE" "SELECT id || ' [' || UPPER(status) || '] (' || assignee || ') ' || title FROM tasks WHERE status IN ('pending','in_progress') ORDER BY priority DESC, created_at ASC;"
  SHOWN_SOMETHING=true
fi

# --- Expiring Knowledge ---
KNOWLEDGE_COUNT="$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM knowledge WHERE expires_at IS NOT NULL AND expires_at <= '${EXPIRY_THRESHOLD}' AND expires_at > datetime('now');")"

if [[ "$KNOWLEDGE_COUNT" -gt 0 ]]; then
  if $SHOWN_SOMETHING; then
    echo ""
  fi
  echo "=== Nexus: ${KNOWLEDGE_COUNT} Knowledge Entries Expiring Soon ==="
  sqlite3 "$DB_FILE" "SELECT id || ' [' || type || '] ' || fact || ' (expires: ' || date(expires_at) || ')' FROM knowledge WHERE expires_at IS NOT NULL AND expires_at <= '${EXPIRY_THRESHOLD}' AND expires_at > datetime('now') ORDER BY expires_at ASC;"
  echo "Review these entries. Promote valuable ones to conventions.md or renew them."
  SHOWN_SOMETHING=true
fi

# --- Nothing to report ---
if ! $SHOWN_SOMETHING; then
  echo "Nexus: No pending tasks or expiring knowledge. Ready to work."
fi
