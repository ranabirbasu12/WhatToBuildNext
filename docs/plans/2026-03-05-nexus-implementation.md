# Nexus Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build Nexus — a Claude Code extension that orchestrates Codex CLI as a coordinated sub-agent with shared task board, knowledge base, cross-review, and cost tracking.

**Architecture:** Claude Code skills teach the orchestrator how to dispatch to Codex via `codex exec`, manage a JSON task board, maintain a JSONL knowledge base, and track usage. A shell helper script handles the mechanics of Codex invocation and output capture.

**Tech Stack:** Bash (dispatch scripts), JSON/JSONL (data), Markdown (skills), jq (JSON processing)

---

## Task 1: Project Scaffolding

**Files:**
- Create: `nexus/context/project-state.md`
- Create: `nexus/context/knowledge.jsonl`
- Create: `nexus/context/conventions.md`
- Create: `nexus/board/tasks.json`
- Create: `nexus/logs/dispatches.jsonl`
- Create: `nexus/logs/usage.json`
- Create: `nexus/config.json`

**Step 1: Create directory structure**

Run: `mkdir -p nexus/{context,board,logs,skills,scripts}`

**Step 2: Create initial project-state.md**

```markdown
# Nexus — Project State

## Architecture
Nexus is a multi-agent orchestration system running as Claude Code skills.
Claude Code acts as conductor, dispatching to Codex CLI for execution.

## Services
- Claude Code: Orchestrator, planner, reviewer, MCP-connected workflows
- Codex CLI (gpt-5.3-codex): Worker, sub-conductor, code auditor

## Recent Decisions
- 2026-03-05: Chose Claude Code extension approach over standalone CLI
- 2026-03-05: Code-first scope, extensible architecture

## Known Issues
None yet — initial build.
```

**Step 3: Create empty knowledge base**

Create `nexus/context/knowledge.jsonl` as empty file.

**Step 4: Create conventions.md**

```markdown
# Project Conventions

## Code Style
- Shell scripts: Use bash, set -euo pipefail, quote all variables
- JSON: 2-space indent, camelCase keys
- Skills: Markdown with clear section headers

## Commit Style
- Conventional commits: feat:, fix:, docs:, refactor:
- Co-authored-by line for AI contributions

## Testing
- Every dispatch script must be testable with a dry-run flag
- Validate JSON structures with jq before writing
```

**Step 5: Create initial tasks.json**

```json
{
  "version": 1,
  "tasks": []
}
```

**Step 6: Create initial usage.json**

```json
{
  "total_dispatches": 0,
  "total_duration_seconds": 0,
  "by_mode": {},
  "by_model": {},
  "session_history": []
}
```

**Step 7: Create config.json**

```json
{
  "codex": {
    "model": "gpt-5.3-codex",
    "defaultMode": "worker",
    "fullAuto": true,
    "multiAgent": true,
    "maxRetries": 3,
    "timeoutSeconds": 300
  },
  "routing": {
    "autoDispatchThreshold": "medium",
    "alwaysReview": true,
    "humanEscalationTriggers": [
      "architecture_decision",
      "security_boundary",
      "schema_change",
      "agent_disagreement",
      "three_failures"
    ]
  },
  "tracking": {
    "logDispatches": true,
    "logUsage": true
  }
}
```

**Step 8: Create empty dispatches.jsonl**

Create `nexus/logs/dispatches.jsonl` as empty file.

**Step 9: Commit**

```bash
git add nexus/
git commit -m "feat: scaffold Nexus directory structure and initial config"
```

---

## Task 2: Codex Dispatch Script

The core mechanical piece — a bash script that invokes `codex exec`, captures output, measures time, and logs the dispatch.

**Files:**
- Create: `nexus/scripts/nexus-dispatch.sh`
- Test: manual invocation with `--dry-run`

**Step 1: Write the dispatch script**

