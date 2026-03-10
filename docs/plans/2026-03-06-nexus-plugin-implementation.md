# Nexus Plugin Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Package Nexus as a portable Claude Code plugin with hybrid local/global data, hooks, slash commands, and GitHub distribution.

**Architecture:** Plugin lives in its own repo (`ranabirbasu/nexus-plugin`). Each project gets a `.nexus/` directory with local SQLite DB. Global state lives in `~/.nexus/`. Hooks auto-fire on session start and post-commit. Skills teach Claude how to work with Nexus. Commands provide `/nexus-*` slash interface.

**Tech Stack:** Bash, SQLite3, Claude Code plugin system (skills, commands, hooks, agents)

**Reference:** Design doc at `docs/plans/2026-03-06-nexus-plugin-design.md`

---

### Task 1: Scaffold Plugin Structure + Manifest

**Files:**
- Create: `~/GitHub/nexus-plugin/.claude-plugin/plugin.json`
- Create: `~/GitHub/nexus-plugin/LICENSE`

**Step 1: Create repo directory and plugin manifest**

```bash
mkdir -p ~/GitHub/nexus-plugin/.claude-plugin
```

```json
// ~/GitHub/nexus-plugin/.claude-plugin/plugin.json
{
  "name": "nexus",
  "version": "0.4.0",
  "description": "Multi-agent orchestration — Claude builds, Codex reviews. Per-project task board, knowledge base, and adversarial review dispatch.",
  "author": "ranabirbasu"
}
```

**Step 2: Create LICENSE (MIT)**

Standard MIT license with `ranabirbasu` as copyright holder, year 2026.

**Step 3: Initialize git repo**

```bash
cd ~/GitHub/nexus-plugin
git init
git add .
git commit -m "feat: scaffold plugin with manifest"
```

Expected: Clean commit with `.claude-plugin/plugin.json` and `LICENSE`.

---

### Task 2: Schema + DB Helpers Library

Port the SQLite schema and `nexus-db.sh` to portable `lib/` versions that work with any project's `.nexus/` directory.

**Files:**
- Create: `~/GitHub/nexus-plugin/lib/schema.sql`
- Create: `~/GitHub/nexus-plugin/lib/nexus-db.sh`
- Create: `~/GitHub/nexus-plugin/lib/helpers.sh`
- Create: `~/GitHub/nexus-plugin/tests/test-plugin.sh`

**Step 1: Write the test for DB init**

```bash
# In tests/test-plugin.sh — test that DB init creates all 5 tables in an arbitrary directory
test_db_init() {
  local project_dir="${TMP_ROOT}/test-project"
  mkdir -p "${project_dir}"

  # Source helpers and init DB
  source "${PLUGIN_ROOT}/lib/helpers.sh"
  source "${PLUGIN_ROOT}/lib/nexus-db.sh"

  nexus_db_init "${project_dir}"

  # Verify .nexus/nexus.db exists with all 5 tables
  local tables
  tables="$(sqlite3 "${project_dir}/.nexus/nexus.db" ".tables")"
  assert_contains "${tables}" "dispatches" || return 1
  assert_contains "${tables}" "events" || return 1
  assert_contains "${tables}" "knowledge" || return 1
  assert_contains "${tables}" "tasks" || return 1
  assert_contains "${tables}" "usage" || return 1
}
```

**Step 2: Run test to verify it fails**

```bash
cd ~/GitHub/nexus-plugin && bash tests/test-plugin.sh
```

Expected: FAIL — `nexus-db.sh` doesn't exist yet.

**Step 3: Create `lib/helpers.sh`**

Shared functions used across all lib scripts. Key functions:

```bash
#!/usr/bin/env bash
# helpers.sh — Shared functions for Nexus plugin

# Find the plugin's own root directory (where .claude-plugin/ lives)
nexus_plugin_root() {
  local dir="${BASH_SOURCE[0]}"
  dir="$(cd "$(dirname "${dir}")/.." && pwd)"
  echo "${dir}"
}

# Find .nexus/ directory by walking up from given dir (or pwd)
nexus_find_project_root() {
  local dir="${1:-$(pwd)}"
  while [[ "${dir}" != "/" ]]; do
    if [[ -d "${dir}/.nexus" ]]; then
      echo "${dir}"
      return 0
    fi
    dir="$(dirname "${dir}")"
  done
  return 1
}

# Get local DB path for a project
nexus_local_db() {
  local project_root="${1:-}"
  if [[ -z "${project_root}" ]]; then
    project_root="$(nexus_find_project_root)" || return 1
  fi
  echo "${project_root}/.nexus/nexus.db"
}

# Get global DB path
nexus_global_db() {
  echo "${HOME}/.nexus/global.db"
}

# SQL-escape a string (single quotes)
sql_escape() {
  printf '%s' "$1" | sed "s/'/''/g"
}

# Check required tool exists
require_tool() {
  if ! command -v "$1" &>/dev/null; then
    echo "ERROR: Required tool '$1' not found." >&2
    return 1
  fi
}
```

**Step 4: Create `lib/schema.sql`**

Copy the v0.2 schema exactly from `WhatToBuildNext?/nexus/schema.sql`. Same 5 tables: `tasks`, `knowledge`, `events`, `dispatches`, `usage`. No changes needed — the schema is already portable.

**Step 5: Create `lib/nexus-db.sh`**

