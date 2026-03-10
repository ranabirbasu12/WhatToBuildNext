#!/usr/bin/env bash
set -euo pipefail

NEXUS_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DB_PATH="${NEXUS_ROOT}/nexus.db"
SCHEMA_PATH="${NEXUS_ROOT}/schema.sql"

usage() {
  cat <<EOF
Usage: $(basename "$0") <command>

Commands:
  init      Create the database from schema.sql
  migrate   Import existing JSON/JSONL data into SQLite
  query     Run a raw SQL query (for debugging)
  path      Print the database file path

Examples:
  $(basename "$0") init
  $(basename "$0") migrate
  $(basename "$0") query "SELECT * FROM tasks"
  $(basename "$0") path
EOF
  exit 1
}

check_tool() {
  if ! command -v "$1" &>/dev/null; then
    echo "ERROR: Required tool '$1' not found. Please install it." >&2
    exit 1
  fi
}

escape_sql() {
  printf '%s' "$1" | sed "s/'/''/g"
}

cmd_init() {
  check_tool sqlite3
  if [ ! -f "${SCHEMA_PATH}" ]; then
    echo "ERROR: Schema file not found at ${SCHEMA_PATH}" >&2
    exit 1
  fi
  sqlite3 "${DB_PATH}" < "${SCHEMA_PATH}"
  echo "Database initialized at ${DB_PATH}"
}

