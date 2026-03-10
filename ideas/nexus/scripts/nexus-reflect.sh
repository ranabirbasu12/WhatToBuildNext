#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────
# nexus-reflect.sh — Self-Improvement Engine
# Extracts knowledge from task outcomes, detects failure
# patterns, and generates session retrospectives.
# ─────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NEXUS_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
DB_FILE="${NEXUS_ROOT}/nexus.db"

# ── Helpers ───────────────────────────────────────────────────

usage() {
  cat <<'EOF'
Usage: nexus-reflect.sh <command> [options]

Commands:
  extract   Add knowledge from task reflection
  adapt     Check failure patterns and suggest adaptations
  retro     Session retrospective

Extract options:
  --task-id <id>              Source task ID (required)
  --outcome <success|failed|retry>  Task outcome (required)
  --fact "What was learned"   Knowledge fact (required)
  --type <gotcha|pattern|decision|anti-pattern>  (required)
  --rec "Recommendation"      (optional)
  --confidence <high|medium|low>  (optional, default: medium)
  --tags "t1,t2"              (optional)
  --files "f1,f2"             (optional)
  --failure-type <type>       (optional: timeout|bad_spec|env_missing|test_flake|review_reject|crash)

Adapt options:
  --session-date YYYY-MM-DD   (optional, default: today)

Retro options:
  --session-date YYYY-MM-DD   (optional, default: today)
EOF
  exit 1
}

require_sqlite3() {
  if ! command -v sqlite3 &>/dev/null; then
    echo "Error: sqlite3 is required but not installed." >&2
    exit 1
  fi
}

require_db() {
  if [[ ! -f "$DB_FILE" ]]; then
    echo "Error: nexus.db not found at $DB_FILE" >&2
    exit 1
  fi
}

sql_escape() {
  printf '%s' "$1" | sed "s/'/''/g"
}

csv_to_json_array() {
  local csv="$1"
  if [[ -z "$csv" ]]; then
    echo "[]"
    return
  fi
  local result="["
  local first=true
  IFS=',' read -ra items <<< "$csv"
  for item in "${items[@]}"; do
    item="$(echo "$item" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    if [[ "$first" == true ]]; then
      first=false
    else
      result+=","
    fi
    result+="\"${item}\""
  done
  result+="]"
  echo "$result"
}

calc_expires_at() {
  local days="$1"
  if [[ "$(uname)" == "Darwin" ]]; then
    date -u -v+"${days}d" +"%Y-%m-%dT%H:%M:%SZ"
  else
    date -u -d "+${days} days" +"%Y-%m-%dT%H:%M:%SZ"
  fi
}

today_date() {
  date -u +"%Y-%m-%d"
}

# ── Commands ──────────────────────────────────────────────────