```bash
#!/usr/bin/env bash
# nexus-db.sh — Database init, query helpers for Nexus plugin
# All functions take a project_root argument instead of hardcoding paths.

NEXUS_DB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source helpers if not already loaded
if ! type nexus_plugin_root &>/dev/null 2>&1; then
  source "${NEXUS_DB_DIR}/helpers.sh"
fi

# Initialize .nexus/ directory and local DB for a project
nexus_db_init() {
  local project_root="${1:?Usage: nexus_db_init <project_root>}"
  local schema="${NEXUS_DB_DIR}/schema.sql"

  require_tool sqlite3

  mkdir -p "${project_root}/.nexus"
  sqlite3 "${project_root}/.nexus/nexus.db" < "${schema}"
}

# Initialize global ~/.nexus/ directory and DB
nexus_db_init_global() {
  local schema="${NEXUS_DB_DIR}/schema.sql"
  local global_dir="${HOME}/.nexus"

  require_tool sqlite3

  mkdir -p "${global_dir}"

  if [[ ! -f "${global_dir}/global.db" ]]; then
    sqlite3 "${global_dir}/global.db" < "${schema}"
    # Add project column to global knowledge table
    sqlite3 "${global_dir}/global.db" "ALTER TABLE knowledge ADD COLUMN project TEXT;" 2>/dev/null || true
  fi

  if [[ ! -f "${global_dir}/config.json" ]]; then
    cat > "${global_dir}/config.json" <<'JSON'
{
  "codex": {
    "model": "gpt-5.3-codex",
    "defaultMode": "reviewer",
    "timeoutSeconds": 300,
    "dispatchBackend": "shell"
  }
}
JSON
  fi
}

# Run a query against local DB
nexus_db_query() {
  local db_path="${1:?Usage: nexus_db_query <db_path> <sql>}"
  local sql="${2:?}"
  sqlite3 -header -column "${db_path}" "${sql}"
}

# Run a query against local DB (raw output, no headers)
nexus_db_query_raw() {
  local db_path="${1:?}"
  local sql="${2:?}"
  sqlite3 "${db_path}" "${sql}"
}
```

**Step 6: Run tests to verify they pass**

```bash
cd ~/GitHub/nexus-plugin && bash tests/test-plugin.sh
```

Expected: PASS for `test_db_init`.

**Step 7: Commit**

```bash
git add lib/ tests/
git commit -m "feat: add schema, DB helpers, and shared helpers library"
```

---

### Task 3: Global DB + Knowledge Resolution

Add global DB support and the merged knowledge query that resolves local-first, then global.

**Files:**
- Modify: `~/GitHub/nexus-plugin/lib/nexus-db.sh`
- Modify: `~/GitHub/nexus-plugin/tests/test-plugin.sh`

**Step 1: Write the test for global DB init**

```bash
test_global_db_init() {
  # Override HOME so we don't touch real ~/.nexus
  export HOME="${TMP_ROOT}/fakehome"
  mkdir -p "${HOME}"

  source "${PLUGIN_ROOT}/lib/helpers.sh"
  source "${PLUGIN_ROOT}/lib/nexus-db.sh"

  nexus_db_init_global

  [[ -f "${HOME}/.nexus/global.db" ]] || return 1
  [[ -f "${HOME}/.nexus/config.json" ]] || return 1

  # global.db should have the project column on knowledge
  local cols
  cols="$(sqlite3 "${HOME}/.nexus/global.db" "PRAGMA table_info(knowledge);" | grep project)"
  [[ -n "${cols}" ]] || return 1
}
```

**Step 2: Write test for knowledge resolution (local + global merge)**

```bash
test_knowledge_resolution() {
  export HOME="${TMP_ROOT}/fakehome"
  local project_dir="${TMP_ROOT}/test-project-kr"
  mkdir -p "${project_dir}" "${HOME}"

  source "${PLUGIN_ROOT}/lib/helpers.sh"
  source "${PLUGIN_ROOT}/lib/nexus-db.sh"

  nexus_db_init "${project_dir}"
  nexus_db_init_global

  local local_db="${project_dir}/.nexus/nexus.db"
  local global_db="${HOME}/.nexus/global.db"

  # Insert local knowledge
  sqlite3 "${local_db}" "INSERT INTO knowledge (id, type, fact, recommendation, confidence, source, tags, files, created_at) VALUES ('k_local', 'pattern', 'Local fact', 'Local rec', 'high', 'claude', '[]', '[]', datetime('now'));"

  # Insert global knowledge
  sqlite3 "${global_db}" "INSERT INTO knowledge (id, type, fact, recommendation, confidence, source, tags, files, created_at, project) VALUES ('k_global', 'gotcha', 'Global fact', 'Global rec', 'medium', 'claude', '[]', '[]', datetime('now'), 'other-project');"

  # Query merged knowledge
  local result
  result="$(nexus_knowledge_query "${local_db}" "${global_db}")"

  assert_contains "${result}" "Local fact" || return 1
  assert_contains "${result}" "Global fact" || return 1
}
```

**Step 3: Add `nexus_knowledge_query` function to `lib/nexus-db.sh`**

```bash
# Query knowledge from local DB first, then global, merged and deduped
nexus_knowledge_query() {
  local local_db="${1:?Usage: nexus_knowledge_query <local_db> <global_db> [max]}"
  local global_db="${2:?}"
  local max="${3:-20}"

  local query="SELECT id, type, fact, recommendation, confidence, source FROM knowledge WHERE (expires_at IS NULL OR expires_at > datetime('now')) ORDER BY CASE confidence WHEN 'high' THEN 1 WHEN 'medium' THEN 2 WHEN 'low' THEN 3 END, created_at DESC LIMIT ${max};"

  local result=""

  # Local first
  if [[ -f "${local_db}" ]]; then
    result+="$(sqlite3 "${local_db}" "${query}" 2>/dev/null || true)"
  fi

  # Global second
  if [[ -f "${global_db}" ]]; then
    if [[ -n "${result}" ]]; then
      result+=$'\n'
    fi
    result+="$(sqlite3 "${global_db}" "${query}" 2>/dev/null || true)"
  fi

  echo "${result}"
}

# Promote a knowledge entry from local to global
nexus_knowledge_promote() {
  local local_db="${1:?Usage: nexus_knowledge_promote <local_db> <global_db> <knowledge_id> <project_name>}"
  local global_db="${2:?}"
  local kid="${3:?}"
  local project="${4:?}"

  require_tool sqlite3

  # Copy from local to global with project tag
  sqlite3 "${local_db}" "SELECT id, type, fact, recommendation, confidence, source, tags, files, created_at FROM knowledge WHERE id = '${kid}';" | while IFS='|' read -r id type fact rec conf src tags files created; do
    sqlite3 "${global_db}" "INSERT OR IGNORE INTO knowledge (id, type, fact, recommendation, confidence, source, tags, files, created_at, project) VALUES ('$(sql_escape "${id}")', '$(sql_escape "${type}")', '$(sql_escape "${fact}")', '$(sql_escape "${rec}")', '$(sql_escape "${conf}")', '$(sql_escape "${src}")', '$(sql_escape "${tags}")', '$(sql_escape "${files}")', '$(sql_escape "${created}")', '$(sql_escape "${project}")');"
  done
}
```

