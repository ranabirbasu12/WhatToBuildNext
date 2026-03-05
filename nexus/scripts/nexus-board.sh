#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DB_FILE="$(cd "$SCRIPT_DIR/.." && pwd)/nexus.db"

if [[ ! -f "$DB_FILE" ]]; then
  echo "Error: nexus.db not found at $DB_FILE" >&2
  exit 1
fi

if ! command -v sqlite3 &>/dev/null; then
  echo "Error: sqlite3 is required but not installed." >&2
  exit 1
fi

# Helper: escape single quotes for SQL
sql_escape() {
  printf '%s' "$1" | sed "s/'/''/g"
}

usage() {
  cat <<'EOF'
Usage: nexus-board.sh <command> [options]

Commands:
  add       Add a new task
  update    Update an existing task
  list      List tasks (with optional filters)
  show      Show full details of a task
  summary   Show board summary

Run nexus-board.sh <command> --help for command-specific help.
EOF
  exit 1
}

cmd_add() {
  local title="" desc="" assignee="claude" priority=1 depends="" mode="worker" parent=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --title)   title="$2"; shift 2 ;;
      --desc)    desc="$2"; shift 2 ;;
      --assignee) assignee="$2"; shift 2 ;;
      --priority) priority="$2"; shift 2 ;;
      --depends) depends="$2"; shift 2 ;;
      --mode)    mode="$2"; shift 2 ;;
      --parent)  parent="$2"; shift 2 ;;
      *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
  done

  if [[ -z "$title" || -z "$desc" ]]; then
    echo "Error: --title and --desc are required." >&2
    exit 1
  fi

  # Validate assignee
  case "$assignee" in
    claude|codex|human) ;;
    *) echo "Error: --assignee must be claude, codex, or human." >&2; exit 1 ;;
  esac

  # Validate priority
  if ! [[ "$priority" =~ ^[0-9]+$ ]] || [[ "$priority" -lt 1 || "$priority" -gt 5 ]]; then
    echo "Error: --priority must be a number between 1 and 5." >&2
    exit 1
  fi

  # Validate mode
  case "$mode" in
    worker|sub-conductor|reviewer) ;;
    *) echo "Error: --mode must be worker, sub-conductor, or reviewer." >&2; exit 1 ;;
  esac

  # Generate next task ID
  local id
  id=$(sqlite3 "$DB_FILE" "SELECT printf('T%03d', COALESCE(MAX(CAST(SUBSTR(id,2) AS INTEGER)),0)+1) FROM tasks;")

  # Build depends JSON array
  local depends_json="[]"
  if [[ -n "$depends" ]]; then
    # Convert CSV to JSON array: "T001,T002" -> '["T001","T002"]'
    depends_json=$(printf '%s' "$depends" | awk -F',' '{
      printf "["
      for (i=1; i<=NF; i++) {
        gsub(/^ +| +$/, "", $i)
        printf "\"%s\"", $i
        if (i < NF) printf ","
      }
      printf "]"
    }')
  fi

  # Handle parent_id (NULL or value)
  local parent_sql="NULL"
  if [[ -n "$parent" ]]; then
    parent_sql="'$(sql_escape "$parent")'"
  fi

  local now
  now=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  # Escape user input
  local title_esc desc_esc
  title_esc=$(sql_escape "$title")
  desc_esc=$(sql_escape "$desc")

  sqlite3 "$DB_FILE" "
    INSERT INTO tasks (id, title, description, assignee, priority, status, mode, parent_id, reviewed_by, review_status, retry_count, depends, notes, created_at, completed_at)
    VALUES ('$id', '$title_esc', '$desc_esc', '$assignee', $priority, 'pending', '$mode', $parent_sql, NULL, 'pending', 0, '$depends_json', '[]', '$now', NULL);
  "

  # Log event
  sqlite3 "$DB_FILE" "
    INSERT INTO events (timestamp, event_type, task_id, agent, payload)
    VALUES ('$now', 'task_created', '$id', 'claude', '{\"title\":\"$title_esc\"}');
  "

  echo "Created task $id: $title"
}