cmd_extract() {
  local task_id="" outcome="" fact="" type="" rec="" confidence="medium"
  local tags="" files="" failure_type=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --task-id)      task_id="$2";      shift 2 ;;
      --outcome)      outcome="$2";      shift 2 ;;
      --fact)         fact="$2";         shift 2 ;;
      --type)         type="$2";         shift 2 ;;
      --rec)          rec="$2";          shift 2 ;;
      --confidence)   confidence="$2";   shift 2 ;;
      --tags)         tags="$2";         shift 2 ;;
      --files)        files="$2";        shift 2 ;;
      --failure-type) failure_type="$2"; shift 2 ;;
      *) echo "Unknown option: $1" >&2; usage ;;
    esac
  done

  # Validate required args
  if [[ -z "$task_id" ]]; then
    echo "Error: --task-id is required." >&2; exit 1
  fi
  if [[ -z "$outcome" ]]; then
    echo "Error: --outcome is required." >&2; exit 1
  fi
  if [[ -z "$fact" ]]; then
    echo "Error: --fact is required." >&2; exit 1
  fi
  if [[ -z "$type" ]]; then
    echo "Error: --type is required." >&2; exit 1
  fi

  # Validate enum values
  case "$outcome" in
    success|failed|retry) ;;
    *) echo "Error: --outcome must be success|failed|retry" >&2; exit 1 ;;
  esac
  case "$type" in
    gotcha|pattern|decision|anti-pattern) ;;
    *) echo "Error: --type must be gotcha|pattern|decision|anti-pattern" >&2; exit 1 ;;
  esac
  case "$confidence" in
    high|medium|low) ;;
    *) echo "Error: --confidence must be high|medium|low" >&2; exit 1 ;;
  esac
  if [[ -n "$failure_type" ]]; then
    case "$failure_type" in
      timeout|bad_spec|env_missing|test_flake|review_reject|crash) ;;
      *) echo "Error: --failure-type must be timeout|bad_spec|env_missing|test_flake|review_reject|crash" >&2; exit 1 ;;
    esac
  fi

  # Check for duplicate knowledge (simple LIKE match on fact substring)
  local e_fact
  e_fact="$(sql_escape "$fact")"
  local dup_count
  dup_count=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM knowledge WHERE fact LIKE '%${e_fact}%';")
  if [[ "$dup_count" -gt 0 ]]; then
    echo "Skipped: duplicate knowledge already exists matching this fact."
    return 0
  fi

  # Generate knowledge ID
  local id
  id=$(sqlite3 "$DB_FILE" "SELECT printf('k_%03d', COALESCE(MAX(CAST(SUBSTR(id,3) AS INTEGER)),0)+1) FROM knowledge;")

  # Convert CSV to JSON arrays
  local tags_json files_json
  tags_json=$(csv_to_json_array "$tags")
  files_json=$(csv_to_json_array "$files")

  # Calculate expires_at (90 days)
  local expires_at
  expires_at=$(calc_expires_at 90)

  local now
  now=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  # Escape all user input
  local e_id e_type e_rec e_confidence e_tags e_files e_task_id e_outcome e_expires_at e_now
  e_id="$(sql_escape "$id")"
  e_type="$(sql_escape "$type")"
  e_rec="$(sql_escape "$rec")"
  e_confidence="$(sql_escape "$confidence")"
  e_tags="$(sql_escape "$tags_json")"
  e_files="$(sql_escape "$files_json")"
  e_task_id="$(sql_escape "$task_id")"
  e_outcome="$(sql_escape "$outcome")"
  e_expires_at="$(sql_escape "$expires_at")"
  e_now="$(sql_escape "$now")"

  # INSERT into knowledge
  sqlite3 "$DB_FILE" "INSERT INTO knowledge (id, type, fact, recommendation, confidence, source, tags, files, source_task_id, outcome, expires_at, created_at) VALUES ('${e_id}', '${e_type}', '${e_fact}', '${e_rec}', '${e_confidence}', 'claude', '${e_tags}', '${e_files}', '${e_task_id}', '${e_outcome}', '${e_expires_at}', '${e_now}');"

  # INSERT event
  local event_payload
  event_payload="{\"knowledge_id\":\"${id}\",\"type\":\"${type}\",\"task_id\":\"${task_id}\",\"outcome\":\"${outcome}\"}"
  sqlite3 "$DB_FILE" "INSERT INTO events (timestamp, event_type, task_id, agent, payload) VALUES ('${e_now}', 'knowledge_extracted', '${e_task_id}', 'claude', '$(sql_escape "$event_payload")');"

  # If --failure-type provided, update dispatches
  if [[ -n "$failure_type" ]]; then
    local e_failure_type
    e_failure_type="$(sql_escape "$failure_type")"
    sqlite3 "$DB_FILE" "UPDATE dispatches SET failure_type = '${e_failure_type}' WHERE task_id = '${e_task_id}' AND failure_type IS NULL;"
  fi

  echo "Extracted ${id}: [${type}] ${fact}"
}