**Step 4: Run tests**

```bash
cd ~/GitHub/nexus-plugin && bash tests/test-plugin.sh
```

Expected: PASS for both new tests.

**Step 5: Commit**

```bash
git add lib/ tests/
git commit -m "feat: add global DB init and knowledge resolution (local + global merge)"
```

---

### Task 4: Dispatch Library (Portable Codex Dispatch)

Port `nexus-dispatch.sh` to a portable version that finds `.nexus/` dynamically.

**Files:**
- Create: `~/GitHub/nexus-plugin/lib/nexus-dispatch.sh`
- Modify: `~/GitHub/nexus-plugin/tests/test-plugin.sh`

**Step 1: Write the test for dispatch dry-run**

```bash
test_dispatch_dry_run() {
  local project_dir="${TMP_ROOT}/test-project-dispatch"
  mkdir -p "${project_dir}"

  source "${PLUGIN_ROOT}/lib/helpers.sh"
  source "${PLUGIN_ROOT}/lib/nexus-db.sh"

  nexus_db_init "${project_dir}"

  # Add context files
  cat > "${project_dir}/.nexus/project-state.md" <<'MD'
# Test Project
Test project context.
MD
  cat > "${project_dir}/.nexus/conventions.md" <<'MD'
# Conventions
- Test convention
MD

  # Add a knowledge entry
  sqlite3 "${project_dir}/.nexus/nexus.db" "INSERT INTO knowledge (id, type, fact, recommendation, confidence, source, tags, files, created_at) VALUES ('k_test', 'pattern', 'Test knowledge', 'Use this', 'high', 'claude', '[]', '[]', datetime('now'));"

  local out
  out="$("${PLUGIN_ROOT}/lib/nexus-dispatch.sh" --mode reviewer --task-id T999 --prompt "Test dispatch" --project-root "${project_dir}" --dry-run)"

  assert_contains "${out}" "NEXUS DISPATCH" || return 1
  assert_contains "${out}" "[PROJECT CONTEXT]" || return 1
  assert_contains "${out}" "Test project context." || return 1
  assert_contains "${out}" "[CONVENTIONS]" || return 1
  assert_contains "${out}" "[RELEVANT KNOWLEDGE]" || return 1
  assert_contains "${out}" "Test knowledge" || return 1
  assert_contains "${out}" "[TASK]" || return 1
  assert_contains "${out}" "Test dispatch" || return 1
}
```

**Step 2: Run test to verify it fails**

Expected: FAIL — `lib/nexus-dispatch.sh` doesn't exist yet.

**Step 3: Create `lib/nexus-dispatch.sh`**

Port from `WhatToBuildNext?/nexus/scripts/nexus-dispatch.sh` with these changes:
- Add `--project-root` argument (finds `.nexus/` via `nexus_find_project_root` if not specified)
- Read config from `~/.nexus/config.json` instead of `nexus/config.json`
- Read context from `<project-root>/.nexus/project-state.md` and `<project-root>/.nexus/conventions.md`
- Query knowledge from both local and global DBs
- Log to `<project-root>/.nexus/nexus.db`
- Keep all existing features: dry-run, enriched prompt, failure detection, SQLite logging

Key difference from v0.3 dispatch — the `--project-root` flag:

```bash
# Parse --project-root or auto-detect
if [[ -z "${PROJECT_ROOT}" ]]; then
  LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "${LIB_DIR}/helpers.sh"
  PROJECT_ROOT="$(nexus_find_project_root)" || {
    echo "Error: No .nexus/ found. Run /nexus-setup first." >&2
    exit 1
  }
fi

DB_FILE="${PROJECT_ROOT}/.nexus/nexus.db"
GLOBAL_DB="${HOME}/.nexus/global.db"
CONFIG_FILE="${HOME}/.nexus/config.json"
PROJECT_STATE="${PROJECT_ROOT}/.nexus/project-state.md"
CONVENTIONS="${PROJECT_ROOT}/.nexus/conventions.md"
```

**Step 4: Run tests**

Expected: PASS.

**Step 5: Commit**

```bash
git add lib/nexus-dispatch.sh tests/
git commit -m "feat: add portable dispatch library with project-root detection"
```

---

### Task 5: Setup Skill + `/nexus-setup` Command

The core initialization flow that creates `.nexus/` in any project.

**Files:**
- Create: `~/GitHub/nexus-plugin/skills/setup/SKILL.md`
- Create: `~/GitHub/nexus-plugin/commands/nexus-setup.md`
- Modify: `~/GitHub/nexus-plugin/tests/test-plugin.sh`

**Step 1: Write the test for setup**

