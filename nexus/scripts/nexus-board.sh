#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOARD_FILE="$(cd "$SCRIPT_DIR/../board" && pwd)/tasks.json"

if [[ ! -f "$BOARD_FILE" ]]; then
  echo "Error: tasks.json not found at $BOARD_FILE" >&2
  exit 1
fi

if ! command -v jq &>/dev/null; then
  echo "Error: jq is required but not installed." >&2
  exit 1
fi

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
  if [[ "$priority" -lt 1 || "$priority" -gt 5 ]] 2>/dev/null; then
    echo "Error: --priority must be between 1 and 5." >&2
    exit 1
  fi

  # Validate mode
  case "$mode" in
    worker|sub-conductor|reviewer) ;;
    *) echo "Error: --mode must be worker, sub-conductor, or reviewer." >&2; exit 1 ;;
  esac

  # Generate ID based on count of existing tasks
  local count
  count=$(jq '.tasks | length' "$BOARD_FILE")
  local next_num=$((count + 1))
  local id
  id=$(printf "T%03d" "$next_num")

  # Build depends array
  local depends_json="[]"
  if [[ -n "$depends" ]]; then
    depends_json=$(echo "$depends" | jq -R 'split(",")')
  fi

  # Build parent value
  local parent_json="null"
  if [[ -n "$parent" ]]; then
    parent_json=$(printf '"%s"' "$parent")
  fi

  local now
  now=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  # Create the task object and add it
  local tmp
  tmp=$(mktemp)
  jq --arg id "$id" \
     --arg title "$title" \
     --arg desc "$desc" \
     --arg assignee "$assignee" \
     --argjson priority "$priority" \
     --argjson depends "$depends_json" \
     --arg mode "$mode" \
     --argjson parent "$parent_json" \
     --arg now "$now" \
     '.tasks += [{
       id: $id,
       title: $title,
       description: $desc,
       assignee: $assignee,
       priority: $priority,
       status: "pending",
       depends: $depends,
       mode: $mode,
       parent: $parent,
       reviewedBy: null,
       reviewStatus: "pending",
       retryCount: 0,
       notes: [],
       subtasks: [],
       createdAt: $now,
       completedAt: null
     }]' "$BOARD_FILE" > "$tmp" && mv "$tmp" "$BOARD_FILE"

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
  exists=$(jq --arg id "$id" '[.tasks[] | select(.id == $id)] | length' "$BOARD_FILE")
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

  local tmp
  tmp=$(mktemp)
  local now
  now=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  # Build the jq update expression dynamically
  local filter='.tasks = [.tasks[] | if .id == $id then'
  local updates=""

  if [[ -n "$status" ]]; then
    updates="$updates | .status = \$status"
    if [[ "$status" == "done" ]]; then
      updates="$updates | .completedAt = \$now"
    fi
  fi

  if [[ -n "$assignee" ]]; then
    updates="$updates | .assignee = \$assignee_val"
  fi

  if [[ -n "$reviewed_by" ]]; then
    updates="$updates | .reviewedBy = \$reviewed_by_val"
  fi

  if [[ -n "$review_status" ]]; then
    updates="$updates | .reviewStatus = \$review_status_val"
  fi

  if [[ -n "$note" ]]; then
    updates="$updates | .notes += [\$note_val]"
  fi

  if [[ "$retry" == true ]]; then
    updates="$updates | .retryCount += 1"
  fi

  if [[ -z "$updates" ]]; then
    echo "No updates specified."
    return 0
  fi

  # Remove leading " | "
  updates="${updates# | }"
  filter="$filter $updates else . end]"

  jq --arg id "$id" \
     --arg status "${status:-}" \
     --arg now "$now" \
     --arg assignee_val "${assignee:-}" \
     --arg reviewed_by_val "${reviewed_by:-}" \
     --arg review_status_val "${review_status:-}" \
     --arg note_val "${note:-}" \
     "$filter" "$BOARD_FILE" > "$tmp" && mv "$tmp" "$BOARD_FILE"

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

  local filter='.tasks[]'
  if [[ -n "$status_filter" ]]; then
    filter="$filter | select(.status == \$status_f)"
  fi
  if [[ -n "$assignee_filter" ]]; then
    filter="$filter | select(.assignee == \$assignee_f)"
  fi

  jq -r --arg status_f "${status_filter:-}" \
         --arg assignee_f "${assignee_filter:-}" \
         "[$filter] | .[] | \"\(.id) [\(.status)] [\(.assignee)] \(.title)\"" \
         "$BOARD_FILE"
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

  local result
  result=$(jq --arg id "$id" '.tasks[] | select(.id == $id)' "$BOARD_FILE")

  if [[ -z "$result" ]]; then
    echo "Error: Task $id not found." >&2
    exit 1
  fi

  echo "$result" | jq .
}

cmd_summary() {
  echo "=== Nexus Task Board ==="

  local total pending in_progress review done failed escalated
  total=$(jq '.tasks | length' "$BOARD_FILE")
  pending=$(jq '[.tasks[] | select(.status == "pending")] | length' "$BOARD_FILE")
  in_progress=$(jq '[.tasks[] | select(.status == "in_progress")] | length' "$BOARD_FILE")
  review=$(jq '[.tasks[] | select(.status == "review")] | length' "$BOARD_FILE")
  done=$(jq '[.tasks[] | select(.status == "done")] | length' "$BOARD_FILE")
  failed=$(jq '[.tasks[] | select(.status == "failed")] | length' "$BOARD_FILE")
  escalated=$(jq '[.tasks[] | select(.status == "escalated")] | length' "$BOARD_FILE")

  echo "Total: $total | Pending: $pending | In Progress: $in_progress | Review: $review | Done: $done | Failed: $failed | Escalated: $escalated"
  echo ""

  jq -r '.tasks[] | "\(.id) [\(.status | ascii_upcase)] (\(.assignee)) p\(.priority) - \(.title)"' "$BOARD_FILE"
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