cmd_adapt() {
  local session_date=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --session-date) session_date="$2"; shift 2 ;;
      *) echo "Unknown option: $1" >&2; usage ;;
    esac
  done

  if [[ -z "$session_date" ]]; then
    session_date="$(today_date)"
  fi

  local e_date
  e_date="$(sql_escape "$session_date")"

  local adaptations=()

  # Query failure counts from dispatches for that date
  local bad_spec timeout_count crash_count env_missing review_reject
  bad_spec=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM dispatches WHERE DATE(timestamp) = '${e_date}' AND failure_type = 'bad_spec';")
  timeout_count=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM dispatches WHERE DATE(timestamp) = '${e_date}' AND failure_type = 'timeout';")
  crash_count=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM dispatches WHERE DATE(timestamp) = '${e_date}' AND failure_type = 'crash';")
  env_missing=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM dispatches WHERE DATE(timestamp) = '${e_date}' AND failure_type = 'env_missing';")
  review_reject=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM dispatches WHERE DATE(timestamp) = '${e_date}' AND failure_type = 'review_reject';")

  # Apply adaptation rules
  if [[ "$bad_spec" -gt 2 ]]; then
    adaptations+=("bad_spec ($bad_spec): Enforce acceptance criteria template before next dispatch")
  fi
  if [[ "$timeout_count" -gt 1 ]]; then
    adaptations+=("timeout ($timeout_count): Consider splitting tasks smaller or reducing context payload")
  fi
  if [[ "$crash_count" -gt 1 ]]; then
    adaptations+=("crash ($crash_count): Force reviewer mode + human checkpoint on next similar task")
  fi
  if [[ "$env_missing" -gt 0 ]]; then
    adaptations+=("env_missing ($env_missing): Add missing tool to conventions.md")
  fi
  if [[ "$review_reject" -gt 2 ]]; then
    adaptations+=("review_reject ($review_reject): Switch assignee or add pre-review checklist")
  fi

  # Check for tasks with retry_count >= 3 that aren't done
  local stuck_tasks
  stuck_tasks=$(sqlite3 "$DB_FILE" "SELECT id || ' (' || status || ', retries: ' || retry_count || ')' FROM tasks WHERE retry_count >= 3 AND status != 'done';")
  if [[ -n "$stuck_tasks" ]]; then
    adaptations+=("Stuck tasks (retry >= 3, not done):")
    while IFS= read -r line; do
      adaptations+=("  $line")
    done <<< "$stuck_tasks"
  fi

  echo "=== Adaptation Check (${session_date}) ==="
  echo ""

  if [[ ${#adaptations[@]} -eq 0 ]]; then
    echo "No adaptations needed."
  else
    for adaptation in "${adaptations[@]}"; do
      echo "  * ${adaptation}"
    done
  fi
}

cmd_retro() {
  local session_date=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --session-date) session_date="$2"; shift 2 ;;
      *) echo "Unknown option: $1" >&2; usage ;;
    esac
  done

  if [[ -z "$session_date" ]]; then
    session_date="$(today_date)"
  fi

  local e_date
  e_date="$(sql_escape "$session_date")"

  echo "=== Session Retrospective (${session_date}) ==="
  echo ""

  # Tasks completed
  local tasks_completed
  tasks_completed=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM tasks WHERE DATE(completed_at) = '${e_date}';")
  echo "Tasks completed:    ${tasks_completed}"

  # Tasks created
  local tasks_created
  tasks_created=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM tasks WHERE DATE(created_at) = '${e_date}';")
  echo "Tasks created:      ${tasks_created}"

  echo ""

  # Dispatches count and total duration
  local dispatch_count total_duration
  dispatch_count=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM dispatches WHERE DATE(timestamp) = '${e_date}';")
  total_duration=$(sqlite3 "$DB_FILE" "SELECT COALESCE(SUM(duration_seconds),0) FROM dispatches WHERE DATE(timestamp) = '${e_date}';")
  echo "Dispatches:         ${dispatch_count} (total duration: ${total_duration}s)"

  # Failure breakdown
  local failures
  failures=$(sqlite3 "$DB_FILE" "SELECT failure_type, COUNT(*) FROM dispatches WHERE DATE(timestamp) = '${e_date}' AND failure_type IS NOT NULL GROUP BY failure_type ORDER BY COUNT(*) DESC;")
  if [[ -n "$failures" ]]; then
    echo ""
    echo "Failure breakdown:"
    while IFS='|' read -r ftype fcount; do
      printf "  %-20s %s\n" "$ftype" "$fcount"
    done <<< "$failures"
  fi

  echo ""

  # Knowledge entries added this session
  local knowledge_added
  knowledge_added=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM knowledge WHERE DATE(created_at) = '${e_date}';")
  echo "Knowledge added:    ${knowledge_added}"

  # Knowledge expiring within 7 days
  local knowledge_expiring
  if [[ "$(uname)" == "Darwin" ]]; then
    local exp_date
    exp_date=$(date -u -v+7d +"%Y-%m-%dT%H:%M:%SZ")
    knowledge_expiring=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM knowledge WHERE expires_at IS NOT NULL AND expires_at <= '${exp_date}' AND expires_at > datetime('now');")
  else
    knowledge_expiring=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM knowledge WHERE expires_at IS NOT NULL AND expires_at <= datetime('now', '+7 days') AND expires_at > datetime('now');")
  fi
  echo "Knowledge expiring: ${knowledge_expiring} (within 7 days)"

  echo ""

  # Routing effectiveness: per mode, success/total and percentage
  echo "Routing effectiveness:"
  local modes
  modes=$(sqlite3 "$DB_FILE" "SELECT DISTINCT mode FROM dispatches WHERE DATE(timestamp) = '${e_date}';")
  if [[ -n "$modes" ]]; then
    while IFS= read -r mode; do
      local mode_total mode_success pct
      mode_total=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM dispatches WHERE DATE(timestamp) = '${e_date}' AND mode = '${mode}';")
      mode_success=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM dispatches WHERE DATE(timestamp) = '${e_date}' AND mode = '${mode}' AND exit_code = 0;")
      if [[ "$mode_total" -gt 0 ]]; then
        pct=$(( mode_success * 100 / mode_total ))
      else
        pct=0
      fi
      printf "  %-20s %d/%d (%d%%)\n" "$mode" "$mode_success" "$mode_total" "$pct"
    done <<< "$modes"
  else
    echo "  (no dispatches)"
  fi

  echo ""

  # Events logged this session
  local events_count
  events_count=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM events WHERE DATE(timestamp) = '${e_date}';")
  echo "Events logged:      ${events_count}"
}

# ── Main ──────────────────────────────────────────────────────

require_sqlite3
require_db

if [[ $# -lt 1 ]]; then
  usage
fi

COMMAND="$1"
shift

case "$COMMAND" in
  extract) cmd_extract "$@" ;;
  adapt)   cmd_adapt "$@" ;;
  retro)   cmd_retro "$@" ;;
  *)       echo "Unknown command: $COMMAND" >&2; usage ;;
esac