```bash
test_setup_creates_nexus_dir() {
  local project_dir="${TMP_ROOT}/test-project-setup"
  mkdir -p "${project_dir}"
  export HOME="${TMP_ROOT}/fakehome-setup"
  mkdir -p "${HOME}"

  source "${PLUGIN_ROOT}/lib/helpers.sh"
  source "${PLUGIN_ROOT}/lib/nexus-db.sh"

  nexus_db_init "${project_dir}"
  nexus_db_init_global

  # Verify local structure
  [[ -f "${project_dir}/.nexus/nexus.db" ]] || return 1
  local tables
  tables="$(sqlite3 "${project_dir}/.nexus/nexus.db" ".tables")"
  assert_contains "${tables}" "tasks" || return 1

  # Verify global structure
  [[ -f "${HOME}/.nexus/global.db" ]] || return 1
  [[ -f "${HOME}/.nexus/config.json" ]] || return 1
}
```

**Step 2: Create `skills/setup/SKILL.md`**

```markdown
# Nexus Setup — Project Initialization

## Overview

This skill initializes Nexus for a new project. It creates the `.nexus/` directory, SQLite database, and starter context files. Also ensures `~/.nexus/` global directory exists.

## When to Use

- When entering a project that doesn't have `.nexus/` yet
- When the user runs `/nexus-setup`
- When session-start detects no `.nexus/`

## The Flow

1. Check if `.nexus/` already exists in project root
   - If yes: offer re-init or skip
   - If no: proceed with init

2. Create `.nexus/` directory structure:
   ```
   .nexus/
   ├── nexus.db           # SQLite database
   ├── conventions.md     # Project-specific conventions
   └── project-state.md   # Living architecture doc
   ```

3. Initialize SQLite DB from schema

4. Detect project stack:
   - Check for `package.json` → Node.js
   - Check for `pyproject.toml` / `requirements.txt` → Python
   - Check for `Cargo.toml` → Rust
   - Check for `go.mod` → Go
   - Check for `Gemfile` → Ruby
   - Fallback: "unknown"

5. Create starter `conventions.md`:
   ```markdown
   # Project Conventions

   ## Stack
   - Language: [detected]
   - Framework: [detected]

   ## Code Style
   - [to be filled as patterns emerge]
   ```

6. Create starter `project-state.md`:
   ```markdown
   # Project State

   ## Architecture
   [To be documented as work progresses]

   ## Key Files
   [To be documented]
   ```

7. Create `~/.nexus/global.db` and `~/.nexus/config.json` if missing

8. Add `.nexus/nexus.db` to `.gitignore` (DB is local-only)

9. Suggest committing `.nexus/conventions.md` and `.nexus/project-state.md` (these are version-controlled)

## Migration from v0.3

If `nexus/nexus.db` exists (old layout from WhatToBuildNext?):
1. Offer to import knowledge entries to `.nexus/nexus.db`
2. Offer to promote cross-project patterns to `~/.nexus/global.db`
3. Copy pending tasks to new local DB

## Commands Used

```bash
# Initialize DB
source "${CLAUDE_PLUGIN_ROOT}/lib/helpers.sh"
source "${CLAUDE_PLUGIN_ROOT}/lib/nexus-db.sh"
nexus_db_init "$(pwd)"
nexus_db_init_global
```

## Anti-Patterns

- Don't run setup in a directory that's not a project root (no parent .git)
- Don't overwrite existing `.nexus/nexus.db` without asking
- Don't commit `nexus.db` to git (it's local state)
```

**Step 3: Create `commands/nexus-setup.md`**

```markdown
---
name: nexus-setup
description: Initialize Nexus for the current project — creates .nexus/ directory with task board, knowledge base, and project context
user_invocable: true
---

Initialize Nexus for this project. Use the `setup` skill from the Nexus plugin to:

1. Create `.nexus/` directory with SQLite database
2. Detect the project's tech stack
3. Create starter `conventions.md` and `project-state.md`
4. Ensure `~/.nexus/` global directory exists
5. Add `.nexus/nexus.db` to `.gitignore`

If `.nexus/` already exists, offer to re-initialize or skip.
If `nexus/nexus.db` exists (v0.3 layout), offer migration.
```

**Step 4: Run tests**

Expected: PASS.

**Step 5: Commit**

```bash
git add skills/ commands/ tests/
git commit -m "feat: add setup skill and /nexus-setup command"
```

---

### Task 6: Core Skills (Orchestrate, Review, Reflect)

Port the v0.3 skills to plugin format, updating paths to use `$CLAUDE_PLUGIN_ROOT` and `.nexus/` per-project layout.

**Files:**
- Create: `~/GitHub/nexus-plugin/skills/orchestrate/SKILL.md`
- Create: `~/GitHub/nexus-plugin/skills/review/SKILL.md`
- Create: `~/GitHub/nexus-plugin/skills/reflect/SKILL.md`

**Step 1: Create `skills/orchestrate/SKILL.md`**

Port from `WhatToBuildNext?/nexus/skills/nexus-orchestrate.md` with these changes:
- Replace `nexus/nexus.db` → `.nexus/nexus.db` everywhere
- Replace `./nexus/scripts/nexus-dispatch.sh` → `"${CLAUDE_PLUGIN_ROOT}/lib/nexus-dispatch.sh"`
- Replace `./nexus/scripts/nexus-session-start.sh` → session-start hook (automatic)
- Replace `./nexus/scripts/nexus-reflect.sh retro` → `/nexus-retro` command
- Add knowledge resolution note: query local first, then `~/.nexus/global.db`
- Keep the routing matrix, golden rules, anti-patterns exactly the same

Key SQLite path changes:
```bash
# Before (v0.3)
sqlite3 nexus/nexus.db "SELECT ..."

# After (plugin)
sqlite3 .nexus/nexus.db "SELECT ..."
```

**Step 2: Create `skills/review/SKILL.md`**

