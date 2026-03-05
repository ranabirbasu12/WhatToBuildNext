# Nexus v0.2 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Upgrade Nexus from JSON/shell-pipe architecture to SQLite backend, self-improvement loop, and MCP-based Codex dispatch.

**Architecture:** SQLite replaces all JSON/JSONL state files. Self-improvement adds mandatory reflect/adapt stages after every task. MCP replaces shell-pipe dispatch to Codex. All existing CLI interfaces stay identical.

**Tech Stack:** bash, sqlite3 (3.51.0, preinstalled on macOS), jq (for migration only), MCP protocol (stdio)

---

### Task 1: Create SQLite Schema and Init Script

**Files:**
- Create: `nexus/scripts/nexus-db.sh`
- Create: `nexus/schema.sql`

**Step 1: Write the schema file**

Create `nexus/schema.sql`:

```sql
-- Nexus v0.2 SQLite Schema

CREATE TABLE IF NOT EXISTS tasks (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  assignee TEXT NOT NULL CHECK(assignee IN ('claude','codex','human')),
  priority INTEGER NOT NULL CHECK(priority BETWEEN 1 AND 5),
  status TEXT NOT NULL DEFAULT 'pending'
    CHECK(status IN ('pending','in_progress','review','done','failed','escalated')),
  mode TEXT NOT NULL CHECK(mode IN ('worker','reviewer','sub-conductor')),
  parent_id TEXT REFERENCES tasks(id),
  reviewed_by TEXT CHECK(reviewed_by IN ('claude','codex')),
  review_status TEXT DEFAULT 'pending'
    CHECK(review_status IN ('pending','approved','changes_requested')),
  retry_count INTEGER DEFAULT 0,
  depends TEXT DEFAULT '[]',
  notes TEXT DEFAULT '[]',
  created_at TEXT NOT NULL,
  completed_at TEXT
);

CREATE TABLE IF NOT EXISTS knowledge (
  id TEXT PRIMARY KEY,
  type TEXT NOT NULL CHECK(type IN ('gotcha','pattern','decision','anti-pattern')),
  fact TEXT NOT NULL,
  recommendation TEXT DEFAULT '',
  confidence TEXT NOT NULL CHECK(confidence IN ('high','medium','low')),
  source TEXT NOT NULL CHECK(source IN ('claude','codex','human')),
  tags TEXT DEFAULT '[]',
  files TEXT DEFAULT '[]',
  source_task_id TEXT,
  outcome TEXT CHECK(outcome IN ('success','failed','retry')),
  expires_at TEXT,
  created_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS events (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  timestamp TEXT NOT NULL,
  event_type TEXT NOT NULL,
  task_id TEXT,
  agent TEXT,
  payload TEXT DEFAULT '{}'
);

CREATE TABLE IF NOT EXISTS dispatches (
  id TEXT PRIMARY KEY,
  timestamp TEXT NOT NULL,
  task_id TEXT NOT NULL,
  mode TEXT NOT NULL,
  model TEXT NOT NULL,
  backend TEXT NOT NULL DEFAULT 'shell',
  prompt_summary TEXT,
  duration_seconds INTEGER,
  exit_code INTEGER,
  failure_type TEXT,
  files_changed TEXT DEFAULT '[]',
  validated INTEGER DEFAULT 0,
  reviewed_by TEXT,
  review_result TEXT
);

CREATE TABLE IF NOT EXISTS usage (
  date TEXT PRIMARY KEY,
  dispatches INTEGER DEFAULT 0,
  duration_seconds INTEGER DEFAULT 0
);
```

**Step 2: Write the db helper script**