```bash
#!/usr/bin/env bash
set -euo pipefail

# nexus-dispatch.sh — Dispatch a task to Codex CLI and capture results
#
# Usage:
#   nexus-dispatch.sh --mode worker --task-id T001 --prompt "implement X" [--dir /path] [--dry-run]
#   nexus-dispatch.sh --mode reviewer --task-id T002 --prompt "review X" [--dir /path]
#   nexus-dispatch.sh --mode sub-conductor --task-id T003 --prompt "build X" [--dir /path]

NEXUS_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG="$NEXUS_ROOT/config.json"
DISPATCHES_LOG="$NEXUS_ROOT/logs/dispatches.jsonl"
USAGE_FILE="$NEXUS_ROOT/logs/usage.json"
CONTEXT_DIR="$NEXUS_ROOT/context"

# Parse arguments
MODE=""
TASK_ID=""
PROMPT=""
WORK_DIR="$(pwd)"
DRY_RUN=false
OUTPUT_FILE=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --mode) MODE="$2"; shift 2 ;;
    --task-id) TASK_ID="$2"; shift 2 ;;
    --prompt) PROMPT="$2"; shift 2 ;;
    --dir) WORK_DIR="$2"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    --output) OUTPUT_FILE="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# Validate required args
if [[ -z "$MODE" || -z "$TASK_ID" || -z "$PROMPT" ]]; then
  echo "Error: --mode, --task-id, and --prompt are required"
  exit 1
fi

# Read config
CODEX_MODEL=$(jq -r '.codex.model' "$CONFIG")
TIMEOUT=$(jq -r '.codex.timeoutSeconds' "$CONFIG")

# Build context-enriched prompt
FULL_PROMPT=""

if [[ -f "$CONTEXT_DIR/project-state.md" ]]; then
  FULL_PROMPT+="[PROJECT CONTEXT]
$(cat "$CONTEXT_DIR/project-state.md")

"
fi

if [[ -f "$CONTEXT_DIR/conventions.md" ]]; then
  FULL_PROMPT+="[CONVENTIONS]
$(cat "$CONTEXT_DIR/conventions.md")

"
fi

# Filter relevant knowledge entries by task tags if knowledge base exists
if [[ -s "$CONTEXT_DIR/knowledge.jsonl" ]]; then
  FULL_PROMPT+="[RELEVANT KNOWLEDGE]
$(cat "$CONTEXT_DIR/knowledge.jsonl")

"
fi

FULL_PROMPT+="[TASK]
$PROMPT

[DELIVERABLES]
Complete the task. Report what files you changed and any issues encountered."

# Build codex command
CODEX_CMD=(codex exec --full-auto -C "$WORK_DIR" -m "$CODEX_MODEL" --ephemeral)

if [[ -n "$OUTPUT_FILE" ]]; then
  CODEX_CMD+=(-o "$OUTPUT_FILE")
else
  OUTPUT_FILE=$(mktemp /tmp/nexus-output-XXXXXX.md)
  CODEX_CMD+=(-o "$OUTPUT_FILE")
fi

# Dry run mode
if [[ "$DRY_RUN" == true ]]; then
  echo "=== DRY RUN ==="
  echo "Mode: $MODE"
  echo "Task: $TASK_ID"
  echo "Model: $CODEX_MODEL"
  echo "Working dir: $WORK_DIR"
  echo "Timeout: ${TIMEOUT}s"
  echo "Command: ${CODEX_CMD[*]}"
  echo ""
  echo "=== PROMPT ==="
  echo "$FULL_PROMPT"
  exit 0
fi

# Execute with timing
echo "Dispatching $TASK_ID to Codex ($MODE mode, model: $CODEX_MODEL)..."
START_TIME=$(date +%s)

EXIT_CODE=0
echo "$FULL_PROMPT" | "${CODEX_CMD[@]}" || EXIT_CODE=$?

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

# Read output
CODEX_OUTPUT=""
if [[ -f "$OUTPUT_FILE" ]]; then
  CODEX_OUTPUT=$(cat "$OUTPUT_FILE")
fi

# Detect changed files via git
CHANGED_FILES=$(cd "$WORK_DIR" && git diff --name-only HEAD 2>/dev/null || echo "[]")
CHANGED_JSON=$(echo "$CHANGED_FILES" | jq -R -s 'split("\n") | map(select(length > 0))')

# Generate dispatch ID
DISPATCH_ID="d_$(date +%s)_${TASK_ID}"

# Log dispatch
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
DISPATCH_ENTRY=$(jq -n \
  --arg id "$DISPATCH_ID" \
  --arg ts "$TIMESTAMP" \
  --arg tid "$TASK_ID" \
  --arg mode "$MODE" \
  --arg model "$CODEX_MODEL" \
  --arg summary "$PROMPT" \
  --argjson duration "$DURATION" \
  --argjson exit_code "$EXIT_CODE" \
  --argjson files "$CHANGED_JSON" \
  '{
    id: $id,
    timestamp: $ts,
    taskId: $tid,
    mode: $mode,
    model: $model,
    prompt_summary: ($summary | if length > 100 then .[:100] + "..." else . end),
    duration_seconds: $duration,
    exit_code: $exit_code,
    files_changed: $files,
    validated: false,
    reviewed_by: null,
    review_result: null
  }')

echo "$DISPATCH_ENTRY" >> "$DISPATCHES_LOG"

# Update usage.json
TEMP_USAGE=$(mktemp)
TODAY=$(date +"%Y-%m-%d")
jq --argjson dur "$DURATION" \
   --arg mode "$MODE" \
   --arg model "$CODEX_MODEL" \
   --arg today "$TODAY" \
   '
   .total_dispatches += 1 |
   .total_duration_seconds += $dur |
   .by_mode[$mode] = ((.by_mode[$mode] // 0) + 1) |
   .by_model[$model] = ((.by_model[$model] // 0) + 1) |
   if (.session_history | length == 0) or (.session_history[-1].date != $today)
   then .session_history += [{"date": $today, "dispatches": 1, "duration": $dur}]
   else .session_history[-1].dispatches += 1 | .session_history[-1].duration += $dur
   end
   ' "$USAGE_FILE" > "$TEMP_USAGE" && mv "$TEMP_USAGE" "$USAGE_FILE"

# Output results
echo ""
echo "=== DISPATCH COMPLETE ==="
echo "Task: $TASK_ID"
echo "Duration: ${DURATION}s"
echo "Exit code: $EXIT_CODE"
echo "Files changed: $CHANGED_FILES"
echo "Dispatch ID: $DISPATCH_ID"
echo ""
echo "=== CODEX OUTPUT ==="
echo "$CODEX_OUTPUT"
```