Port from `WhatToBuildNext?/nexus/skills/nexus-review.md` with these changes:
- Replace dispatch script path with `"${CLAUDE_PLUGIN_ROOT}/lib/nexus-dispatch.sh"`
- Replace `nexus/logs/output-*` → `.nexus/logs/output-*` (create logs dir in `.nexus/`)
- Replace `nexus/nexus.db` → `.nexus/nexus.db`
- Keep the three review templates exactly the same
- Keep the anti-patterns exactly the same

**Step 3: Create `skills/reflect/SKILL.md`**

Port from `WhatToBuildNext?/nexus/skills/nexus-reflect.md` with these changes:
- Replace `nexus/nexus.db` → `.nexus/nexus.db`
- Replace `conventions.md` path → `.nexus/conventions.md`
- Add promotion flow: local `.nexus/nexus.db` → global `~/.nexus/global.db`
- Add promotion command:
  ```bash
  source "${CLAUDE_PLUGIN_ROOT}/lib/helpers.sh"
  source "${CLAUDE_PLUGIN_ROOT}/lib/nexus-db.sh"
  nexus_knowledge_promote ".nexus/nexus.db" "${HOME}/.nexus/global.db" "k_XXX" "$(basename $(pwd))"
  ```
- Keep the knowledge lifecycle, good/bad entry examples, failure taxonomy exactly the same

**Step 4: Commit**

```bash
git add skills/
git commit -m "feat: add orchestrate, review, and reflect skills"
```

---

### Task 7: Codex Reviewer Agent

**Files:**
- Create: `~/GitHub/nexus-plugin/agents/codex-reviewer.md`

**Step 1: Create agent definition**

```markdown
---
name: codex-reviewer
description: Adversarial code reviewer using Codex CLI — finds bugs, security issues, and missed edge cases that Claude missed
model: gpt-5.3-codex
---

# Codex Adversarial Reviewer

You are an adversarial code reviewer. Your job is to find what Claude missed.

## Review Templates

### Post-Feature Review
Review the recent changes (git diff). Find:
1. Bugs and logic errors
2. Security vulnerabilities (OWASP top 10)
3. Edge cases and error handling gaps
4. Convention violations (check .nexus/conventions.md)
5. What would you do differently?

### Security Audit
Security audit of the specified files/area. Check for:
- Injection (SQL, command, XSS)
- Authentication bypass
- Authorization gaps
- Sensitive data exposure
- Insecure defaults

### Architecture Review
Evaluate the design decisions. Consider:
- What assumptions could break under load?
- What coupling will cause problems later?
- What's missing from the error handling?

## Context

You have access to:
- `.nexus/conventions.md` — project-specific code conventions
- `.nexus/project-state.md` — current architecture
- `.nexus/nexus.db` — knowledge base (query with sqlite3)
- `~/.nexus/global.db` — cross-project patterns

## Output Format

For each finding:
```
[SEVERITY: critical|high|medium|low]
[FILE: path/to/file:line]
[ISSUE] Description of the problem
[FIX] Suggested fix
```
```

**Step 2: Commit**

```bash
git add agents/
git commit -m "feat: add codex-reviewer agent definition"
```

---

### Task 8: Hooks (Session-Start + Post-Commit)

**Files:**
- Create: `~/GitHub/nexus-plugin/hooks/hooks.json`
- Create: `~/GitHub/nexus-plugin/hooks/run-hook.cmd`
- Create: `~/GitHub/nexus-plugin/hooks/session-start`
- Create: `~/GitHub/nexus-plugin/hooks/post-commit`
- Modify: `~/GitHub/nexus-plugin/tests/test-plugin.sh`

**Step 1: Write the test for session-start hook**

```bash
test_session_start_hook() {
  local project_dir="${TMP_ROOT}/test-project-hook"
  mkdir -p "${project_dir}"

  source "${PLUGIN_ROOT}/lib/helpers.sh"
  source "${PLUGIN_ROOT}/lib/nexus-db.sh"
  nexus_db_init "${project_dir}"

  # Add a pending task
  sqlite3 "${project_dir}/.nexus/nexus.db" "INSERT INTO tasks (id, title, description, assignee, priority, status, mode, created_at) VALUES ('T001', 'Test task', 'A test', 'claude', 1, 'pending', 'worker', datetime('now'));"

  # Run session-start hook (set NEXUS_PROJECT_ROOT to simulate)
  local out
  NEXUS_PROJECT_ROOT="${project_dir}" out="$(bash "${PLUGIN_ROOT}/hooks/session-start" 2>&1)"

  assert_contains "${out}" "T001" || return 1
  assert_contains "${out}" "Test task" || return 1
}
```

**Step 2: Write test for post-commit hook**

```bash
test_post_commit_hook() {
  local project_dir="${TMP_ROOT}/test-project-pc"
  mkdir -p "${project_dir}"

  source "${PLUGIN_ROOT}/lib/helpers.sh"
  source "${PLUGIN_ROOT}/lib/nexus-db.sh"
  nexus_db_init "${project_dir}"

  # Initialize git repo for commit info
  cd "${project_dir}"
  git init
  echo "test" > test.txt
  git add test.txt
  git commit -m "test commit"

  # Run post-commit hook
  local out
  NEXUS_PROJECT_ROOT="${project_dir}" out="$(bash "${PLUGIN_ROOT}/hooks/post-commit" 2>&1)"

  assert_contains "${out}" "NEXUS KNOWLEDGE CAPTURE" || return 1
  assert_contains "${out}" "test commit" || return 1
}
```

**Step 3: Create `hooks/hooks.json`**

```json
{
  "hooks": [
    {
      "matcher": "SessionStart",
      "hooks": [
        {
          "type": "command",
          "command": "bash '${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd' session-start",
          "timeout": 5000
        }
      ]
    },
    {
      "matcher": "Bash",
      "hooks": [
        {
          "type": "command",
          "command": "bash '${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd' post-commit",
          "timeout": 5000
        }
      ]
    }
  ]
}
```

