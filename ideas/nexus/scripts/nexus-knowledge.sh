#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────
# nexus-knowledge.sh — Knowledge Base Management Script
# Manages the SQLite knowledge base: add entries, search,
# generate prompt-ready output, view statistics, and expire.
# ─────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NEXUS_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
DB_FILE="${NEXUS_ROOT}/nexus.db"

# ── Helpers ───────────────────────────────────────────────────

usage() {
  cat <<'EOF'
Usage: nexus-knowledge.sh <command> [options]

Commands:
  add      Add a knowledge entry
  search   Search entries by tags and/or type
  prime    Output entries formatted for prompt injection
  stats    Show knowledge base statistics
  expire   Delete entries past their expires_at

Add options:
  --type <gotcha|pattern|decision|anti-pattern>  (required)
  --fact "Description"                            (required)
  --rec  "Recommendation"                         (optional, default: "")
  --confidence <high|medium|low>                  (optional, default: medium)
  --source <claude|codex|human>                   (optional, default: claude)
  --tags "tag1,tag2"                              (optional, default: [])
  --files "file1,file2"                           (optional, default: [])
  --source-task <task_id>                         (optional)
  --outcome <success|failed|retry>                (optional)
  --expires <days>                                (optional, default: 90)

Search options:
  --tags "tag1,tag2"   Filter by tag (OR match)
  --type <type>        Filter by type

Prime options:
  --tags "tag1,tag2"   Filter by tags (OR match)
  --max <N>            Max entries to output (default: 20)
EOF
  exit 1
}

require_sqlite3() {
  if ! command -v sqlite3 &>/dev/null; then
    echo "Error: sqlite3 is required but not installed." >&2
    exit 1
  fi
}

sql_escape() {
  local val="$1"
  echo "${val//\'/\'\'}"
}

csv_to_json_array() {
  local csv="$1"
  if [ -z "$csv" ]; then
    echo "[]"
    return
  fi
  local result="["
  local first=true
  IFS=',' read -ra items <<< "$csv"
  for item in "${items[@]}"; do
    # Trim whitespace
    item="$(echo "$item" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    if [ "$first" = true ]; then
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

# ── Commands ──────────────────────────────────────────────────

cmd_add() {
  local type="" fact="" rec="" confidence="medium" source="claude"
  local tags="" files="" source_task="" outcome="" expires="90"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --type)        type="$2";        shift 2 ;;
      --fact)        fact="$2";        shift 2 ;;
      --rec)         rec="$2";         shift 2 ;;
      --confidence)  confidence="$2";  shift 2 ;;
      --source)      source="$2";      shift 2 ;;
      --tags)        tags="$2";        shift 2 ;;
      --files)       files="$2";       shift 2 ;;
      --source-task) source_task="$2"; shift 2 ;;
      --outcome)     outcome="$2";     shift 2 ;;
      --expires)     expires="$2";     shift 2 ;;
      *) echo "Unknown option: $1" >&2; usage ;;
    esac
  done

  # Validate required fields
  if [ -z "$type" ]; then
    echo "Error: --type is required" >&2; usage
  fi
  if [ -z "$fact" ]; then
    echo "Error: --fact is required" >&2; usage
  fi

  # Validate enum values
  case "$type" in
    gotcha|pattern|decision|anti-pattern) ;;
    *) echo "Error: --type must be gotcha|pattern|decision|anti-pattern" >&2; exit 1 ;;
  esac
  case "$confidence" in
    high|medium|low) ;;
    *) echo "Error: --confidence must be high|medium|low" >&2; exit 1 ;;
  esac
  case "$source" in
    claude|codex|human) ;;
    *) echo "Error: --source must be claude|codex|human" >&2; exit 1 ;;
  esac
  if [ -n "$outcome" ]; then
    case "$outcome" in
      success|failed|retry) ;;
      *) echo "Error: --outcome must be success|failed|retry" >&2; exit 1 ;;
    esac
  fi

  # Generate ID
  local id
  id=$(sqlite3 "$DB_FILE" "SELECT printf('k_%03d', COALESCE(MAX(CAST(SUBSTR(id,3) AS INTEGER)),0)+1) FROM knowledge;")

  local timestamp
  timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  local tags_json
  tags_json=$(csv_to_json_array "$tags")

  local files_json
  files_json=$(csv_to_json_array "$files")

  local expires_at
  expires_at=$(calc_expires_at "$expires")

  # Escape user input for SQL
  local e_id e_type e_fact e_rec e_confidence e_source e_tags e_files
  local e_source_task e_outcome e_expires_at e_timestamp
  e_id="$(sql_escape "$id")"
  e_type="$(sql_escape "$type")"
  e_fact="$(sql_escape "$fact")"
  e_rec="$(sql_escape "$rec")"
  e_confidence="$(sql_escape "$confidence")"
  e_source="$(sql_escape "$source")"
  e_tags="$(sql_escape "$tags_json")"
  e_files="$(sql_escape "$files_json")"
  e_source_task="$(sql_escape "$source_task")"
  e_outcome="$(sql_escape "$outcome")"
  e_expires_at="$(sql_escape "$expires_at")"
  e_timestamp="$(sql_escape "$timestamp")"

  # Build outcome clause
  local outcome_sql
  if [ -n "$outcome" ]; then
    outcome_sql="'${e_outcome}'"
  else
    outcome_sql="NULL"
  fi

  # Build source_task clause
  local source_task_sql
  if [ -n "$source_task" ]; then
    source_task_sql="'${e_source_task}'"
  else
    source_task_sql="NULL"
  fi

  sqlite3 "$DB_FILE" "INSERT INTO knowledge (id, type, fact, recommendation, confidence, source, tags, files, source_task_id, outcome, expires_at, created_at) VALUES ('${e_id}', '${e_type}', '${e_fact}', '${e_rec}', '${e_confidence}', '${e_source}', '${e_tags}', '${e_files}', ${source_task_sql}, ${outcome_sql}, '${e_expires_at}', '${e_timestamp}');"

  # Log event
  local event_payload
  event_payload="{\"knowledge_id\":\"${id}\",\"type\":\"${type}\",\"fact\":\"$(sql_escape "$fact")\"}"
  sqlite3 "$DB_FILE" "INSERT INTO events (timestamp, event_type, task_id, agent, payload) VALUES ('${e_timestamp}', 'knowledge_added', ${source_task_sql}, '${e_source}', '$(sql_escape "$event_payload")');"

  echo "Added ${id}: [${type}] ${fact}"
}