**Step 2: Make executable and test dry-run**

Run: `chmod +x nexus/scripts/nexus-dispatch.sh`
Run: `./nexus/scripts/nexus-dispatch.sh --mode worker --task-id T000 --prompt "echo hello" --dry-run`

Expected: Prints the full enriched prompt and command without executing.

**Step 3: Test real dispatch with a trivial task**

Run: `./nexus/scripts/nexus-dispatch.sh --mode worker --task-id T000 --prompt "Create a file called nexus-test.txt with the text 'Nexus lives'" --dir /tmp`

Expected: Codex creates the file, dispatch is logged, usage is updated.

**Step 4: Verify logging**

Run: `cat nexus/logs/dispatches.jsonl | jq .`
Run: `cat nexus/logs/usage.json | jq .`

Expected: One dispatch entry, usage counters incremented.

**Step 5: Commit**

```bash
git add nexus/scripts/nexus-dispatch.sh
git commit -m "feat: add Codex dispatch script with context injection and logging"
```

---

## Task 3: Task Board Management Script

A helper script for CRUD operations on the task board.

**Files:**
- Create: `nexus/scripts/nexus-board.sh`

**Step 1: Write the board management script**

```bash
#!/usr/bin/env bash
set -euo pipefail

# nexus-board.sh — Manage the Nexus task board
#
# Usage:
#   nexus-board.sh add --title "Title" --desc "Description" [--assignee claude] [--priority 1] [--depends T001]
#   nexus-board.sh update --id T001 --status in_progress
#   nexus-board.sh list [--status pending] [--assignee codex]
#   nexus-board.sh show --id T001
#   nexus-board.sh summary

NEXUS_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BOARD="$NEXUS_ROOT/board/tasks.json"

ACTION="${1:-}"
shift || true

case "$ACTION" in
  add)
    TITLE="" DESC="" ASSIGNEE="claude" PRIORITY=1 DEPENDS="" MODE="worker" PARENT=""
    while [[ $# -gt 0 ]]; do
      case $1 in
        --title) TITLE="$2"; shift 2 ;;
        --desc) DESC="$2"; shift 2 ;;
        --assignee) ASSIGNEE="$2"; shift 2 ;;
        --priority) PRIORITY="$2"; shift 2 ;;
        --depends) DEPENDS="$2"; shift 2 ;;
        --mode) MODE="$2"; shift 2 ;;
        --parent) PARENT="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
      esac
    done

    if [[ -z "$TITLE" ]]; then
      echo "Error: --title is required"; exit 1
    fi

    # Generate ID
    EXISTING=$(jq '.tasks | length' "$BOARD")
    TASK_ID="T$(printf '%03d' $((EXISTING + 1)))"
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Parse dependencies into array
    DEPS_JSON="[]"
    if [[ -n "$DEPENDS" ]]; then
      DEPS_JSON=$(echo "$DEPENDS" | tr ',' '\n' | jq -R . | jq -s .)
    fi

    TEMP=$(mktemp)
    jq --arg id "$TASK_ID" \
       --arg title "$TITLE" \
       --arg desc "$DESC" \
       --arg assignee "$ASSIGNEE" \
       --arg mode "$MODE" \
       --argjson priority "$PRIORITY" \
       --argjson deps "$DEPS_JSON" \
       --arg parent "$PARENT" \
       --arg ts "$TIMESTAMP" \
       '.tasks += [{
         id: $id,
         title: $title,
         description: $desc,
         status: "pending",
         assignee: $assignee,
         dispatchMode: $mode,
         priority: $priority,
         dependencies: $deps,
         parentTask: (if $parent == "" then null else $parent end),
         subtasks: [],
         reviewedBy: null,
         reviewStatus: "pending",
         retryCount: 0,
         notes: [],
         createdAt: $ts,
         completedAt: null
       }]' "$BOARD" > "$TEMP" && mv "$TEMP" "$BOARD"

    echo "Created task $TASK_ID: $TITLE"
    ;;

  update)
    ID="" STATUS="" ASSIGNEE="" REVIEW_BY="" REVIEW_STATUS="" NOTE=""
    while [[ $# -gt 0 ]]; do
      case $1 in
        --id) ID="$2"; shift 2 ;;
        --status) STATUS="$2"; shift 2 ;;
        --assignee) ASSIGNEE="$2"; shift 2 ;;
        --reviewed-by) REVIEW_BY="$2"; shift 2 ;;
        --review-status) REVIEW_STATUS="$2"; shift 2 ;;
        --note) NOTE="$2"; shift 2 ;;
        --retry) ID="$2"; shift 2;
          TEMP=$(mktemp)
          jq --arg id "$ID" '(.tasks[] | select(.id == $id)).retryCount += 1' "$BOARD" > "$TEMP" && mv "$TEMP" "$BOARD"
          echo "Incremented retry count for $ID"
          exit 0 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
      esac
    done

    if [[ -z "$ID" ]]; then echo "Error: --id is required"; exit 1; fi

    TEMP=$(mktemp)
    FILTER="(.tasks[] | select(.id == \$id))"

    jq_args=(--arg id "$ID")
    jq_expr=""

    if [[ -n "$STATUS" ]]; then
      jq_args+=(--arg status "$STATUS")
      jq_expr+=" | $FILTER.status = \$status"
      if [[ "$STATUS" == "done" ]]; then
        jq_args+=(--arg now "$(date -u +"%Y-%m-%dT%H:%M:%SZ")")
        jq_expr+=" | $FILTER.completedAt = \$now"
      fi
    fi
    if [[ -n "$ASSIGNEE" ]]; then
      jq_args+=(--arg assignee "$ASSIGNEE")
      jq_expr+=" | $FILTER.assignee = \$assignee"
    fi
    if [[ -n "$REVIEW_BY" ]]; then
      jq_args+=(--arg rb "$REVIEW_BY")
      jq_expr+=" | $FILTER.reviewedBy = \$rb"
    fi
    if [[ -n "$REVIEW_STATUS" ]]; then
      jq_args+=(--arg rs "$REVIEW_STATUS")
      jq_expr+=" | $FILTER.reviewStatus = \$rs"
    fi
    if [[ -n "$NOTE" ]]; then
      jq_args+=(--arg note "$NOTE")
      jq_expr+=" | $FILTER.notes += [\$note]"
    fi

    if [[ -z "$jq_expr" ]]; then
      echo "Error: nothing to update"; exit 1
    fi

    jq "${jq_args[@]}" ". ${jq_expr}" "$BOARD" > "$TEMP" && mv "$TEMP" "$BOARD"
    echo "Updated task $ID"
    ;;

  list)
    FILTER_STATUS="" FILTER_ASSIGNEE=""
    while [[ $# -gt 0 ]]; do
      case $1 in
        --status) FILTER_STATUS="$2"; shift 2 ;;
        --assignee) FILTER_ASSIGNEE="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
      esac
    done

    FILTER=".tasks"
    if [[ -n "$FILTER_STATUS" ]]; then
      FILTER+=" | map(select(.status == \"$FILTER_STATUS\"))"
    fi
    if [[ -n "$FILTER_ASSIGNEE" ]]; then
      FILTER+=" | map(select(.assignee == \"$FILTER_ASSIGNEE\"))"
    fi

    jq -r "$FILTER | .[] | \"\(.id) [\(.status)] [\(.assignee)] \(.title)\"" "$BOARD"
    ;;

  show)
    ID=""
    while [[ $# -gt 0 ]]; do
      case $1 in
        --id) ID="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
      esac
    done
    jq --arg id "$ID" '.tasks[] | select(.id == $id)' "$BOARD"
    ;;

  summary)
    echo "=== Nexus Task Board ==="
    TOTAL=$(jq '.tasks | length' "$BOARD")
    PENDING=$(jq '[.tasks[] | select(.status == "pending")] | length' "$BOARD")
    IN_PROGRESS=$(jq '[.tasks[] | select(.status == "in_progress")] | length' "$BOARD")
    REVIEW=$(jq '[.tasks[] | select(.status == "review")] | length' "$BOARD")
    DONE=$(jq '[.tasks[] | select(.status == "done")] | length' "$BOARD")
    FAILED=$(jq '[.tasks[] | select(.status == "failed")] | length' "$BOARD")
    ESCALATED=$(jq '[.tasks[] | select(.status == "escalated")] | length' "$BOARD")
    echo "Total: $TOTAL | Pending: $PENDING | In Progress: $IN_PROGRESS | Review: $REVIEW | Done: $DONE | Failed: $FAILED | Escalated: $ESCALATED"
    echo ""
    jq -r '.tasks[] | "\(.id) [\(.status | ascii_upcase)] (\(.assignee)) p\(.priority) - \(.title)"' "$BOARD"
    ;;

  *)
    echo "Usage: nexus-board.sh {add|update|list|show|summary} [options]"
    exit 1
    ;;
esac
```