Create `nexus/scripts/nexus-db.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NEXUS_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
DB_FILE="${NEXUS_ROOT}/nexus.db"
SCHEMA_FILE="${NEXUS_ROOT}/schema.sql"

usage() {
  cat <<'EOF'
Usage: nexus-db.sh <command>

Commands:
  init      Create database and apply schema
  migrate   Migrate v0.1 JSON/JSONL data into SQLite
  query     Run a raw SQL query (for debugging)
  path      Print the database file path
EOF
  exit 1
}

require_sqlite() {
  if ! command -v sqlite3 &>/dev/null; then
    echo "Error: sqlite3 is required but not installed." >&2
    exit 1
  fi
}

db_path() {
  echo "${DB_FILE}"
}

cmd_init() {
  require_sqlite
  if [[ ! -f "${SCHEMA_FILE}" ]]; then
    echo "Error: schema.sql not found at ${SCHEMA_FILE}" >&2
    exit 1
  fi
  sqlite3 "${DB_FILE}" < "${SCHEMA_FILE}"
  echo "Database initialized at ${DB_FILE}"
}

cmd_migrate() {
  require_sqlite

  if [[ ! -f "${DB_FILE}" ]]; then
    echo "Initializing database first..."
    cmd_init
  fi

  local tasks_json="${NEXUS_ROOT}/board/tasks.json"
  if [[ -f "${tasks_json}" ]]; then
    echo "Migrating tasks..."
    local count=0
    jq -c '.tasks[]' "${tasks_json}" | while IFS= read -r task; do
      local id title desc assignee priority status mode parent reviewed_by review_status retry_count depends notes created_at completed_at
      id="$(echo "${task}" | jq -r '.id')"
      title="$(echo "${task}" | jq -r '.title')"
      desc="$(echo "${task}" | jq -r '.description')"
      assignee="$(echo "${task}" | jq -r '.assignee')"
      priority="$(echo "${task}" | jq -r '.priority')"
      status="$(echo "${task}" | jq -r '.status')"
      mode="$(echo "${task}" | jq -r '.mode')"
      parent="$(echo "${task}" | jq -r '.parent // empty')"
      reviewed_by="$(echo "${task}" | jq -r '.reviewedBy // empty')"
      review_status="$(echo "${task}" | jq -r '.reviewStatus')"
      retry_count="$(echo "${task}" | jq -r '.retryCount')"
      depends="$(echo "${task}" | jq -c '.depends')"
      notes="$(echo "${task}" | jq -c '.notes')"
      created_at="$(echo "${task}" | jq -r '.createdAt')"
      completed_at="$(echo "${task}" | jq -r '.completedAt // empty')"

      sqlite3 "${DB_FILE}" "INSERT OR IGNORE INTO tasks (id, title, description, assignee, priority, status, mode, parent_id, reviewed_by, review_status, retry_count, depends, notes, created_at, completed_at) VALUES ('${id}', '$(echo "${title}" | sed "s/'/''/g")', '$(echo "${desc}" | sed "s/'/''/g")', '${assignee}', ${priority}, '${status}', '${mode}', $(if [[ -n "${parent}" ]]; then echo "'${parent}'"; else echo "NULL"; fi), $(if [[ -n "${reviewed_by}" ]]; then echo "'${reviewed_by}'"; else echo "NULL"; fi), '${review_status}', ${retry_count}, '${depends}', '${notes}', '${created_at}', $(if [[ -n "${completed_at}" ]]; then echo "'${completed_at}'"; else echo "NULL"; fi));"
      count=$((count + 1))
    done
    echo "  Migrated tasks from tasks.json"
  fi

  local kb_file="${NEXUS_ROOT}/context/knowledge.jsonl"
  if [[ -s "${kb_file}" ]]; then
    echo "Migrating knowledge base..."
    while IFS= read -r entry; do
      local id type fact rec confidence source tags files ts
      id="$(echo "${entry}" | jq -r '.id')"
      type="$(echo "${entry}" | jq -r '.type')"
      fact="$(echo "${entry}" | jq -r '.fact')"
      rec="$(echo "${entry}" | jq -r '.recommendation // empty')"
      confidence="$(echo "${entry}" | jq -r '.confidence')"
      source="$(echo "${entry}" | jq -r '.source')"
      tags="$(echo "${entry}" | jq -c '.tags')"
      files="$(echo "${entry}" | jq -c '.files')"
      ts="$(echo "${entry}" | jq -r '.timestamp')"

      sqlite3 "${DB_FILE}" "INSERT OR IGNORE INTO knowledge (id, type, fact, recommendation, confidence, source, tags, files, created_at) VALUES ('${id}', '${type}', '$(echo "${fact}" | sed "s/'/''/g")', '$(echo "${rec}" | sed "s/'/''/g")', '${confidence}', '${source}', '${tags}', '${files}', '${ts}');"
    done < "${kb_file}"
    echo "  Migrated knowledge from knowledge.jsonl"
  fi

  local dispatches_file="${NEXUS_ROOT}/logs/dispatches.jsonl"
  if [[ -s "${dispatches_file}" ]]; then
    echo "Migrating dispatches..."
    while IFS= read -r entry; do
      local id ts task_id mode model prompt_summary duration exit_code files_changed validated
      id="$(echo "${entry}" | jq -r '.id')"
      ts="$(echo "${entry}" | jq -r '.timestamp')"
      task_id="$(echo "${entry}" | jq -r '.taskId')"
      mode="$(echo "${entry}" | jq -r '.mode')"
      model="$(echo "${entry}" | jq -r '.model')"
      prompt_summary="$(echo "${entry}" | jq -r '.prompt_summary')"
      duration="$(echo "${entry}" | jq -r '.duration_seconds')"
      exit_code="$(echo "${entry}" | jq -r '.exit_code')"
      files_changed="$(echo "${entry}" | jq -c '.files_changed')"
      validated="$(echo "${entry}" | jq -r 'if .validated then 1 else 0 end')"

      sqlite3 "${DB_FILE}" "INSERT OR IGNORE INTO dispatches (id, timestamp, task_id, mode, model, backend, prompt_summary, duration_seconds, exit_code, files_changed, validated) VALUES ('${id}', '${ts}', '${task_id}', '${mode}', '${model}', 'shell', '$(echo "${prompt_summary}" | sed "s/'/''/g")', ${duration}, ${exit_code}, '${files_changed}', ${validated});"
    done < "${dispatches_file}"
    echo "  Migrated dispatches from dispatches.jsonl"
  fi

  local usage_file="${NEXUS_ROOT}/logs/usage.json"
  if [[ -f "${usage_file}" ]]; then
    echo "Migrating usage..."
    jq -c '.session_history[]' "${usage_file}" | while IFS= read -r session; do
      local date dispatches duration
      date="$(echo "${session}" | jq -r '.date')"
      dispatches="$(echo "${session}" | jq -r '.dispatches')"
      duration="$(echo "${session}" | jq -r '.duration_seconds')"
      sqlite3 "${DB_FILE}" "INSERT OR IGNORE INTO usage (date, dispatches, duration_seconds) VALUES ('${date}', ${dispatches}, ${duration});"
    done
    echo "  Migrated usage from usage.json"
  fi

  echo "Migration complete."
}

cmd_query() {
  require_sqlite
  if [[ $# -lt 1 ]]; then
    echo "Error: provide a SQL query string" >&2
    exit 1
  fi
  sqlite3 -header -column "${DB_FILE}" "$1"
}

# Main
if [[ $# -lt 1 ]]; then
  usage
fi

command="$1"
shift

case "$command" in
  init)    cmd_init ;;
  migrate) cmd_migrate ;;
  query)   cmd_query "$@" ;;
  path)    db_path ;;
  *)       echo "Unknown command: $command" >&2; usage ;;
esac
```