**Step 4: Create `hooks/run-hook.cmd`**

```bash
#!/usr/bin/env bash
set -euo pipefail

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK_NAME="${1:?Usage: run-hook.cmd <hook-name>}"

# Find project root (walk up from pwd looking for .nexus/)
find_nexus_root() {
  local dir="$(pwd)"
  while [[ "${dir}" != "/" ]]; do
    if [[ -d "${dir}/.nexus" ]]; then
      echo "${dir}"
      return 0
    fi
    dir="$(dirname "${dir}")"
  done
  return 1
}

export NEXUS_PROJECT_ROOT="$(find_nexus_root 2>/dev/null)" || true
export NEXUS_PLUGIN_ROOT="$(cd "${HOOK_DIR}/.." && pwd)"

if [[ -x "${HOOK_DIR}/${HOOK_NAME}" ]]; then
  exec bash "${HOOK_DIR}/${HOOK_NAME}"
fi
```

**Step 5: Create `hooks/session-start`**

Port from `WhatToBuildNext?/nexus/scripts/nexus-session-start.sh`:
- Use `NEXUS_PROJECT_ROOT` env var instead of hardcoded path
- If no `.nexus/` found, output "Run /nexus-setup to enable Nexus for this project"
- Query both local and global DBs for dashboard
- Same output format: active tasks + expiring knowledge

```bash
#!/usr/bin/env bash
set -euo pipefail

# If no .nexus/ found, suggest setup
if [[ -z "${NEXUS_PROJECT_ROOT:-}" || ! -d "${NEXUS_PROJECT_ROOT}/.nexus" ]]; then
  echo "Nexus: No .nexus/ found. Run /nexus-setup to enable Nexus for this project."
  exit 0
fi

DB_FILE="${NEXUS_PROJECT_ROOT}/.nexus/nexus.db"
GLOBAL_DB="${HOME}/.nexus/global.db"

if [[ ! -f "${DB_FILE}" ]] || ! command -v sqlite3 &>/dev/null; then
  exit 0
fi

# Calculate expiry threshold (7 days from now)
if [[ "$(uname)" == "Darwin" ]]; then
  EXPIRY_THRESHOLD="$(date -u -v+7d +"%Y-%m-%dT%H:%M:%SZ")"
else
  EXPIRY_THRESHOLD="$(date -u -d "+7 days" +"%Y-%m-%dT%H:%M:%SZ")"
fi

SHOWN_SOMETHING=false

# Active Tasks (local)
TASK_COUNT="$(sqlite3 "${DB_FILE}" "SELECT COUNT(*) FROM tasks WHERE status IN ('pending','in_progress');")"
if [[ "${TASK_COUNT}" -gt 0 ]]; then
  echo "=== Nexus: ${TASK_COUNT} Active Tasks ==="
  sqlite3 "${DB_FILE}" "SELECT id || ' [' || UPPER(status) || '] (' || assignee || ') ' || title FROM tasks WHERE status IN ('pending','in_progress') ORDER BY priority DESC, created_at ASC;"
  SHOWN_SOMETHING=true
fi

# Expiring Knowledge (local)
KNOWLEDGE_COUNT="$(sqlite3 "${DB_FILE}" "SELECT COUNT(*) FROM knowledge WHERE expires_at IS NOT NULL AND expires_at <= '${EXPIRY_THRESHOLD}' AND expires_at > datetime('now');")"
if [[ "${KNOWLEDGE_COUNT}" -gt 0 ]]; then
  $SHOWN_SOMETHING && echo ""
  echo "=== Nexus: ${KNOWLEDGE_COUNT} Knowledge Entries Expiring Soon ==="
  sqlite3 "${DB_FILE}" "SELECT id || ' [' || type || '] ' || fact || ' (expires: ' || date(expires_at) || ')' FROM knowledge WHERE expires_at IS NOT NULL AND expires_at <= '${EXPIRY_THRESHOLD}' AND expires_at > datetime('now') ORDER BY expires_at ASC;"
  SHOWN_SOMETHING=true
fi

# Global knowledge count (info only)
if [[ -f "${GLOBAL_DB}" ]]; then
  GLOBAL_COUNT="$(sqlite3 "${GLOBAL_DB}" "SELECT COUNT(*) FROM knowledge;" 2>/dev/null || echo 0)"
  if [[ "${GLOBAL_COUNT}" -gt 0 ]]; then
    $SHOWN_SOMETHING && echo ""
    echo "=== Nexus: ${GLOBAL_COUNT} Global Knowledge Entries Available ==="
    SHOWN_SOMETHING=true
  fi
fi

if ! $SHOWN_SOMETHING; then
  echo "Nexus: No pending tasks or expiring knowledge. Ready to work."
fi
```

**Step 6: Create `hooks/post-commit`**

Port from `WhatToBuildNext?/nexus/hooks/post-commit-knowledge.sh`:
- Use `NEXUS_PROJECT_ROOT` env var
- Check if `$TOOL_INPUT` contains `git commit` (for PostToolUse matcher)
- If no `.nexus/` found, exit silently
- Same `[NEXUS KNOWLEDGE CAPTURE]` output format