**Step 2: Make executable and test**

Run: `chmod +x nexus/scripts/nexus-board.sh`
Run: `./nexus/scripts/nexus-board.sh add --title "Test task" --desc "A test" --assignee codex`
Run: `./nexus/scripts/nexus-board.sh list`
Run: `./nexus/scripts/nexus-board.sh summary`

Expected: Task created, listed, summary shown.

**Step 3: Commit**

```bash
git add nexus/scripts/nexus-board.sh
git commit -m "feat: add task board management script"
```

---

## Task 4: Knowledge Base Helper Script

Script for adding, querying, and priming from the knowledge base.

**Files:**
- Create: `nexus/scripts/nexus-knowledge.sh`

**Step 1: Write the knowledge script**

```bash
#!/usr/bin/env bash
set -euo pipefail

# nexus-knowledge.sh — Manage the Nexus knowledge base
#
# Usage:
#   nexus-knowledge.sh add --type gotcha --fact "Description" --rec "What to do" [--tags "auth,db"] [--files "src/a.ts"]
#   nexus-knowledge.sh search --tags "auth" [--type gotcha]
#   nexus-knowledge.sh prime --tags "auth,jwt" [--max 10]
#   nexus-knowledge.sh list [--type pattern]
#   nexus-knowledge.sh stats

NEXUS_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
KB="$NEXUS_ROOT/context/knowledge.jsonl"

ACTION="${1:-}"
shift || true

case "$ACTION" in
  add)
    TYPE="" FACT="" REC="" CONFIDENCE="medium" SOURCE="claude" TAGS="" FILES=""
    while [[ $# -gt 0 ]]; do
      case $1 in
        --type) TYPE="$2"; shift 2 ;;
        --fact) FACT="$2"; shift 2 ;;
        --rec) REC="$2"; shift 2 ;;
        --confidence) CONFIDENCE="$2"; shift 2 ;;
        --source) SOURCE="$2"; shift 2 ;;
        --tags) TAGS="$2"; shift 2 ;;
        --files) FILES="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
      esac
    done

    if [[ -z "$TYPE" || -z "$FACT" ]]; then
      echo "Error: --type and --fact are required"; exit 1
    fi

    # Count existing entries for ID
    COUNT=0
    if [[ -s "$KB" ]]; then
      COUNT=$(wc -l < "$KB" | tr -d ' ')
    fi
    ID="k_$(printf '%03d' $((COUNT + 1)))"
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    TAGS_JSON=$(echo "$TAGS" | tr ',' '\n' | jq -R 'select(length > 0)' | jq -s .)
    FILES_JSON=$(echo "$FILES" | tr ',' '\n' | jq -R 'select(length > 0)' | jq -s .)

    ENTRY=$(jq -n -c \
      --arg id "$ID" \
      --arg ts "$TIMESTAMP" \
      --arg type "$TYPE" \
      --arg fact "$FACT" \
      --arg rec "$REC" \
      --arg conf "$CONFIDENCE" \
      --arg src "$SOURCE" \
      --argjson tags "$TAGS_JSON" \
      --argjson files "$FILES_JSON" \
      '{id: $id, timestamp: $ts, type: $type, fact: $fact, recommendation: $rec, confidence: $conf, source: $src, tags: $tags, affectedFiles: $files}')

    echo "$ENTRY" >> "$KB"
    echo "Added knowledge entry $ID: $FACT"
    ;;

  search)
    SEARCH_TAGS="" SEARCH_TYPE=""
    while [[ $# -gt 0 ]]; do
      case $1 in
        --tags) SEARCH_TAGS="$2"; shift 2 ;;
        --type) SEARCH_TYPE="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
      esac
    done

    if [[ ! -s "$KB" ]]; then
      echo "Knowledge base is empty."
      exit 0
    fi

    FILTER="."
    if [[ -n "$SEARCH_TYPE" ]]; then
      FILTER+=" | select(.type == \"$SEARCH_TYPE\")"
    fi
    if [[ -n "$SEARCH_TAGS" ]]; then
      IFS=',' read -ra TAG_ARR <<< "$SEARCH_TAGS"
      for tag in "${TAG_ARR[@]}"; do
        FILTER+=" | select(.tags | index(\"$tag\"))"
      done
    fi

    jq "$FILTER" "$KB"
    ;;

  prime)
    # Output formatted knowledge for prompt injection
    PRIME_TAGS="" MAX=20
    while [[ $# -gt 0 ]]; do
      case $1 in
        --tags) PRIME_TAGS="$2"; shift 2 ;;
        --max) MAX="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
      esac
    done

    if [[ ! -s "$KB" ]]; then
      exit 0
    fi

    if [[ -n "$PRIME_TAGS" ]]; then
      IFS=',' read -ra TAG_ARR <<< "$PRIME_TAGS"
      # Build jq filter for tag matching
      JQ_FILTER="select("
      first=true
      for tag in "${TAG_ARR[@]}"; do
        if [[ "$first" == true ]]; then first=false; else JQ_FILTER+=" or "; fi
        JQ_FILTER+="(.tags | index(\"$tag\"))"
      done
      JQ_FILTER+=")"
      jq -r "$JQ_FILTER | \"- [\(.type)] \(.fact) → \(.recommendation)\"" "$KB" | head -n "$MAX"
    else
      jq -r '"- [\(.type)] \(.fact) → \(.recommendation)"' "$KB" | head -n "$MAX"
    fi
    ;;

  stats)
    if [[ ! -s "$KB" ]]; then
      echo "Knowledge base is empty."
      exit 0
    fi
    TOTAL=$(wc -l < "$KB" | tr -d ' ')
    echo "=== Knowledge Base ==="
    echo "Total entries: $TOTAL"
    echo ""
    echo "By type:"
    jq -r '.type' "$KB" | sort | uniq -c | sort -rn
    echo ""
    echo "By source:"
    jq -r '.source' "$KB" | sort | uniq -c | sort -rn
    echo ""
    echo "By confidence:"
    jq -r '.confidence' "$KB" | sort | uniq -c | sort -rn
    ;;

  *)
    echo "Usage: nexus-knowledge.sh {add|search|prime|list|stats} [options]"
    exit 1
    ;;
esac
```

