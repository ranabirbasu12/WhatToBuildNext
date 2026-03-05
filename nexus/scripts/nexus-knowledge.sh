#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────
# nexus-knowledge.sh — Knowledge Base Management Script
# Manages the JSONL knowledge base: add entries, search,
# generate prompt-ready output, and view statistics.
# ─────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NEXUS_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
KB_FILE="${NEXUS_ROOT}/context/knowledge.jsonl"

# ── Helpers ───────────────────────────────────────────────────

usage() {
  cat <<'EOF'
Usage: nexus-knowledge.sh <command> [options]

Commands:
  add      Add a knowledge entry
  search   Search entries by tags and/or type
  prime    Output entries formatted for prompt injection
  stats    Show knowledge base statistics

Add options:
  --type <gotcha|pattern|decision|anti-pattern>  (required)
  --fact "Description"                            (required)
  --rec  "Recommendation"                         (optional, default: "")
  --confidence <high|medium|low>                  (optional, default: medium)
  --source <claude|codex|human>                   (optional, default: claude)
  --tags "tag1,tag2"                              (optional, default: [])
  --files "file1,file2"                           (optional, default: [])

Search options:
  --tags "tag1,tag2"   Filter by tag (OR match)
  --type <type>        Filter by type

Prime options:
  --tags "tag1,tag2"   Filter by tags (OR match)
  --max <N>            Max entries to output (default: 20)
EOF
  exit 1
}

require_jq() {
  if ! command -v jq &>/dev/null; then
    echo "Error: jq is required but not installed." >&2
    exit 1
  fi
}

next_id() {
  local count
  if [ ! -s "$KB_FILE" ]; then
    count=0
  else
    count=$(wc -l < "$KB_FILE" | tr -d ' ')
  fi
  printf "k_%03d" $((count + 1))
}

csv_to_json_array() {
  local csv="$1"
  if [ -z "$csv" ]; then
    echo "[]"
  else
    echo "$csv" | tr ',' '\n' | jq -R . | jq -sc .
  fi
}

# ── Commands ──────────────────────────────────────────────────

cmd_add() {
  local type="" fact="" rec="" confidence="medium" source="claude" tags="" files=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --type)       type="$2";       shift 2 ;;
      --fact)       fact="$2";       shift 2 ;;
      --rec)        rec="$2";        shift 2 ;;
      --confidence) confidence="$2"; shift 2 ;;
      --source)     source="$2";     shift 2 ;;
      --tags)       tags="$2";       shift 2 ;;
      --files)      files="$2";      shift 2 ;;
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

  local id
  id=$(next_id)
  local timestamp
  timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  local tags_json
  tags_json=$(csv_to_json_array "$tags")
  local files_json
  files_json=$(csv_to_json_array "$files")

  local entry
  entry=$(jq -nc \
    --arg id "$id" \
    --arg type "$type" \
    --arg fact "$fact" \
    --arg rec "$rec" \
    --arg confidence "$confidence" \
    --arg source "$source" \
    --argjson tags "$tags_json" \
    --argjson files "$files_json" \
    --arg ts "$timestamp" \
    '{
      id: $id,
      type: $type,
      fact: $fact,
      recommendation: $rec,
      confidence: $confidence,
      source: $source,
      tags: $tags,
      files: $files,
      timestamp: $ts
    }')

  echo "$entry" >> "$KB_FILE"
  echo "Added $id: [$type] $fact"
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

  if [ ! -s "$KB_FILE" ]; then
    echo "Knowledge base is empty."
    return
  fi

  local filter="."

  if [ -n "$type" ]; then
    filter="${filter} | select(.type == \$type_filter)"
  fi

  if [ -n "$tags" ]; then
    local tags_json
    tags_json=$(csv_to_json_array "$tags")
    filter="${filter} | select((.tags // []) as \$t | ${tags_json} | any(. as \$s | \$t | index(\$s) != null))"
  fi

  jq --arg type_filter "${type:-}" "$filter" "$KB_FILE"
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

  if [ ! -s "$KB_FILE" ]; then
    exit 0
  fi

  local filter="."

  if [ -n "$tags" ]; then
    local tags_json
    tags_json=$(csv_to_json_array "$tags")
    filter="${filter} | select((.tags // []) as \$t | ${tags_json} | any(. as \$s | \$t | index(\$s) != null))"
  fi

  jq -r "$filter | \"- [\" + .type + \"] \" + .fact + (if .recommendation != \"\" then \" -> \" + .recommendation else \"\" end)" "$KB_FILE" | head -n "$max"
}

cmd_stats() {
  if [ ! -s "$KB_FILE" ]; then
    echo "Knowledge base is empty."
    return
  fi

  local total
  total=$(wc -l < "$KB_FILE" | tr -d ' ')
  echo "Total entries: $total"
  echo ""

  echo "By type:"
  jq -r '.type' "$KB_FILE" | sort | uniq -c | sort -rn | while read -r count name; do
    printf "  %-16s %d\n" "$name" "$count"
  done
  echo ""

  echo "By source:"
  jq -r '.source' "$KB_FILE" | sort | uniq -c | sort -rn | while read -r count name; do
    printf "  %-16s %d\n" "$name" "$count"
  done
  echo ""

  echo "By confidence:"
  jq -r '.confidence' "$KB_FILE" | sort | uniq -c | sort -rn | while read -r count name; do
    printf "  %-16s %d\n" "$name" "$count"
  done
}

# ── Main ──────────────────────────────────────────────────────

require_jq

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
  *)      echo "Unknown command: $COMMAND" >&2; usage ;;
esac