```bash
#!/usr/bin/env bash
set -euo pipefail

# Only fire on git commit commands
if [[ -n "${TOOL_INPUT:-}" ]]; then
  if ! echo "${TOOL_INPUT}" | grep -q "git commit"; then
    exit 0
  fi
fi

# Need .nexus/ to exist
if [[ -z "${NEXUS_PROJECT_ROOT:-}" || ! -d "${NEXUS_PROJECT_ROOT}/.nexus" ]]; then
  exit 0
fi

DB_PATH="${NEXUS_PROJECT_ROOT}/.nexus/nexus.db"
if [[ ! -f "${DB_PATH}" ]]; then
  exit 0
fi

# Get last commit info
COMMIT_MSG=$(git log -1 --pretty=format:'%s' 2>/dev/null || echo 'unknown')
COMMIT_HASH=$(git log -1 --pretty=format:'%h' 2>/dev/null || echo 'unknown')
CHANGED_FILES=$(git diff-tree --no-commit-id --name-only -r HEAD 2>/dev/null | head -10 || echo 'unknown')

cat <<EOF

[NEXUS KNOWLEDGE CAPTURE]

Commit: ${COMMIT_HASH} — ${COMMIT_MSG}
Files changed:
${CHANGED_FILES}

Claude: Review this commit. If it contains a reusable learning (pattern, gotcha,
decision, or anti-pattern), capture it with:

sqlite3 "${DB_PATH}" "INSERT INTO knowledge (id, type, fact, recommendation, confidence, source, tags, files, expires_at, created_at) VALUES ((SELECT printf('k_%03d', COALESCE(MAX(CAST(SUBSTR(id,3) AS INTEGER)),0)+1) FROM knowledge), '<pattern|gotcha|decision|anti-pattern>', '<what was learned>', '<what to do next time>', 'medium', 'claude', '[\"tag1\",\"tag2\"]', '[]', datetime('now', '+90 days'), datetime('now'));"

If this commit has no reusable learning (trivial fix, formatting), skip.

EOF
```

**Step 7: Make hooks executable**

```bash
chmod +x hooks/run-hook.cmd hooks/session-start hooks/post-commit
```

**Step 8: Run tests**

Expected: PASS for both hook tests.

**Step 9: Commit**

```bash
git add hooks/ tests/
git commit -m "feat: add session-start and post-commit hooks"
```

---

### Task 9: Slash Commands (`/nexus`, `/nexus-board`, `/nexus-review`, `/nexus-retro`)

**Files:**
- Create: `~/GitHub/nexus-plugin/commands/nexus.md`
- Create: `~/GitHub/nexus-plugin/commands/nexus-board.md`
- Create: `~/GitHub/nexus-plugin/commands/nexus-review.md`
- Create: `~/GitHub/nexus-plugin/commands/nexus-retro.md`

**Step 1: Create `commands/nexus.md` (main entry)**

```markdown
---
name: nexus
description: Show Nexus dashboard — task board summary and recent knowledge
user_invocable: true
---

Show the Nexus dashboard for this project:

1. Query `.nexus/nexus.db` for active tasks:
   ```bash
   sqlite3 .nexus/nexus.db "SELECT id, status, assignee, title FROM tasks WHERE status IN ('pending','in_progress') ORDER BY priority DESC;"
   ```

2. Query recent knowledge (last 5 entries):
   ```bash
   sqlite3 .nexus/nexus.db "SELECT id, type, fact FROM knowledge ORDER BY created_at DESC LIMIT 5;"
   ```

3. Show task board summary:
   ```bash
   sqlite3 .nexus/nexus.db "SELECT status, COUNT(*) as count FROM tasks GROUP BY status;"
   ```

4. Check global knowledge count:
   ```bash
   sqlite3 ~/.nexus/global.db "SELECT COUNT(*) || ' global knowledge entries' FROM knowledge;" 2>/dev/null || echo "No global DB yet"
   ```

Present results as a concise dashboard.
```

**Step 2: Create `commands/nexus-board.md`**

```markdown
---
name: nexus-board
description: Show the full Nexus task board with all tasks and their status
user_invocable: true
---

Show the full task board from `.nexus/nexus.db`:

```bash
sqlite3 -header -column .nexus/nexus.db "SELECT id, status, assignee, priority, title, created_at FROM tasks ORDER BY CASE status WHEN 'in_progress' THEN 1 WHEN 'pending' THEN 2 WHEN 'review' THEN 3 WHEN 'done' THEN 4 WHEN 'failed' THEN 5 ELSE 6 END, priority DESC;"
```

Also show the summary:
```bash
sqlite3 .nexus/nexus.db "SELECT status, COUNT(*) as count FROM tasks GROUP BY status;"
```

If no `.nexus/` exists, tell the user to run `/nexus-setup`.
```

**Step 3: Create `commands/nexus-review.md`**

```markdown
---
name: nexus-review
description: Dispatch Codex adversarial review of recent changes
user_invocable: true
---

Dispatch a Codex adversarial review. Use the `review` skill from the Nexus plugin.

1. Determine scope — the user may specify files or a commit range. Default: `git diff HEAD~1`
2. Create a review task in `.nexus/nexus.db`
3. Dispatch via the plugin's dispatch library:
   ```bash
   "${CLAUDE_PLUGIN_ROOT}/lib/nexus-dispatch.sh" \
     --mode reviewer \
     --task-id TXXX-review \
     --prompt "Review the recent changes. Find: bugs, security issues, missed edge cases, convention violations. Be adversarial." \
     --project-root "$(pwd)"
   ```
4. Read the output and triage findings
5. Log results to `.nexus/nexus.db`

If Codex is not available, fall back to using Claude's own review capabilities and note the limitation.
```

**Step 4: Create `commands/nexus-retro.md`**

```markdown
---
name: nexus-retro
description: Run session retrospective — review work done, promote knowledge, update memory
user_invocable: true
---

Run a Nexus session retrospective. Use the `reflect` skill from the Nexus plugin.

1. Show tasks completed this session:
   ```bash
   sqlite3 .nexus/nexus.db "SELECT id, title, status FROM tasks WHERE completed_at >= datetime('now', '-8 hours') ORDER BY completed_at DESC;"
   ```

2. Show dispatches this session:
   ```bash
   sqlite3 .nexus/nexus.db "SELECT id, task_id, mode, duration_seconds, exit_code FROM dispatches WHERE timestamp >= datetime('now', '-8 hours');"
   ```

3. Show knowledge added this session:
   ```bash
   sqlite3 .nexus/nexus.db "SELECT id, type, fact FROM knowledge WHERE created_at >= datetime('now', '-8 hours');"
   ```

4. Suggest knowledge promotion candidates:
   - Entries with confidence='high' that appear in 3+ sessions
   - Patterns that apply beyond this project
   - Offer to promote to `~/.nexus/global.db` using:
     ```bash
     source "${CLAUDE_PLUGIN_ROOT}/lib/nexus-db.sh"
     nexus_knowledge_promote ".nexus/nexus.db" "${HOME}/.nexus/global.db" "k_XXX" "$(basename $(pwd))"
     ```

5. Prompt MEMORY.md update if significant learnings occurred.
```