**Step 2: Make executable and test**

Run: `chmod +x nexus/scripts/nexus-knowledge.sh`
Run: `./nexus/scripts/nexus-knowledge.sh add --type gotcha --fact "Codex sandbox blocks network" --rec "Ensure all deps are installed before dispatch" --tags "codex,dispatch"`
Run: `./nexus/scripts/nexus-knowledge.sh prime --tags "codex"`
Run: `./nexus/scripts/nexus-knowledge.sh stats`

**Step 3: Commit**

```bash
git add nexus/scripts/nexus-knowledge.sh
git commit -m "feat: add knowledge base management script"
```

---

## Task 5: Status Dashboard Script

Quick terminal view of board + usage + knowledge stats.

**Files:**
- Create: `nexus/scripts/nexus-status.sh`

**Step 1: Write the status script**

```bash
#!/usr/bin/env bash
set -euo pipefail

NEXUS_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "╔══════════════════════════════════════╗"
echo "║           NEXUS STATUS               ║"
echo "╚══════════════════════════════════════╝"
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
  echo "By mode:"
  jq -r '.by_mode | to_entries[] | "  \(.key): \(.value)"' "$USAGE" 2>/dev/null || echo "  (none)"
fi
echo ""

# Knowledge
echo "=== Knowledge Base ==="
KB="$NEXUS_ROOT/context/knowledge.jsonl"
if [[ -s "$KB" ]]; then
  echo "Entries: $(wc -l < "$KB" | tr -d ' ')"
else
  echo "Entries: 0"
fi
echo ""

echo "=== Recent Dispatches ==="
DISPATCHES_LOG="$NEXUS_ROOT/logs/dispatches.jsonl"
if [[ -s "$DISPATCHES_LOG" ]]; then
  tail -5 "$DISPATCHES_LOG" | jq -r '"  \(.taskId) [\(.mode)] \(.duration_seconds)s exit:\(.exit_code) — \(.prompt_summary)"'
else
  echo "  (none)"
fi
```