**Step 3: Run init and verify**

Run: `chmod +x nexus/scripts/nexus-db.sh && ./nexus/scripts/nexus-db.sh init`
Expected: "Database initialized at .../nexus/nexus.db"

Run: `sqlite3 nexus/nexus.db ".tables"`
Expected: `dispatches  events      knowledge   tasks       usage`

**Step 4: Commit**

```bash
git add nexus/schema.sql nexus/scripts/nexus-db.sh
git commit -m "feat(nexus): add SQLite schema and db helper script"
```

---

### Task 2: Migrate Existing Data and Test Migration

**Files:**
- Modify: `nexus/scripts/nexus-db.sh` (already has migrate command)
- Modify: `.gitignore` (add nexus.db)

**Step 1: Add nexus.db to .gitignore**

Append `nexus/*.db` to `.gitignore` so the database isn't committed.

**Step 2: Run migration**

Run: `./nexus/scripts/nexus-db.sh migrate`
Expected: Messages about migrating tasks, knowledge, dispatches, usage.

**Step 3: Verify data**

Run: `sqlite3 nexus/nexus.db "SELECT id, title, status FROM tasks;"`
Expected: 5 rows (T001-T005), all status "done"

Run: `sqlite3 nexus/nexus.db "SELECT id, type, fact FROM knowledge;"`
Expected: 6 rows (k_001 through k_006)

Run: `sqlite3 nexus/nexus.db "SELECT id, task_id, mode FROM dispatches;"`
Expected: 3-4 rows of dispatch records

Run: `sqlite3 nexus/nexus.db "SELECT * FROM usage;"`
Expected: 1 row for 2026-03-05

**Step 4: Commit**

```bash
git add .gitignore
git commit -m "feat(nexus): migrate v0.1 data to SQLite"
```

---

### Task 3: Rewrite nexus-board.sh to Use SQLite

**Files:**
- Modify: `nexus/scripts/nexus-board.sh`

**Step 1: Write the failing test**

Add to `nexus/tests/test-nexus.sh` a new test function `test_board_sqlite_flow` that:
- Creates a temp nexus root with `nexus.db` (init from schema.sql)
- Runs the same add/list/update/show/summary operations as `test_board_flow`
- Verifies results via `sqlite3` queries instead of `jq` on JSON

**Step 2: Run test to verify it fails**

Run: `./nexus/tests/test-nexus.sh`
Expected: New test fails because board.sh still uses JSON

**Step 3: Rewrite nexus-board.sh**

Replace all `jq` operations on `tasks.json` with `sqlite3` queries on `nexus.db`. Key changes:

- `DB_FILE` replaces `BOARD_FILE`: `DB_FILE="$(cd "$SCRIPT_DIR/.." && pwd)/nexus.db"`
- Remove `jq` requirement check, add `sqlite3` check
- `cmd_add`: `INSERT INTO tasks` instead of `jq .tasks +=`
- ID generation: `SELECT printf('T%03d', COALESCE(MAX(CAST(SUBSTR(id,2) AS INTEGER)),0)+1) FROM tasks;`
- `cmd_update`: `UPDATE tasks SET ... WHERE id = ?` instead of jq filter building
- `cmd_list`: `SELECT id, status, assignee, title FROM tasks WHERE ...`
- `cmd_show`: `SELECT * FROM tasks WHERE id = ?` formatted as JSON with `sqlite3 -json`
- `cmd_summary`: `SELECT status, COUNT(*) FROM tasks GROUP BY status`
- Log events to `events` table on add/update

The CLI interface (arguments, output format) stays identical so existing skills and tests work.

**Step 4: Run tests**

Run: `./nexus/tests/test-nexus.sh`
Expected: Both old and new board tests pass

**Step 5: Commit**

```bash
git add nexus/scripts/nexus-board.sh nexus/tests/test-nexus.sh
git commit -m "feat(nexus): rewrite board script to use SQLite backend"
```

---

### Task 4: Rewrite nexus-knowledge.sh to Use SQLite

**Files:**
- Modify: `nexus/scripts/nexus-knowledge.sh`

**Step 1: Write the failing test**

Add `test_knowledge_sqlite_flow` to test suite. Same operations as `test_knowledge_flow` but verifying via `sqlite3` queries.

**Step 2: Run test to verify it fails**

Run: `./nexus/tests/test-nexus.sh`
Expected: New test fails

**Step 3: Rewrite nexus-knowledge.sh**

Replace all `jq` operations on `knowledge.jsonl` with `sqlite3` queries on `nexus.db`. Key changes:

- `DB_FILE` replaces `KB_FILE`: `DB_FILE="${NEXUS_ROOT}/nexus.db"`
- `cmd_add`: `INSERT INTO knowledge` with auto-generated ID via `SELECT printf('k_%03d', COALESCE(MAX(CAST(SUBSTR(id,3) AS INTEGER)),0)+1) FROM knowledge;`
- Add new fields: `--source-task`, `--outcome`, `--expires` (optional args)
- Default `expires_at` to 90 days from now if not specified
- `cmd_search`: `SELECT * FROM knowledge WHERE type = ? AND ...` with JSON tag matching via `json_each()`
- `cmd_prime`: `SELECT type, fact, recommendation FROM knowledge WHERE ...` formatted as dash-prefixed lines
- `cmd_stats`: `SELECT type, COUNT(*) FROM knowledge GROUP BY type` etc.
- Log events to `events` table on add
- New command: `cmd_expire` — deletes entries past their `expires_at` date

**Step 4: Run tests**

Run: `./nexus/tests/test-nexus.sh`
Expected: All tests pass

**Step 5: Commit**

```bash
git add nexus/scripts/nexus-knowledge.sh nexus/tests/test-nexus.sh
git commit -m "feat(nexus): rewrite knowledge script to use SQLite backend"
```

---

### Task 5: Rewrite nexus-dispatch.sh and nexus-status.sh for SQLite

**Files:**
- Modify: `nexus/scripts/nexus-dispatch.sh`
- Modify: `nexus/scripts/nexus-status.sh`

**Step 1: Update nexus-dispatch.sh**

Replace the logging section (dispatches.jsonl + usage.json writes) with SQLite inserts:

- `INSERT INTO dispatches (...)` instead of appending to `dispatches.jsonl`
- `INSERT OR REPLACE INTO usage (...)` instead of `jq` update on `usage.json`
- `INSERT INTO events (...)` to log the dispatch event
- Add `--backend` field (default "shell") to dispatch log
- Add `failure_type` detection: if exit_code != 0 and duration >= timeout, set "timeout"; if exit_code != 0 and output is empty, set "crash"; otherwise set NULL
- Context injection for knowledge now queries SQLite: `sqlite3 -json "${DB_FILE}" "SELECT * FROM knowledge WHERE expires_at IS NULL OR expires_at > datetime('now')"`

**Step 2: Update nexus-status.sh**

Replace all `jq` reads with `sqlite3` queries:

- Task summary: `SELECT status, COUNT(*) FROM tasks GROUP BY status`
- Usage: `SELECT SUM(dispatches), SUM(duration_seconds) FROM usage`
- Knowledge: `SELECT COUNT(*) FROM knowledge`
- Recent dispatches: `SELECT * FROM dispatches ORDER BY timestamp DESC LIMIT 5`
- New section: failure taxonomy summary `SELECT failure_type, COUNT(*) FROM dispatches WHERE failure_type IS NOT NULL GROUP BY failure_type`

**Step 3: Run existing tests**

Run: `./nexus/tests/test-nexus.sh`
Expected: dispatch dry-run and status tests still pass

**Step 4: Commit**