cmd_update() {
  local id="" status="" assignee="" reviewed_by="" review_status="" note="" retry=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --id)             id="$2"; shift 2 ;;
      --status)         status="$2"; shift 2 ;;
      --assignee)       assignee="$2"; shift 2 ;;
      --reviewed-by)    reviewed_by="$2"; shift 2 ;;
      --review-status)  review_status="$2"; shift 2 ;;
      --note)           note="$2"; shift 2 ;;
      --retry)          retry=true; shift ;;
      *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
  done

  if [[ -z "$id" ]]; then
    echo "Error: --id is required." >&2
    exit 1
  fi

  # Verify task exists
  local exists
  exists=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM tasks WHERE id = '$(sql_escape "$id")';")
  if [[ "$exists" -eq 0 ]]; then
    echo "Error: Task $id not found." >&2
    exit 1
  fi

  # Validate status if provided
  if [[ -n "$status" ]]; then
    case "$status" in
      pending|in_progress|review|done|failed|escalated) ;;
      *) echo "Error: Invalid status: $status" >&2; exit 1 ;;
    esac
  fi

  # Validate assignee if provided
  if [[ -n "$assignee" ]]; then
    case "$assignee" in
      claude|codex|human) ;;
      *) echo "Error: --assignee must be claude, codex, or human." >&2; exit 1 ;;
    esac
  fi

  # Validate reviewed-by if provided
  if [[ -n "$reviewed_by" ]]; then
    case "$reviewed_by" in
      claude|codex) ;;
      *) echo "Error: --reviewed-by must be claude or codex." >&2; exit 1 ;;
    esac
  fi

  # Validate review-status if provided
  if [[ -n "$review_status" ]]; then
    case "$review_status" in
      pending|approved|changes_requested) ;;
      *) echo "Error: Invalid review-status: $review_status" >&2; exit 1 ;;
    esac
  fi

  local now
  now=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  local id_esc
  id_esc=$(sql_escape "$id")

  # Build SET clause dynamically
  local set_parts=()

  if [[ -n "$status" ]]; then
    set_parts+=("status = '$status'")
    if [[ "$status" == "done" ]]; then
      set_parts+=("completed_at = '$now'")
    fi
  fi

  if [[ -n "$assignee" ]]; then
    set_parts+=("assignee = '$assignee'")
  fi

  if [[ -n "$reviewed_by" ]]; then
    set_parts+=("reviewed_by = '$(sql_escape "$reviewed_by")'")
  fi

  if [[ -n "$review_status" ]]; then
    set_parts+=("review_status = '$review_status'")
  fi

  if [[ -n "$note" ]]; then
    local note_esc
    note_esc=$(sql_escape "$note")
    set_parts+=("notes = json_insert(notes, '\$[#]', '$note_esc')")
  fi

  if [[ "$retry" == true ]]; then
    set_parts+=("retry_count = retry_count + 1")
  fi

  if [[ ${#set_parts[@]} -eq 0 ]]; then
    echo "No updates specified."
    return 0
  fi

  # Join set_parts with commas
  local set_clause=""
  for i in "${!set_parts[@]}"; do
    if [[ "$i" -eq 0 ]]; then
      set_clause="${set_parts[$i]}"
    else
      set_clause="$set_clause, ${set_parts[$i]}"
    fi
  done

  sqlite3 "$DB_FILE" "UPDATE tasks SET $set_clause WHERE id = '$id_esc';"

  # Log event
  local payload="{\"updates\":\"$set_clause\"}"
  local payload_esc
  payload_esc=$(sql_escape "$payload")
  sqlite3 "$DB_FILE" "
    INSERT INTO events (timestamp, event_type, task_id, agent, payload)
    VALUES ('$now', 'task_updated', '$id_esc', 'claude', '$payload_esc');
  "

  echo "Updated task $id"
}

cmd_list() {
  local status_filter="" assignee_filter=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --status)   status_filter="$2"; shift 2 ;;
      --assignee) assignee_filter="$2"; shift 2 ;;
      *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
  done

  local where_parts=()

  if [[ -n "$status_filter" ]]; then
    where_parts+=("status = '$(sql_escape "$status_filter")'")
  fi

  if [[ -n "$assignee_filter" ]]; then
    where_parts+=("assignee = '$(sql_escape "$assignee_filter")'")
  fi

  local where_clause=""
  if [[ ${#where_parts[@]} -gt 0 ]]; then
    where_clause="WHERE"
    for i in "${!where_parts[@]}"; do
      if [[ "$i" -eq 0 ]]; then
        where_clause="$where_clause ${where_parts[$i]}"
      else
        where_clause="$where_clause AND ${where_parts[$i]}"
      fi
    done
  fi

  sqlite3 "$DB_FILE" "SELECT id || ' [' || status || '] [' || assignee || '] ' || title FROM tasks $where_clause ORDER BY id;"
}

cmd_show() {
  local id=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --id) id="$2"; shift 2 ;;
      *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
  done

  if [[ -z "$id" ]]; then
    echo "Error: --id is required." >&2
    exit 1
  fi

  local id_esc
  id_esc=$(sql_escape "$id")

  local exists
  exists=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM tasks WHERE id = '$id_esc';")
  if [[ "$exists" -eq 0 ]]; then
    echo "Error: Task $id not found." >&2
    exit 1
  fi

  sqlite3 -json "$DB_FILE" "SELECT id, title, description, assignee, priority, status, mode, parent_id AS parent, reviewed_by AS reviewedBy, review_status AS reviewStatus, retry_count AS retryCount, depends, notes, created_at AS createdAt, completed_at AS completedAt FROM tasks WHERE id = '$id_esc';" | python3 -c "
import sys, json
rows = json.load(sys.stdin)
if rows:
    task = rows[0]
    # Parse JSON string fields
    for key in ('depends', 'notes'):
        if isinstance(task.get(key), str):
            try:
                task[key] = json.loads(task[key])
            except (json.JSONDecodeError, TypeError):
                pass
    # Convert empty string to null for nullable fields
    for key in ('parent', 'reviewedBy', 'completedAt'):
        if task.get(key) == '' or task.get(key) is None:
            task[key] = None
    print(json.dumps(task, indent=2))
"
}

cmd_summary() {
  echo "=== Nexus Task Board ==="

  local total pending in_progress review done_count failed escalated
  total=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM tasks;")
  pending=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM tasks WHERE status = 'pending';")
  in_progress=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM tasks WHERE status = 'in_progress';")
  review=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM tasks WHERE status = 'review';")
  done_count=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM tasks WHERE status = 'done';")
  failed=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM tasks WHERE status = 'failed';")
  escalated=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM tasks WHERE status = 'escalated';")

  echo "Total: $total | Pending: $pending | In Progress: $in_progress | Review: $review | Done: $done_count | Failed: $failed | Escalated: $escalated"
  echo ""

  sqlite3 "$DB_FILE" "SELECT id || ' [' || UPPER(status) || '] (' || assignee || ') p' || priority || ' - ' || title FROM tasks ORDER BY id;"
}

# Main dispatch
if [[ $# -lt 1 ]]; then
  usage
fi

command="$1"
shift

case "$command" in
  add)     cmd_add "$@" ;;
  update)  cmd_update "$@" ;;
  list)    cmd_list "$@" ;;
  show)    cmd_show "$@" ;;
  summary) cmd_summary "$@" ;;
  *)       echo "Unknown command: $command" >&2; usage ;;
esac