**Step 2: Make executable and test**

Run: `chmod +x nexus/scripts/nexus-status.sh`
Run: `./nexus/scripts/nexus-status.sh`

**Step 3: Commit**

```bash
git add nexus/scripts/nexus-status.sh
git commit -m "feat: add Nexus status dashboard script"
```

---

## Task 6: Core Orchestration Skill

The main Claude Code skill that teaches the orchestrator how to think with Nexus.

**Files:**
- Create: `nexus/skills/nexus-orchestrate.md`

**Step 1: Write the orchestration skill**

This is the brain — a markdown skill file that Claude Code loads to understand how to use Nexus. It contains routing logic, dispatch patterns, and the execution loop.

The skill should cover:
- When to use Codex vs handle directly
- How to invoke the dispatch script
- How to read/update the task board
- The PRIME → PLAN → DISPATCH → VALIDATE → REVIEW → RESOLVE loop
- When to escalate to the human
- How to extract learnings into the knowledge base

**Step 2: Test by invoking the skill in Claude Code**

Manually invoke the skill and verify it loads correctly and the instructions are coherent.

**Step 3: Commit**

```bash
git add nexus/skills/nexus-orchestrate.md
git commit -m "feat: add core Nexus orchestration skill"
```

---

## Task 7: Cross-Review Skill

