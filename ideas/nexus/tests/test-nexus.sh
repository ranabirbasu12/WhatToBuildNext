#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_SCRIPTS_DIR="$(cd "${TEST_DIR}/../scripts" && pwd)"
SOURCE_SCHEMA="$(cd "${TEST_DIR}/.." && pwd)/schema.sql"

PASS_COUNT=0
FAIL_COUNT=0
TMP_ROOT=""
TEST_NEXUS_ROOT=""

cleanup() {
  if [[ -n "${TMP_ROOT}" && -d "${TMP_ROOT}" ]]; then
    rm -rf "${TMP_ROOT}"
  fi
}
trap cleanup EXIT

pass() {
  local name="$1"
  echo "PASS: ${name}"
  PASS_COUNT=$((PASS_COUNT + 1))
}

fail() {
  local name="$1"
  local reason="$2"
  echo "FAIL: ${name} -- ${reason}"
  FAIL_COUNT=$((FAIL_COUNT + 1))
}

assert_contains() {
  local haystack="$1"
  local needle="$2"
  [[ "${haystack}" == *"${needle}"* ]]
}

setup_test_env() {
  TMP_ROOT="$(mktemp -d)"
  TEST_NEXUS_ROOT="${TMP_ROOT}/nexus"

  mkdir -p "${TEST_NEXUS_ROOT}/scripts" \
           "${TEST_NEXUS_ROOT}/hooks" \
           "${TEST_NEXUS_ROOT}/context" \
           "${TEST_NEXUS_ROOT}/logs" \
           "${TMP_ROOT}/bin" \
           "${TMP_ROOT}/work"

  # Copy scripts
  cp "${SOURCE_SCRIPTS_DIR}"/*.sh "${TEST_NEXUS_ROOT}/scripts/"
  chmod +x "${TEST_NEXUS_ROOT}/scripts/"*.sh

  # Copy hooks
  local hooks_dir="$(cd "${TEST_DIR}/../hooks" && pwd 2>/dev/null)" || true
  if [[ -d "${hooks_dir}" ]]; then
    cp "${hooks_dir}"/*.sh "${TEST_NEXUS_ROOT}/hooks/" 2>/dev/null || true
    chmod +x "${TEST_NEXUS_ROOT}/hooks/"*.sh 2>/dev/null || true
  fi

  # Copy schema and initialize SQLite db
  cp "${SOURCE_SCHEMA}" "${TEST_NEXUS_ROOT}/schema.sql"
  sqlite3 "${TEST_NEXUS_ROOT}/nexus.db" < "${TEST_NEXUS_ROOT}/schema.sql"

  # Context fixtures
  cat > "${TEST_NEXUS_ROOT}/context/project-state.md" <<'MD'
# Test Project State
Test project context from fixture.
MD

  cat > "${TEST_NEXUS_ROOT}/context/conventions.md" <<'MD'
# Test Conventions
- fixture convention
MD

  # Config fixture
  cat > "${TEST_NEXUS_ROOT}/config.json" <<'JSON'
{
  "codex": {
    "model": "gpt-5.3-codex",
    "timeoutSeconds": 60,
    "dispatchBackend": "shell"
  }
}
JSON

  # Stub codex binary
  cat > "${TMP_ROOT}/bin/codex" <<'SH'
#!/usr/bin/env bash
echo "stub codex"
SH
  chmod +x "${TMP_ROOT}/bin/codex"

  export PATH="${TMP_ROOT}/bin:${PATH}"
}

run_test() {
  local name="$1"
  shift

  if "$@"; then
    pass "${name}"
  else
    fail "${name}" "assertion failed"
  fi
}

# ── Test 1: DB initialization ─────────────────────────────────

test_db_init() {
  local tables
  tables="$(sqlite3 "${TEST_NEXUS_ROOT}/nexus.db" ".tables")"

  assert_contains "${tables}" "dispatches" || return 1
  assert_contains "${tables}" "events" || return 1
  assert_contains "${tables}" "knowledge" || return 1
  assert_contains "${tables}" "tasks" || return 1
  assert_contains "${tables}" "usage" || return 1
}

# ── Test 2: Board flow ────────────────────────────────────────

test_board_flow() {
  local board="${TEST_NEXUS_ROOT}/scripts/nexus-board.sh"
  local db="${TEST_NEXUS_ROOT}/nexus.db"
  local out

  # Add a task
  out="$("${board}" add --title "Build tests" --desc "Create automated tests" --assignee codex --priority 2 --mode reviewer)"
  assert_contains "${out}" "Created task T001" || return 1

  # Verify with list
  out="$("${board}" list)"
  assert_contains "${out}" "T001 [pending] [codex] Build tests" || return 1

  # Update status to in_progress
  out="$("${board}" update --id T001 --status in_progress)"
  assert_contains "${out}" "Updated task T001" || return 1

  # Verify with show
  out="$("${board}" show --id T001)"
  assert_contains "${out}" '"id": "T001"' || return 1
  assert_contains "${out}" '"status": "in_progress"' || return 1

  # Add a note
  "${board}" update --id T001 --note "needs follow-up" >/dev/null
  local notes
  notes="$(sqlite3 "${db}" "SELECT notes FROM tasks WHERE id = 'T001';")"
  assert_contains "${notes}" "needs follow-up" || return 1

  # Retry
  "${board}" update --id T001 --retry >/dev/null
  local retry_count
  retry_count="$(sqlite3 "${db}" "SELECT retry_count FROM tasks WHERE id = 'T001';")"
  [[ "${retry_count}" == "1" ]] || return 1

  # Mark done
  "${board}" update --id T001 --status done >/dev/null
  local completed
  completed="$(sqlite3 "${db}" "SELECT completed_at FROM tasks WHERE id = 'T001';")"
  [[ -n "${completed}" && "${completed}" != "" ]] || return 1

  # Summary
  out="$("${board}" summary)"
  assert_contains "${out}" "Done: 1" || return 1
}

# ── Test 3: Knowledge flow ────────────────────────────────────

test_knowledge_flow() {
  local kb="${TEST_NEXUS_ROOT}/scripts/nexus-knowledge.sh"
  local out

  # Add entry with all fields
  out="$("${kb}" add --type gotcha --fact "Fixture fact" --rec "Fixture recommendation" --confidence high --source codex --tags "testing,nexus" --files "nexus/scripts/nexus-board.sh")"
  assert_contains "${out}" "Added k_001" || return 1

  # Search by tags
  out="$("${kb}" search --tags testing)"
  assert_contains "${out}" "Fixture fact" || return 1

  # Search by type
  out="$("${kb}" search --type gotcha)"
  assert_contains "${out}" '"type":"gotcha"' || return 1

  # Prime output format
  out="$("${kb}" prime --tags nexus --max 5)"
  assert_contains "${out}" "- [gotcha] Fixture fact -> Fixture recommendation" || return 1

  # Stats
  out="$("${kb}" stats)"
  assert_contains "${out}" "Total entries: 1" || return 1
  assert_contains "${out}" "gotcha" || return 1
}

# ── Test 4: Dispatch dry-run ──────────────────────────────────

test_dispatch_dry_run() {
  local dispatch="${TEST_NEXUS_ROOT}/scripts/nexus-dispatch.sh"
  local db="${TEST_NEXUS_ROOT}/nexus.db"
  local out

  # Seed a knowledge entry directly in SQLite
  sqlite3 "${db}" "INSERT INTO knowledge (id, type, fact, recommendation, confidence, source, tags, files, created_at) VALUES ('k_dispatch', 'pattern', 'Dispatch fixture', 'Use dry run', 'high', 'claude', '[\"dispatch\"]', '[]', '2026-03-05T00:00:00Z');"

  out="$("${dispatch}" --mode worker --task-id T999 --prompt "Validate enriched prompt" --dir "${TMP_ROOT}/work" --dry-run)"

  assert_contains "${out}" "NEXUS DISPATCH" || return 1
  assert_contains "${out}" "[PROJECT CONTEXT]" || return 1
  assert_contains "${out}" "Test project context from fixture." || return 1
  assert_contains "${out}" "[CONVENTIONS]" || return 1
  assert_contains "${out}" "[RELEVANT KNOWLEDGE]" || return 1
  assert_contains "${out}" "[TASK]" || return 1
  assert_contains "${out}" "Validate enriched prompt" || return 1
  assert_contains "${out}" "Dry run complete. No execution performed." || return 1
}

# ── Test 5: Status dashboard ─────────────────────────────────

test_status_runs() {
  local status_script="${TEST_NEXUS_ROOT}/scripts/nexus-status.sh"
  local out

  out="$("${status_script}")"
  assert_contains "${out}" "N E X U S  STATUS" || return 1
  assert_contains "${out}" "=== Nexus Task Board ===" || return 1
  assert_contains "${out}" "=== Codex Usage ===" || return 1
  assert_contains "${out}" "=== Knowledge Base ===" || return 1
  assert_contains "${out}" "=== Failure Taxonomy ===" || return 1
}

# ── Test 6: Reflect extract ──────────────────────────────────

test_reflect_extract() {
  local reflect="${TEST_NEXUS_ROOT}/scripts/nexus-reflect.sh"
  local db="${TEST_NEXUS_ROOT}/nexus.db"
  local out

  # Add a task to db first
  sqlite3 "${db}" "INSERT INTO tasks (id, title, description, assignee, priority, status, mode, retry_count, depends, notes, created_at) VALUES ('T100', 'Reflect test task', 'Task for reflect testing', 'codex', 1, 'done', 'worker', 0, '[]', '[]', '2026-03-05T00:00:00Z');"

  # Run reflect extract
  out="$("${reflect}" extract --task-id T100 --outcome success --fact "Tests should seed SQLite directly" --type pattern --rec "Use INSERT statements" --confidence high --tags "testing,reflect" --files "test-nexus.sh")"
  assert_contains "${out}" "Extracted" || return 1
  assert_contains "${out}" "pattern" || return 1

  # Verify knowledge entry in db
  local fact_in_db
  fact_in_db="$(sqlite3 "${db}" "SELECT fact FROM knowledge WHERE source_task_id = 'T100';")"
  assert_contains "${fact_in_db}" "Tests should seed SQLite directly" || return 1

  # Verify event logged
  local event_count
  event_count="$(sqlite3 "${db}" "SELECT COUNT(*) FROM events WHERE event_type = 'knowledge_extracted' AND task_id = 'T100';")"
  [[ "${event_count}" -ge 1 ]] || return 1

  # Try extracting duplicate fact — should print "Skipped"
  out="$("${reflect}" extract --task-id T100 --outcome success --fact "Tests should seed SQLite directly" --type pattern)"
  assert_contains "${out}" "Skipped" || return 1
}

# ── Test 7: Reflect adapt ────────────────────────────────────

test_reflect_adapt() {
  local reflect="${TEST_NEXUS_ROOT}/scripts/nexus-reflect.sh"
  local db="${TEST_NEXUS_ROOT}/nexus.db"
  local today
  today="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  local out

  # Insert dispatch records with failure_type for today
  sqlite3 "${db}" "INSERT INTO dispatches (id, timestamp, task_id, mode, model, backend, duration_seconds, exit_code, failure_type) VALUES ('d-adapt-1', '${today}', 'T200', 'worker', 'gpt-5.3-codex', 'shell', 10, 1, 'timeout');"
  sqlite3 "${db}" "INSERT INTO dispatches (id, timestamp, task_id, mode, model, backend, duration_seconds, exit_code, failure_type) VALUES ('d-adapt-2', '${today}', 'T201', 'worker', 'gpt-5.3-codex', 'shell', 10, 1, 'timeout');"
  sqlite3 "${db}" "INSERT INTO dispatches (id, timestamp, task_id, mode, model, backend, duration_seconds, exit_code, failure_type) VALUES ('d-adapt-3', '${today}', 'T202', 'worker', 'gpt-5.3-codex', 'shell', 10, 1, 'env_missing');"

  out="$("${reflect}" adapt)"

  assert_contains "${out}" "Adaptation Check" || return 1
  # Should suggest adaptations for timeout (2) and env_missing (1)
  assert_contains "${out}" "timeout" || return 1
  assert_contains "${out}" "env_missing" || return 1
}

# ── Test 8: Reflect retro ────────────────────────────────────

test_reflect_retro() {
  local reflect="${TEST_NEXUS_ROOT}/scripts/nexus-reflect.sh"
  local db="${TEST_NEXUS_ROOT}/nexus.db"
  local today
  today="$(date -u +"%Y-%m-%d")"
  local now
  now="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  local out

  # Insert a completed task for today
  sqlite3 "${db}" "INSERT OR IGNORE INTO tasks (id, title, description, assignee, priority, status, mode, retry_count, depends, notes, created_at, completed_at) VALUES ('T300', 'Retro task', 'For retro test', 'codex', 1, 'done', 'worker', 0, '[]', '[]', '${now}', '${now}');"

  # Insert a dispatch for today
  sqlite3 "${db}" "INSERT INTO dispatches (id, timestamp, task_id, mode, model, backend, duration_seconds, exit_code) VALUES ('d-retro-1', '${now}', 'T300', 'worker', 'gpt-5.3-codex', 'shell', 15, 0);"

  # Insert a knowledge entry for today
  sqlite3 "${db}" "INSERT INTO knowledge (id, type, fact, recommendation, confidence, source, tags, files, created_at) VALUES ('k_retro', 'pattern', 'Retro test fact', '', 'medium', 'claude', '[]', '[]', '${now}');"

  out="$("${reflect}" retro)"

  assert_contains "${out}" "Tasks completed" || return 1
  assert_contains "${out}" "Dispatches" || return 1
  assert_contains "${out}" "Knowledge added" || return 1
  assert_contains "${out}" "Routing effectiveness" || return 1
}

# ── v0.3 Tests ──────────────────────────────────────────────

test_v03_hook_exists() {
  local hook="${TEST_NEXUS_ROOT}/hooks/post-commit-knowledge.sh"
  [[ -f "${hook}" ]] || return 1
  [[ -x "${hook}" ]] || return 1

  # Should output NEXUS KNOWLEDGE CAPTURE marker (may show 'unknown' for git info)
  local out
  out="$(bash "${hook}" 2>&1)" || true
  assert_contains "${out}" "NEXUS KNOWLEDGE CAPTURE" || return 1
}

test_v03_session_start() {
  local script="${TEST_NEXUS_ROOT}/scripts/nexus-session-start.sh"
  local out
  out="$(bash "${script}" 2>&1)"
  [[ $? -eq 0 ]] || return 1
  # Should produce output (either "Ready to work" or task listing)
  [[ -n "${out}" ]] || return 1
}

test_v03_memory_sync() {
  local script="${TEST_NEXUS_ROOT}/scripts/nexus-memory-sync.sh"
  local out
  out="$(bash "${script}" stats 2>&1)"
  assert_contains "${out}" "Total active" || assert_contains "${out}" "Knowledge Base Stats" || return 1
}

test_v03_config_reviewer_default() {
  # Check the real config (not the test fixture)
  local real_config
  real_config="$(cd "${TEST_DIR}/../.." && pwd)/nexus/config.json"
  if [[ -f "${real_config}" ]]; then
    local mode
    mode="$(python3 -c "import json; print(json.load(open('${real_config}'))['codex']['defaultMode'])")"
    [[ "${mode}" == "reviewer" ]] || return 1
  fi
}

test_v03_claude_md_session_start() {
  local claude_md
  claude_md="$(cd "${TEST_DIR}/../.." && pwd)/CLAUDE.md"
  grep -q "nexus-session-start.sh" "${claude_md}" || return 1
}

# ── Main ──────────────────────────────────────────────────────

main() {
  setup_test_env

  # v0.2 tests
  run_test "test_db_init: schema creates all 5 tables" test_db_init
  run_test "test_board_flow: add/list/update/show/note/retry/done/summary" test_board_flow
  run_test "test_knowledge_flow: add/search/prime/stats" test_knowledge_flow
  run_test "test_dispatch_dry_run: enriched prompt with SQLite knowledge" test_dispatch_dry_run
  run_test "test_status_runs: dashboard sections present" test_status_runs
  run_test "test_reflect_extract: knowledge extraction + dedup" test_reflect_extract
  run_test "test_reflect_adapt: failure pattern adaptation" test_reflect_adapt
  run_test "test_reflect_retro: session retrospective" test_reflect_retro

  # v0.3 tests
  run_test "test_v03_hook_exists: post-commit hook exists and outputs marker" test_v03_hook_exists
  run_test "test_v03_session_start: session-start script runs" test_v03_session_start
  run_test "test_v03_memory_sync: memory-sync stats runs" test_v03_memory_sync
  run_test "test_v03_config_reviewer_default: config has reviewer as default" test_v03_config_reviewer_default
  run_test "test_v03_claude_md_session_start: CLAUDE.md references session-start" test_v03_claude_md_session_start

  echo ""
  echo "Tests complete: ${PASS_COUNT} passed, ${FAIL_COUNT} failed"

  if [[ ${FAIL_COUNT} -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