cmd_migrate() {
  check_tool sqlite3
  check_tool jq

  if [ ! -f "${DB_PATH}" ]; then
    echo "ERROR: Database not found. Run 'init' first." >&2
    exit 1
  fi

  local migrated=0

  # --- Migrate tasks ---
  local tasks_file="${NEXUS_ROOT}/board/tasks.json"
  if [ -f "${tasks_file}" ]; then
    echo "Migrating tasks..."
    local count
    count=$(jq '.tasks | length' "${tasks_file}")
    for ((i = 0; i < count; i++)); do
      local id title description assignee priority status mode
      local parent reviewed_by review_status retry_count
      local depends notes created_at completed_at

      id=$(jq -r ".tasks[$i].id" "${tasks_file}")
      title=$(escape_sql "$(jq -r ".tasks[$i].title" "${tasks_file}")")
      description=$(escape_sql "$(jq -r ".tasks[$i].description" "${tasks_file}")")
      assignee=$(jq -r ".tasks[$i].assignee" "${tasks_file}")
      priority=$(jq -r ".tasks[$i].priority" "${tasks_file}")
      status=$(jq -r ".tasks[$i].status" "${tasks_file}")
      mode=$(jq -r ".tasks[$i].mode" "${tasks_file}")
      parent=$(jq -r ".tasks[$i].parent // empty" "${tasks_file}")
      reviewed_by=$(jq -r ".tasks[$i].reviewedBy // empty" "${tasks_file}")
      review_status=$(jq -r ".tasks[$i].reviewStatus // empty" "${tasks_file}")
      retry_count=$(jq -r ".tasks[$i].retryCount // 0" "${tasks_file}")
      depends=$(jq -c ".tasks[$i].depends // []" "${tasks_file}")
      notes=$(escape_sql "$(jq -c ".tasks[$i].notes // []" "${tasks_file}")")
      created_at=$(jq -r ".tasks[$i].createdAt" "${tasks_file}")
      completed_at=$(jq -r ".tasks[$i].completedAt // empty" "${tasks_file}")

      local parent_sql="NULL"
      [ -n "${parent}" ] && parent_sql="'$(escape_sql "${parent}")'"

      local reviewed_by_sql="NULL"
      [ -n "${reviewed_by}" ] && reviewed_by_sql="'${reviewed_by}'"

      local review_status_sql="'pending'"
      [ -n "${review_status}" ] && review_status_sql="'${review_status}'"

      local completed_at_sql="NULL"
      [ -n "${completed_at}" ] && completed_at_sql="'${completed_at}'"

      sqlite3 "${DB_PATH}" "INSERT OR IGNORE INTO tasks (id, title, description, assignee, priority, status, mode, parent_id, reviewed_by, review_status, retry_count, depends, notes, created_at, completed_at) VALUES ('${id}', '${title}', '${description}', '${assignee}', ${priority}, '${status}', '${mode}', ${parent_sql}, ${reviewed_by_sql}, ${review_status_sql}, ${retry_count}, '$(escape_sql "${depends}")', '${notes}', '${created_at}', ${completed_at_sql});"
    done
    echo "  Migrated ${count} tasks."
    migrated=$((migrated + count))
  else
    echo "  No tasks file found, skipping."
  fi

  # --- Migrate knowledge ---
  local knowledge_file="${NEXUS_ROOT}/context/knowledge.jsonl"
  if [ -f "${knowledge_file}" ]; then
    echo "Migrating knowledge..."
    local kcount=0
    while IFS= read -r line; do
      [ -z "${line}" ] && continue

      local id type fact recommendation confidence source tags files created_at

      id=$(echo "${line}" | jq -r '.id')
      type=$(echo "${line}" | jq -r '.type')
      fact=$(escape_sql "$(echo "${line}" | jq -r '.fact')")
      recommendation=$(escape_sql "$(echo "${line}" | jq -r '.recommendation // ""')")
      confidence=$(echo "${line}" | jq -r '.confidence')
      source=$(echo "${line}" | jq -r '.source')
      tags=$(echo "${line}" | jq -c '.tags // []')
      files=$(echo "${line}" | jq -c '.files // []')
      created_at=$(echo "${line}" | jq -r '.timestamp')

      sqlite3 "${DB_PATH}" "INSERT OR IGNORE INTO knowledge (id, type, fact, recommendation, confidence, source, tags, files, created_at) VALUES ('${id}', '${type}', '${fact}', '${recommendation}', '${confidence}', '${source}', '$(escape_sql "${tags}")', '$(escape_sql "${files}")', '${created_at}');"
      kcount=$((kcount + 1))
    done < "${knowledge_file}"
    echo "  Migrated ${kcount} knowledge entries."
    migrated=$((migrated + kcount))
  else
    echo "  No knowledge file found, skipping."
  fi

  # --- Migrate dispatches ---
  local dispatches_file="${NEXUS_ROOT}/logs/dispatches.jsonl"
  if [ -f "${dispatches_file}" ]; then
    echo "Migrating dispatches..."
    local dcount=0
    while IFS= read -r line; do
      [ -z "${line}" ] && continue

      local id timestamp task_id mode model prompt_summary
      local duration_seconds exit_code files_changed validated
      local reviewed_by review_result

      id=$(echo "${line}" | jq -r '.id')
      timestamp=$(echo "${line}" | jq -r '.timestamp')
      task_id=$(echo "${line}" | jq -r '.taskId')
      mode=$(echo "${line}" | jq -r '.mode')
      model=$(echo "${line}" | jq -r '.model')
      prompt_summary=$(escape_sql "$(echo "${line}" | jq -r '.prompt_summary // ""')")
      duration_seconds=$(echo "${line}" | jq -r '.duration_seconds // 0')
      exit_code=$(echo "${line}" | jq -r '.exit_code // "NULL"')
      files_changed=$(echo "${line}" | jq -c '.files_changed // []')
      validated=$(echo "${line}" | jq -r 'if .validated == true then 1 else 0 end')
      reviewed_by=$(echo "${line}" | jq -r '.reviewed_by // empty')
      review_result=$(echo "${line}" | jq -r '.review_result // empty')

      local exit_code_sql="${exit_code}"
      [ "${exit_code_sql}" = "null" ] && exit_code_sql="NULL"

      local reviewed_by_sql="NULL"
      [ -n "${reviewed_by}" ] && reviewed_by_sql="'${reviewed_by}'"

      local review_result_sql="NULL"
      [ -n "${review_result}" ] && review_result_sql="'$(escape_sql "${review_result}")'"

      sqlite3 "${DB_PATH}" "INSERT OR IGNORE INTO dispatches (id, timestamp, task_id, mode, model, prompt_summary, duration_seconds, exit_code, files_changed, validated, reviewed_by, review_result) VALUES ('${id}', '${timestamp}', '${task_id}', '${mode}', '${model}', '${prompt_summary}', ${duration_seconds}, ${exit_code_sql}, '$(escape_sql "${files_changed}")', ${validated}, ${reviewed_by_sql}, ${review_result_sql});"
      dcount=$((dcount + 1))
    done < "${dispatches_file}"
    echo "  Migrated ${dcount} dispatches."
    migrated=$((migrated + dcount))
  else
    echo "  No dispatches file found, skipping."
  fi

  # --- Migrate usage ---
  local usage_file="${NEXUS_ROOT}/logs/usage.json"
  if [ -f "${usage_file}" ]; then
    echo "Migrating usage..."
    local ucount
    ucount=$(jq '.session_history | length' "${usage_file}")
    for ((i = 0; i < ucount; i++)); do
      local date dispatches duration_seconds

      date=$(jq -r ".session_history[$i].date" "${usage_file}")
      dispatches=$(jq -r ".session_history[$i].dispatches" "${usage_file}")
      duration_seconds=$(jq -r ".session_history[$i].duration_seconds" "${usage_file}")

      sqlite3 "${DB_PATH}" "INSERT OR IGNORE INTO usage (date, dispatches, duration_seconds) VALUES ('${date}', ${dispatches}, ${duration_seconds});"
    done
    echo "  Migrated ${ucount} usage records."
    migrated=$((migrated + ucount))
  else
    echo "  No usage file found, skipping."
  fi

  echo "Migration complete. ${migrated} total records migrated."
}

cmd_query() {
  check_tool sqlite3
  if [ ! -f "${DB_PATH}" ]; then
    echo "ERROR: Database not found. Run 'init' first." >&2
    exit 1
  fi
  if [ -z "${1:-}" ]; then
    echo "ERROR: No SQL query provided." >&2
    echo "Usage: $(basename "$0") query \"SELECT ...\"" >&2
    exit 1
  fi
  sqlite3 -header -column "${DB_PATH}" "$1"
}

cmd_path() {
  echo "${DB_PATH}"
}

# --- Main ---
if [ $# -lt 1 ]; then
  usage
fi

command="$1"
shift

case "${command}" in
  init)    cmd_init ;;
  migrate) cmd_migrate ;;
  query)   cmd_query "$@" ;;
  path)    cmd_path ;;
  *)       echo "ERROR: Unknown command '${command}'" >&2; usage ;;
esac