**Files:**
- Create: `nexus/skills/nexus-review.md`

**Step 1: Write the review skill**

Covers:
- How to send Claude's work to Codex for review (`codex exec "review..."`)
- How to review Codex's work (Claude reads the diff and checks architectural coherence)
- Disagreement resolution protocol (present both views to human)
- What to look for in reviews (bugs, security, architecture drift, convention violations)

**Step 2: Commit**

```bash
git add nexus/skills/nexus-review.md
git commit -m "feat: add cross-review skill"
```

---

## Task 8: Context Priming Skill

**Files:**
- Create: `nexus/skills/nexus-prime.md`

**Step 1: Write the priming skill**

Covers:
- How to load and update project-state.md
- How to query the knowledge base for relevant entries before dispatch
- When and how to update conventions.md
- Post-task knowledge extraction pattern

**Step 2: Commit**

```bash
git add nexus/skills/nexus-prime.md
git commit -m "feat: add context priming skill"
```

---

## Task 9: Board Management Skill

**Files:**
- Create: `nexus/skills/nexus-board.md`

**Step 1: Write the board skill**

Covers:
- How to break work into tasks with proper fields
- Task lifecycle: pending → in_progress → review → done
- Dependency management
- When to create subtasks vs keep a task monolithic
- How to show the board to the user