**Step 5: Commit**

```bash
git add commands/
git commit -m "feat: add /nexus, /nexus-board, /nexus-review, /nexus-retro commands"
```

---

### Task 10: Test Suite + Integration Test

Complete the test suite with all major flows.

**Files:**
- Modify: `~/GitHub/nexus-plugin/tests/test-plugin.sh`

**Step 1: Write complete test file**

The test file should follow the same pattern as `WhatToBuildNext?/nexus/tests/test-nexus.sh` with:

- Test harness: `setup_test_env`, `pass`, `fail`, `assert_contains`, `cleanup`
- `PLUGIN_ROOT` points to the plugin directory
- `TMP_ROOT` for isolated test directories
- Override `HOME` for global DB tests

Tests to include:
1. `test_db_init` — local DB creates all 5 tables
2. `test_global_db_init` — global DB has project column
3. `test_knowledge_resolution` — local + global merge
4. `test_dispatch_dry_run` — enriched prompt with context from `.nexus/`
5. `test_session_start_hook` — shows pending tasks
6. `test_post_commit_hook` — outputs NEXUS KNOWLEDGE CAPTURE marker
7. `test_knowledge_promote` — entry copied from local to global with project tag
8. `test_setup_creates_nexus_dir` — `.nexus/` structure created correctly
9. `test_helpers_find_project_root` — walks up directory tree to find `.nexus/`

**Step 2: Run all tests**

```bash
cd ~/GitHub/nexus-plugin && bash tests/test-plugin.sh
```

Expected: All 9 tests PASS.

**Step 3: Commit**

```bash
git add tests/
git commit -m "test: complete test suite — 9 tests covering DB, hooks, dispatch, knowledge"
```

---

### Task 11: README + GitHub Repo Setup

**Files:**
- Create: `~/GitHub/nexus-plugin/README.md`
- Create: `~/GitHub/nexus-plugin/.gitignore`

**Step 1: Create `.gitignore`**

```
.DS_Store
*.db
```

**Step 2: Create `README.md`**

Contents:
- **What is Nexus?** — Multi-agent orchestration for Claude Code. Claude builds, Codex reviews.
- **Install** — How to register in `~/.claude/settings.json` (the `extraKnownMarketplaces` config from the design doc)
- **Quick Start** — `/nexus-setup` then `/nexus`
- **Commands** — Table of `/nexus-*` commands
- **How It Works** — Brief: per-project `.nexus/`, global `~/.nexus/`, hooks, skills
- **Data Model** — Local vs global, knowledge promotion
- **From v0.3** — Migration note

**Step 3: Create GitHub repo and push**

```bash
cd ~/GitHub/nexus-plugin
git add .
git commit -m "docs: add README and .gitignore"
git tag v0.4.0
# User creates repo on GitHub, then:
git remote add origin git@github.com:ranabirbasu/nexus-plugin.git
git push -u origin main --tags
```

**Step 4: Test installation**

Register the plugin in `~/.claude/settings.json`:
```json
{
  "extraKnownMarketplaces": {
    "nexus-marketplace": {
      "source": {
        "source": "github",
        "repo": "ranabirbasu/nexus-plugin"
      }
    }
  },
  "enabledPlugins": {
    "nexus@nexus-marketplace": true
  }
}
```

Verify: restart Claude Code, run `/nexus-setup` in a test project, confirm `.nexus/` created.

**Step 5: Commit (if any final tweaks)**

```bash
git add . && git commit -m "chore: final tweaks after install test" && git push
```

---

## Summary

| Task | What | Key Files |
|------|------|-----------|
| 1 | Scaffold + manifest | `.claude-plugin/plugin.json`, `LICENSE` |
| 2 | Schema + DB helpers | `lib/schema.sql`, `lib/nexus-db.sh`, `lib/helpers.sh` |
| 3 | Global DB + knowledge resolution | `lib/nexus-db.sh` (extend) |
| 4 | Portable dispatch | `lib/nexus-dispatch.sh` |
| 5 | Setup skill + `/nexus-setup` | `skills/setup/SKILL.md`, `commands/nexus-setup.md` |
| 6 | Core skills | `skills/orchestrate/`, `skills/review/`, `skills/reflect/` |
| 7 | Codex reviewer agent | `agents/codex-reviewer.md` |
| 8 | Hooks | `hooks/hooks.json`, `hooks/session-start`, `hooks/post-commit` |
| 9 | Slash commands | `commands/nexus*.md` |
| 10 | Test suite | `tests/test-plugin.sh` |
| 11 | README + GitHub | `README.md`, `.gitignore`, push |

## Dependencies

```
Task 1 (scaffold) → Task 2 (schema/helpers) → Task 3 (global DB) → Task 4 (dispatch)
                                                                  ↘ Task 5 (setup)
Task 2 → Task 6 (skills) — no dependency on 3/4/5
Task 2 → Task 7 (agent) — independent
Task 2 → Task 8 (hooks) — depends on helpers
Task 6 → Task 9 (commands) — commands reference skills
Task 2-9 → Task 10 (tests) — tests cover everything
Task 1-10 → Task 11 (README + push)
```

Tasks 5, 6, 7 can run in parallel after Task 3.