```bash
git add nexus/scripts/nexus-dispatch.sh nexus/scripts/nexus-status.sh
git commit -m "feat(nexus): migrate dispatch and status scripts to SQLite"
```

---

### Task 6: Build the Self-Improvement Reflect Script

**Files:**
- Create: `nexus/scripts/nexus-reflect.sh`

**Step 1: Write the test**

Add `test_reflect_flow` to test suite:
- Insert a completed task into test SQLite db
- Insert a dispatch record with exit_code=0
- Run `nexus-reflect.sh --task-id T001 --outcome success --fact "Test fact" --rec "Test rec" --type pattern --tags "test"`
- Verify: knowledge entry added to db
- Verify: event logged
- Run with `--outcome failed --failure-type timeout`
- Verify: failure counter incremented

**Step 2: Run test to verify it fails**

Run: `./nexus/tests/test-nexus.sh`
Expected: Fails, script doesn't exist

**Step 3: Write nexus-reflect.sh**

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NEXUS_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
DB_FILE="${NEXUS_ROOT}/nexus.db"

usage() {
  cat <<'EOF'
Usage: nexus-reflect.sh <command> [options]

Commands:
  extract    Add a knowledge entry from task reflection
  adapt      Check failure patterns and suggest adaptations
  retro      Generate session retrospective

Extract options:
  --task-id <id>      Source task ID (required)
  --outcome <val>     success|failed|retry (required)
  --fact "..."        What was learned (required)
  --rec "..."         Recommendation (optional)
  --type <val>        gotcha|pattern|decision|anti-pattern (required)
  --confidence <val>  high|medium|low (default: medium)
  --tags "t1,t2"      Comma-separated tags (optional)
  --files "f1,f2"     Comma-separated files (optional)
  --failure-type <v>  timeout|bad_spec|env_missing|test_flake|review_reject|crash (optional)

Adapt options:
  --session-date <YYYY-MM-DD>  Date to check (default: today)

Retro options:
  --session-date <YYYY-MM-DD>  Date to summarize (default: today)
EOF
  exit 1
}

require_sqlite() {
  if ! command -v sqlite3 &>/dev/null; then
    echo "Error: sqlite3 is required." >&2; exit 1
  fi
  if [[ ! -f "${DB_FILE}" ]]; then
    echo "Error: nexus.db not found. Run nexus-db.sh init first." >&2; exit 1
  fi
}

cmd_extract() {
  local task_id="" outcome="" fact="" rec="" type="" confidence="medium" tags="" files="" failure_type=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --task-id)      task_id="$2"; shift 2 ;;
      --outcome)      outcome="$2"; shift 2 ;;
      --fact)         fact="$2"; shift 2 ;;
      --rec)          rec="$2"; shift 2 ;;
      --type)         type="$2"; shift 2 ;;
      --confidence)   confidence="$2"; shift 2 ;;
      --tags)         tags="$2"; shift 2 ;;
      --files)        files="$2"; shift 2 ;;
      --failure-type) failure_type="$2"; shift 2 ;;
      *) echo "Unknown option: $1" >&2; usage ;;
    esac
  done

  # Validate required
  if [[ -z "${task_id}" || -z "${outcome}" || -z "${fact}" || -z "${type}" ]]; then
    echo "Error: --task-id, --outcome, --fact, --type are required." >&2; usage
  fi

  # Validate enums
  case "${outcome}" in success|failed|retry) ;; *) echo "Error: --outcome must be success|failed|retry" >&2; exit 1 ;; esac
  case "${type}" in gotcha|pattern|decision|anti-pattern) ;; *) echo "Error: --type must be gotcha|pattern|decision|anti-pattern" >&2; exit 1 ;; esac
  case "${confidence}" in high|medium|low) ;; *) echo "Error: --confidence must be high|medium|low" >&2; exit 1 ;; esac

  # Check for duplicate (simple substring match on fact)
  local existing
  existing="$(sqlite3 "${DB_FILE}" "SELECT COUNT(*) FROM knowledge WHERE fact LIKE '%$(echo "${fact}" | sed "s/'/''/g")%';")"
  if [[ "${existing}" -gt 0 ]]; then
    echo "Skipped: similar knowledge entry already exists."
    return 0
  fi

  # Generate ID
  local id
  id="$(sqlite3 "${DB_FILE}" "SELECT printf('k_%03d', COALESCE(MAX(CAST(SUBSTR(id,3) AS INTEGER)),0)+1) FROM knowledge;")"

  # Build tags/files JSON arrays
  local tags_json="[]" files_json="[]"
  if [[ -n "${tags}" ]]; then
    tags_json="$(echo "${tags}" | tr ',' '\n' | sed 's/^ *//;s/ *$//' | while IFS= read -r t; do printf '"%s",' "$t"; done | sed 's/,$//' | sed 's/^/[/;s/$/]/')"
  fi
  if [[ -n "${files}" ]]; then
    files_json="$(echo "${files}" | tr ',' '\n' | sed 's/^ *//;s/ *$//' | while IFS= read -r f; do printf '"%s",' "$f"; done | sed 's/,$//' | sed 's/^/[/;s/$/]/')"
  fi

  local now expires
  now="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  expires="$(date -u -v+90d +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u -d "+90 days" +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || echo "")"

  sqlite3 "${DB_FILE}" "INSERT INTO knowledge (id, type, fact, recommendation, confidence, source, tags, files, source_task_id, outcome, expires_at, created_at) VALUES ('${id}', '${type}', '$(echo "${fact}" | sed "s/'/''/g")', '$(echo "${rec}" | sed "s/'/''/g")', '${confidence}', 'claude', '${tags_json}', '${files_json}', '${task_id}', '${outcome}', $(if [[ -n "${expires}" ]]; then echo "'${expires}'"; else echo "NULL"; fi), '${now}');"

  # Log event
  sqlite3 "${DB_FILE}" "INSERT INTO events (timestamp, event_type, task_id, agent, payload) VALUES ('${now}', 'knowledge_extracted', '${task_id}', 'claude', '{\"knowledge_id\":\"${id}\",\"outcome\":\"${outcome}\"}');"

  # If failure, update dispatch failure_type
  if [[ -n "${failure_type}" ]]; then
    sqlite3 "${DB_FILE}" "UPDATE dispatches SET failure_type = '${failure_type}' WHERE task_id = '${task_id}' AND failure_type IS NULL;"
  fi

  echo "Extracted ${id}: [${type}] ${fact}"
}