**Step 2: Commit**

```bash
git add nexus/skills/nexus-board.md
git commit -m "feat: add task board management skill"
```

---

## Task 10: Integration Test — End-to-End Workflow

The real test: use Nexus to accomplish a small coding task.

**Step 1: Create a small test project**

Create a simple Node.js project in a temp directory with a basic Express app that needs a feature added.

**Step 2: Run the full Nexus loop manually**

1. Prime context
2. Add tasks to the board
3. Dispatch one task to Codex via the dispatch script
4. Validate the output (run tests)
5. Send for cross-review
6. Log a knowledge entry
7. Check the status dashboard

**Step 3: Document what worked and what needs fixing**

Update project-state.md and knowledge.jsonl with findings.

**Step 4: Commit**

```bash
git add -A
git commit -m "feat: complete Nexus integration test and initial knowledge entries"
```

---

## Task 11: CLAUDE.md Integration

Wire Nexus into this project's Claude Code configuration so it loads automatically.

**Files:**
- Create: `CLAUDE.md`

**Step 1: Write CLAUDE.md**

Reference Nexus skills, document the workflow, point to nexus/config.json.

**Step 2: Commit**

```bash
git add CLAUDE.md
git commit -m "docs: add CLAUDE.md with Nexus integration"
```

---

## Build Order Summary

```
Task 1: Scaffolding (no deps)
Task 2: Dispatch script (depends on Task 1)
Task 3: Board script (depends on Task 1)
Task 4: Knowledge script (depends on Task 1)
Task 5: Status dashboard (depends on Tasks 2, 3, 4)
Task 6: Orchestration skill (depends on Tasks 2, 3, 4)
Task 7: Review skill (depends on Task 2)
Task 8: Priming skill (depends on Task 4)
Task 9: Board skill (depends on Task 3)
Task 10: Integration test (depends on all above)
Task 11: CLAUDE.md (depends on Task 10)
```

Tasks 2, 3, 4 can be built in parallel after Task 1.
Tasks 5, 6, 7, 8, 9 can be partially parallelized after their deps.
