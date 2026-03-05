#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_SCRIPTS_DIR="$(cd "${TEST_DIR}/../scripts" && pwd)"

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

  mkdir -p "${TEST_NEXUS_ROOT}/scripts" "${TEST_NEXUS_ROOT}/board" "${TEST_NEXUS_ROOT}/context" "${TEST_NEXUS_ROOT}/logs" "${TMP_ROOT}/bin" "${TMP_ROOT}/work"

  cp "${SOURCE_SCRIPTS_DIR}"/*.sh "${TEST_NEXUS_ROOT}/scripts/"
  chmod +x "${TEST_NEXUS_ROOT}/scripts/"*.sh

  cat > "${TEST_NEXUS_ROOT}/board/tasks.json" <<'JSON'
{
  "tasks": []
}
JSON

  : > "${TEST_NEXUS_ROOT}/context/knowledge.jsonl"

  cat > "${TEST_NEXUS_ROOT}/context/project-state.md" <<'MD'
# Test Project State
Test project context from fixture.
MD

  cat > "${TEST_NEXUS_ROOT}/context/conventions.md" <<'MD'
# Test Conventions
- fixture convention
MD

  cat > "${TEST_NEXUS_ROOT}/config.json" <<'JSON'
{
  "codex": {
    "model": "gpt-5.3-codex",
    "timeoutSeconds": 60
  }
}
JSON

  cat > "${TEST_NEXUS_ROOT}/logs/usage.json" <<'JSON'
{
  "total_dispatches": 0,
  "total_duration_seconds": 0,
  "by_mode": {},
  "by_model": {},
  "session_history": []
}
JSON

  : > "${TEST_NEXUS_ROOT}/logs/dispatches.jsonl"

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

test_board_flow() {
  local board="${TEST_NEXUS_ROOT}/scripts/nexus-board.sh"

  local out
  out="$("${board}" add --title "Build tests" --desc "Create automated tests" --assignee codex --priority 2 --mode reviewer)"
  assert_contains "${out}" "Created task T001" || return 1

  out="$("${board}" list)"
  assert_contains "${out}" "T001 [pending] [codex] Build tests" || return 1

  out="$("${board}" update --id T001 --status in_progress)"
  assert_contains "${out}" "Updated task T001" || return 1

  out="$("${board}" show --id T001)"
  assert_contains "${out}" '"id": "T001"' || return 1
  assert_contains "${out}" '"status": "in_progress"' || return 1

  out="$("${board}" summary)"
  assert_contains "${out}" "In Progress: 1" || return 1

  "${board}" update --id T001 --note "needs follow-up" >/dev/null
  "${board}" update --id T001 --retry >/dev/null

  local notes
  notes="$(jq -r '.tasks[] | select(.id=="T001") | .notes[0]' "${TEST_NEXUS_ROOT}/board/tasks.json")"
  [[ "${notes}" == "needs follow-up" ]] || return 1

  local retry_count
  retry_count="$(jq -r '.tasks[] | select(.id=="T001") | .retryCount' "${TEST_NEXUS_ROOT}/board/tasks.json")"
  [[ "${retry_count}" == "1" ]] || return 1

  "${board}" update --id T001 --status done >/dev/null
  local completed
  completed="$(jq -r '.tasks[] | select(.id=="T001") | .completedAt' "${TEST_NEXUS_ROOT}/board/tasks.json")"
  [[ "${completed}" != "null" ]] || return 1
}

test_knowledge_flow() {
  local kb="${TEST_NEXUS_ROOT}/scripts/nexus-knowledge.sh"
  local out

  out="$("${kb}" add --type gotcha --fact "Fixture fact" --rec "Fixture recommendation" --confidence high --source codex --tags "testing,nexus" --files "nexus/scripts/nexus-board.sh")"
  assert_contains "${out}" "Added k_001" || return 1

  out="$("${kb}" search --tags testing)"
  assert_contains "${out}" 'Fixture fact' || return 1

  out="$("${kb}" search --type gotcha)"
  assert_contains "${out}" '"type": "gotcha"' || return 1

  out="$("${kb}" prime --tags nexus --max 5)"
  assert_contains "${out}" "- [gotcha] Fixture fact -> Fixture recommendation" || return 1

  out="$("${kb}" stats)"
  assert_contains "${out}" "Total entries: 1" || return 1
  assert_contains "${out}" "gotcha" || return 1
}

test_dispatch_dry_run() {
  local dispatch="${TEST_NEXUS_ROOT}/scripts/nexus-dispatch.sh"
  local out

  # Seed one knowledge entry so [RELEVANT KNOWLEDGE] is present.
  cat > "${TEST_NEXUS_ROOT}/context/knowledge.jsonl" <<'JSONL'
{"id":"k_001","type":"pattern","fact":"Dispatch fixture","recommendation":"Use dry run","confidence":"high","source":"claude","tags":["dispatch"],"files":[],"timestamp":"2026-03-05T00:00:00Z"}
JSONL

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

test_status_runs() {
  local status_script="${TEST_NEXUS_ROOT}/scripts/nexus-status.sh"
  local out

  out="$("${status_script}")"
  assert_contains "${out}" "N E X U S  STATUS" || return 1
  assert_contains "${out}" "=== Nexus Task Board ===" || return 1
  assert_contains "${out}" "=== Codex Usage ===" || return 1
  assert_contains "${out}" "=== Knowledge Base ===" || return 1
}

main() {
  setup_test_env

  run_test "nexus-board: add/list/update/show/summary/note/retry" test_board_flow
  run_test "nexus-knowledge: add/search/prime/stats" test_knowledge_flow
  run_test "nexus-dispatch: dry-run includes project context" test_dispatch_dry_run
  run_test "nexus-status: runs without error" test_status_runs

  echo ""
  echo "Tests complete: ${PASS_COUNT} passed, ${FAIL_COUNT} failed"

  if [[ ${FAIL_COUNT} -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