cmd_adapt() {
  local session_date
  session_date="$(date +%Y-%m-%d)"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --session-date) session_date="$2"; shift 2 ;;
      *) echo "Unknown option: $1" >&2; usage ;;
    esac
  done

  echo "=== Adaptation Check (${session_date}) ==="

  # Check failure patterns
  local bad_spec_count timeout_count crash_count
  bad_spec_count="$(sqlite3 "${DB_FILE}" "SELECT COUNT(*) FROM dispatches WHERE failure_type='bad_spec' AND DATE(timestamp)='${session_date}';")"
  timeout_count="$(sqlite3 "${DB_FILE}" "SELECT COUNT(*) FROM dispatches WHERE failure_type='timeout' AND DATE(timestamp)='${session_date}';")"
  crash_count="$(sqlite3 "${DB_FILE}" "SELECT COUNT(*) FROM dispatches WHERE failure_type='crash' AND DATE(timestamp)='${session_date}';")"

  local adaptations=0

  if [[ "${bad_spec_count}" -gt 2 ]]; then
    echo "ADAPT: ${bad_spec_count} bad_spec failures -> Enforce acceptance criteria template before next dispatch"
    adaptations=$((adaptations + 1))
  fi

  if [[ "${timeout_count}" -gt 1 ]]; then
    echo "ADAPT: ${timeout_count} timeout failures -> Consider splitting tasks smaller or reducing context payload"
    adaptations=$((adaptations + 1))
  fi

  if [[ "${crash_count}" -gt 1 ]]; then
    echo "ADAPT: ${crash_count} crash failures -> Force reviewer mode + human checkpoint on next similar task"
    adaptations=$((adaptations + 1))
  fi

  # Check retry patterns
  local high_retry_tasks
  high_retry_tasks="$(sqlite3 "${DB_FILE}" "SELECT id, title, retry_count FROM tasks WHERE retry_count >= 3 AND status != 'done';")"
  if [[ -n "${high_retry_tasks}" ]]; then
    echo "ADAPT: Tasks with 3+ retries need human escalation:"
    echo "${high_retry_tasks}" | while IFS='|' read -r tid ttitle tretry; do
      echo "  ${tid} (${tretry} retries): ${ttitle}"
    done
    adaptations=$((adaptations + 1))
  fi

  if [[ "${adaptations}" -eq 0 ]]; then
    echo "No adaptations needed. System performing normally."
  fi
}