cmd_search() {
  local tags="" type=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --tags) tags="$2"; shift 2 ;;
      --type) type="$2"; shift 2 ;;
      *) echo "Unknown option: $1" >&2; usage ;;
    esac
  done

  local where="WHERE (expires_at IS NULL OR expires_at > datetime('now'))"

  if [ -n "$type" ]; then
    local e_type
    e_type="$(sql_escape "$type")"
    where="${where} AND type = '${e_type}'"
  fi

  if [ -n "$tags" ]; then
    local tag_conditions=""
    IFS=',' read -ra tag_arr <<< "$tags"
    for tag in "${tag_arr[@]}"; do
      tag="$(echo "$tag" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
      local e_tag
      e_tag="$(sql_escape "$tag")"
      if [ -n "$tag_conditions" ]; then
        tag_conditions="${tag_conditions} OR "
      fi
      tag_conditions="${tag_conditions}EXISTS (SELECT 1 FROM json_each(tags) WHERE json_each.value = '${e_tag}')"
    done
    where="${where} AND (${tag_conditions})"
  fi

  local query="SELECT json_object('id', id, 'type', type, 'fact', fact, 'recommendation', recommendation, 'confidence', confidence, 'source', source, 'tags', json(tags), 'files', json(files), 'source_task_id', source_task_id, 'outcome', outcome, 'expires_at', expires_at, 'created_at', created_at) FROM knowledge ${where} ORDER BY created_at;"

  local results
  results=$(sqlite3 "$DB_FILE" "$query")

  if [ -z "$results" ]; then
    echo "No matching entries found."
    return
  fi

  echo "$results"
}

cmd_prime() {
  local tags="" max=20

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --tags) tags="$2"; shift 2 ;;
      --max)  max="$2";  shift 2 ;;
      *) echo "Unknown option: $1" >&2; usage ;;
    esac
  done

  local where="WHERE (expires_at IS NULL OR expires_at > datetime('now'))"

  if [ -n "$tags" ]; then
    local tag_conditions=""
    IFS=',' read -ra tag_arr <<< "$tags"
    for tag in "${tag_arr[@]}"; do
      tag="$(echo "$tag" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
      local e_tag
      e_tag="$(sql_escape "$tag")"
      if [ -n "$tag_conditions" ]; then
        tag_conditions="${tag_conditions} OR "
      fi
      tag_conditions="${tag_conditions}EXISTS (SELECT 1 FROM json_each(tags) WHERE json_each.value = '${e_tag}')"
    done
    where="${where} AND (${tag_conditions})"
  fi

  local e_max
  e_max="$(sql_escape "$max")"

  local query="SELECT '- [' || type || '] ' || fact || CASE WHEN recommendation != '' THEN ' -> ' || recommendation ELSE '' END FROM knowledge ${where} ORDER BY created_at LIMIT ${e_max};"

  sqlite3 "$DB_FILE" "$query"
}

cmd_stats() {
  local total
  total=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM knowledge WHERE expires_at IS NULL OR expires_at > datetime('now');")

  echo "Total entries: ${total}"
  echo ""

  echo "By type:"
  sqlite3 "$DB_FILE" "SELECT type, COUNT(*) FROM knowledge WHERE expires_at IS NULL OR expires_at > datetime('now') GROUP BY type ORDER BY COUNT(*) DESC;" | while IFS='|' read -r name count; do
    printf "  %-16s %s\n" "$name" "$count"
  done
  echo ""

  echo "By source:"
  sqlite3 "$DB_FILE" "SELECT source, COUNT(*) FROM knowledge WHERE expires_at IS NULL OR expires_at > datetime('now') GROUP BY source ORDER BY COUNT(*) DESC;" | while IFS='|' read -r name count; do
    printf "  %-16s %s\n" "$name" "$count"
  done
  echo ""

  echo "By confidence:"
  sqlite3 "$DB_FILE" "SELECT confidence, COUNT(*) FROM knowledge WHERE expires_at IS NULL OR expires_at > datetime('now') GROUP BY confidence ORDER BY COUNT(*) DESC;" | while IFS='|' read -r name count; do
    printf "  %-16s %s\n" "$name" "$count"
  done
}

cmd_expire() {
  local count
  count=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM knowledge WHERE expires_at IS NOT NULL AND expires_at <= datetime('now');")

  sqlite3 "$DB_FILE" "DELETE FROM knowledge WHERE expires_at IS NOT NULL AND expires_at <= datetime('now');"

  echo "Expired and deleted ${count} entries."
}

# ── Main ──────────────────────────────────────────────────────

require_sqlite3

if [[ $# -lt 1 ]]; then
  usage
fi

COMMAND="$1"
shift

case "$COMMAND" in
  add)    cmd_add "$@" ;;
  search) cmd_search "$@" ;;
  prime)  cmd_prime "$@" ;;
  stats)  cmd_stats "$@" ;;
  expire) cmd_expire ;;
  *)      echo "Unknown command: $COMMAND" >&2; usage ;;
esac