cmd_retro() {
  local session_date
  session_date="$(date +%Y-%m-%d)"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --session-date) session_date="$2"; shift 2 ;;
      *) echo "Unknown option: $1" >&2; usage ;;
    esac
  done

  echo "=== Session Retrospective (${session_date}) ==="
  echo ""

  # Tasks completed
  local tasks_done
  tasks_done="$(sqlite3 "${DB_FILE}" "SELECT COUNT(*) FROM tasks WHERE DATE(completed_at)='${session_date}';")"
  echo "Tasks completed: ${tasks_done}"

  # Dispatches
  local dispatch_count dispatch_duration
  dispatch_count="$(sqlite3 "${DB_FILE}" "SELECT COUNT(*) FROM dispatches WHERE DATE(timestamp)='${session_date}';")"
  dispatch_duration="$(sqlite3 "${DB_FILE}" "SELECT COALESCE(SUM(duration_seconds),0) FROM dispatches WHERE DATE(timestamp)='${session_date}';")"
  echo "Dispatches: ${dispatch_count} (${dispatch_duration}s total)"

  # Failure breakdown
  echo ""
  echo "Failure modes:"
  local failures
  failures="$(sqlite3 "${DB_FILE}" "SELECT failure_type, COUNT(*) FROM dispatches WHERE DATE(timestamp)='${session_date}' AND failure_type IS NOT NULL GROUP BY failure_type ORDER BY COUNT(*) DESC;")"
  if [[ -n "${failures}" ]]; then
    echo "${failures}" | while IFS='|' read -r ftype fcount; do
      echo "  ${ftype}: ${fcount}"
    done
  else
    echo "  (none)"
  fi

  # Knowledge added
  echo ""
  local knowledge_added
  knowledge_added="$(sqlite3 "${DB_FILE}" "SELECT COUNT(*) FROM knowledge WHERE DATE(created_at)='${session_date}';")"
  echo "Knowledge entries added: ${knowledge_added}"

  # Knowledge expiring soon (next 7 days)
  local expiring
  expiring="$(sqlite3 "${DB_FILE}" "SELECT COUNT(*) FROM knowledge WHERE expires_at IS NOT NULL AND expires_at <= datetime('now', '+7 days');")"
  if [[ "${expiring}" -gt 0 ]]; then
    echo "Knowledge entries expiring within 7 days: ${expiring}"
  fi

  # Routing effectiveness
  echo ""
  echo "Routing effectiveness:"
  sqlite3 "${DB_FILE}" "SELECT mode, COUNT(*) as total, SUM(CASE WHEN exit_code=0 THEN 1 ELSE 0 END) as success FROM dispatches WHERE DATE(timestamp)='${session_date}' GROUP BY mode;" | while IFS='|' read -r dmode dtotal dsuccess; do
    local rate=0
    if [[ "${dtotal}" -gt 0 ]]; then
      rate=$(( (dsuccess * 100) / dtotal ))
    fi
    echo "  ${dmode}: ${dsuccess}/${dtotal} success (${rate}%)"
  done

  echo ""
  echo "─────────────────────────────────────────"
}

# Main
require_sqlite

if [[ $# -lt 1 ]]; then
  usage
fi

command="$1"
shift

case "$command" in
  extract) cmd_extract "$@" ;;
  adapt)   cmd_adapt "$@" ;;
  retro)   cmd_retro "$@" ;;
  *)       echo "Unknown command: $command" >&2; usage ;;
esac
```

**Step 4: Run test**

Run: `./nexus/tests/test-nexus.sh`
Expected: All tests pass including new reflect test

**Step 5: Commit**

```bash
git add nexus/scripts/nexus-reflect.sh nexus/tests/test-nexus.sh
git commit -m "feat(nexus): add self-improvement reflect script with extract/adapt/retro"
```

---

### Task 7: Register Codex as MCP Server

**Files:**
- Modify: `nexus/config.json`
- Create or modify: `.claude/settings.local.json` (project-level MCP config)

**Step 1: Update nexus config.json**

Add `dispatchBackend` field:

```json
{
  "codex": {
    "dispatchBackend": "mcp",
    "fallbackBackend": "shell",
    "model": "gpt-5.3-codex",
    "defaultMode": "worker",
    "fullAuto": true,
    "multiAgent": true,
    "maxRetries": 3,
    "timeoutSeconds": 300
  }
}
```

**Step 2: Register Codex MCP server**

Add to `.claude/settings.local.json`:

```json
{
  "mcpServers": {
    "codex": {
      "command": "codex",
      "args": ["mcp-server", "-c", "model=\"gpt-5.3-codex\""]
    }
  }
}
```

**Step 3: Verify MCP server starts**

Run: `codex mcp-server -c 'model="gpt-5.3-codex"' &` then kill it.
Expected: Process starts without error

**Step 4: Update nexus-dispatch.sh for MCP awareness**

Add logic at the execution section:
- Read `dispatchBackend` from config.json
- If "mcp", log a note that MCP dispatch is handled by Claude Code's MCP layer (the dispatch script becomes a logging/context wrapper rather than executing codex directly)
- If "shell", use existing `codex exec` path
- Both paths write to the same SQLite tables

**Step 5: Commit**

```bash
git add nexus/config.json .claude/settings.local.json nexus/scripts/nexus-dispatch.sh
git commit -m "feat(nexus): register Codex as MCP server with shell fallback"
```

---

### Task 8: Update Skills for v0.2

**Files:**
- Modify: `nexus/skills/nexus-orchestrate.md`
- Modify: `nexus/skills/nexus-prime.md`
- Modify: `nexus/skills/nexus-review.md`
- Create: `nexus/skills/nexus-reflect.md`

**Step 1: Update nexus-orchestrate.md**

Add to the execution loop:
- After RESOLVE step, add REFLECT step
- Document MCP dispatch as primary method
- Add failure taxonomy reference
- Update routing matrix with adaptation rules

**Step 2: Update nexus-prime.md**

- Change knowledge priming to use `nexus-reflect.sh retro` for session context
- Add knowledge expiry awareness
- Reference SQLite queries for advanced context

**Step 3: Update nexus-review.md**

- Add: after review, reviewer must call `nexus-reflect.sh extract` with findings
- Add: review results feed into failure taxonomy

**Step 4: Create nexus-reflect.md**

New skill teaching when and how to reflect:
- Mandatory after every task completion
- What makes a good reflection (evidence-based, actionable)
- When to run `adapt` (before starting new work)
- When to run `retro` (end of session or on demand)
- How knowledge expiry works

**Step 5: Commit**

```bash
git add nexus/skills/
git commit -m "feat(nexus): update skills for v0.2 reflect loop and MCP dispatch"
```

---

### Task 9: Update Test Suite for v0.2

**Files:**
- Modify: `nexus/tests/test-nexus.sh`

**Step 1: Update test setup**

- `setup_test_env` now creates SQLite db from schema.sql instead of JSON fixtures
- Keep stub codex binary
- Initialize test db with `sqlite3 "${TEST_DB}" < "${SOURCE_SCHEMA}"`

**Step 2: Update all existing tests**

- `test_board_flow`: verify via `sqlite3` queries instead of `jq`
- `test_knowledge_flow`: verify via `sqlite3` queries
- `test_dispatch_dry_run`: still works (dry-run doesn't touch db)
- `test_status_runs`: still works (reads from db now)

**Step 3: Add new tests**

- `test_reflect_extract`: extract knowledge, verify in db
- `test_reflect_adapt`: insert failure records, check adaptation suggestions
- `test_reflect_retro`: insert session data, verify retro output
- `test_db_init`: verify schema creates all tables
- `test_db_migrate`: create JSON fixtures, migrate, verify data

**Step 4: Run full suite**

Run: `./nexus/tests/test-nexus.sh`
Expected: All tests pass (target: 8-10 tests)

**Step 5: Commit**

```bash
git add nexus/tests/test-nexus.sh
git commit -m "test(nexus): update test suite for v0.2 SQLite and reflect"
```

---

### Task 10: Update CLAUDE.md and Project State

**Files:**
- Modify: `CLAUDE.md`
- Modify: `nexus/context/project-state.md`

**Step 1: Update CLAUDE.md**

Add:
- `nexus/scripts/nexus-db.sh` to scripts section
- `nexus/scripts/nexus-reflect.sh` to scripts section
- `nexus/skills/nexus-reflect.md` to skills section
- Quick reference for reflect commands
- Note about MCP dispatch being primary

**Step 2: Update project-state.md**

- Update architecture section for SQLite + MCP
- Add v0.2 components list
- Update known issues (resolved: ID collision, locking, CSV whitespace)
- Add new stats

**Step 3: Commit**

```bash
git add CLAUDE.md nexus/context/project-state.md
git commit -m "docs(nexus): update CLAUDE.md and project state for v0.2"
```

---

### Task 11: End-to-End Validation

**Step 1: Run full test suite**

Run: `./nexus/tests/test-nexus.sh`
Expected: All tests pass

**Step 2: Run status dashboard**

Run: `./nexus/scripts/nexus-status.sh`
Expected: Shows task summary, usage, knowledge, dispatches, failure taxonomy from SQLite

**Step 3: Test reflect workflow manually**

Run:
```bash
./nexus/scripts/nexus-reflect.sh extract \
  --task-id T006 \
  --outcome success \
  --fact "Codex MCP server mode confirmed working for architectural review" \
  --rec "Use MCP dispatch as primary method for v0.2" \
  --type pattern \
  --confidence high \
  --tags "mcp,codex,dispatch"
```
Expected: Knowledge entry added

Run: `./nexus/scripts/nexus-reflect.sh adapt`
Expected: "No adaptations needed" or relevant suggestions

Run: `./nexus/scripts/nexus-reflect.sh retro`
Expected: Session retrospective with stats

**Step 4: Test dry-run dispatch**

Run:
```bash
./nexus/scripts/nexus-dispatch.sh \
  --mode worker \
  --task-id T007 \
  --prompt "Test v0.2 dispatch" \
  --dry-run
```
Expected: Shows enriched prompt with knowledge from SQLite

**Step 5: Commit final state**

```bash
git add -A
git commit -m "feat(nexus): v0.2 complete — SQLite, self-improvement, MCP integration"
```
