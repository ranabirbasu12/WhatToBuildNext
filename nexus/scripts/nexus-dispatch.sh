#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────
# nexus-dispatch.sh — Codex Dispatch Script
# Invokes codex exec with context-enriched prompts, captures
# output, logs dispatches and usage.
# ─────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NEXUS_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# ── Defaults ────────────────────────────────────────────────
MODE=""
TASK_ID=""
PROMPT=""
DIR="$(pwd)"
DRY_RUN=false
OUTPUT_FILE=""

# ── Parse arguments ─────────────────────────────────────────
usage() {
  cat <<EOF
Usage: nexus-dispatch.sh [OPTIONS]

Options:
  --mode       worker|reviewer|sub-conductor  (required)
  --task-id    Task identifier, e.g. T001      (required)
  --prompt     The task prompt                  (required)
  --dir        Working directory (default: pwd)
  --output     Output file path
  --dry-run    Print enriched prompt and command without executing
  -h, --help   Show this help message
EOF
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)
      MODE="$2"; shift 2 ;;
    --task-id)
      TASK_ID="$2"; shift 2 ;;
    --prompt)
      PROMPT="$2"; shift 2 ;;
    --dir)
      DIR="$2"; shift 2 ;;
    --output)
      OUTPUT_FILE="$2"; shift 2 ;;
    --dry-run)
      DRY_RUN=true; shift ;;
    -h|--help)
      usage ;;
    *)
      echo "Error: unknown option '$1'" >&2
      usage ;;
  esac
done

# ── Validate required args ──────────────────────────────────
if [[ -z "${MODE}" ]]; then
  echo "Error: --mode is required" >&2; usage
fi
if [[ "${MODE}" != "worker" && "${MODE}" != "reviewer" && "${MODE}" != "sub-conductor" ]]; then
  echo "Error: --mode must be worker, reviewer, or sub-conductor" >&2; usage
fi
if [[ -z "${TASK_ID}" ]]; then
  echo "Error: --task-id is required" >&2; usage
fi
if [[ -z "${PROMPT}" ]]; then
  echo "Error: --prompt is required" >&2; usage
fi

# ── Read config ─────────────────────────────────────────────
CONFIG_FILE="${NEXUS_ROOT}/config.json"
if [[ ! -f "${CONFIG_FILE}" ]]; then
  echo "Error: config.json not found at ${CONFIG_FILE}" >&2
  exit 1
fi

MODEL="$(jq -r '.codex.model' "${CONFIG_FILE}")"
TIMEOUT="$(jq -r '.codex.timeoutSeconds' "${CONFIG_FILE}")"

# ── Build context-enriched prompt ───────────────────────────
ENRICHED_PROMPT=""

# [PROJECT CONTEXT]
PROJECT_STATE_FILE="${NEXUS_ROOT}/context/project-state.md"
if [[ -f "${PROJECT_STATE_FILE}" ]]; then
  PROJECT_STATE="$(cat "${PROJECT_STATE_FILE}")"
  ENRICHED_PROMPT+="[PROJECT CONTEXT]
${PROJECT_STATE}

"
fi

# [CONVENTIONS]
CONVENTIONS_FILE="${NEXUS_ROOT}/context/conventions.md"
if [[ -f "${CONVENTIONS_FILE}" ]]; then
  CONVENTIONS="$(cat "${CONVENTIONS_FILE}")"
  ENRICHED_PROMPT+="[CONVENTIONS]
${CONVENTIONS}

"
fi

# [RELEVANT KNOWLEDGE]
KNOWLEDGE_FILE="${NEXUS_ROOT}/context/knowledge.jsonl"
if [[ -f "${KNOWLEDGE_FILE}" && -s "${KNOWLEDGE_FILE}" ]]; then
  KNOWLEDGE="$(cat "${KNOWLEDGE_FILE}")"
  ENRICHED_PROMPT+="[RELEVANT KNOWLEDGE]
${KNOWLEDGE}

"
fi

# [TASK]
ENRICHED_PROMPT+="[TASK]
${PROMPT}

"

# [DELIVERABLES]
ENRICHED_PROMPT+="[DELIVERABLES]
Report the following when done:
1. List all files changed (created, modified, deleted)
2. List any issues encountered or decisions made
3. Confirm task completion status
"

# ── Determine output file ──────────────────────────────────
if [[ -z "${OUTPUT_FILE}" ]]; then
  OUTPUT_FILE="${NEXUS_ROOT}/logs/output-${TASK_ID}-$(date +%s).md"
fi

# ── Build command ───────────────────────────────────────────
CODEX_CMD=(
  codex exec
  --full-auto
  -C "${DIR}"
  -m "${MODEL}"
  --ephemeral
  -o "${OUTPUT_FILE}"
)

# ── Dry-run mode ────────────────────────────────────────────
if [[ "${DRY_RUN}" == true ]]; then
  echo "============================================"
  echo "  NEXUS DISPATCH — DRY RUN"
  echo "============================================"
  echo ""
  echo "── Configuration ──"
  echo "  Model:     ${MODEL}"
  echo "  Timeout:   ${TIMEOUT}s"
  echo "  Mode:      ${MODE}"
  echo "  Task ID:   ${TASK_ID}"
  echo "  Directory: ${DIR}"
  echo "  Output:    ${OUTPUT_FILE}"
  echo ""
  echo "── Command ──"
  echo "  ${CODEX_CMD[*]}"
  echo ""
  echo "── Enriched Prompt ──"
  echo "${ENRICHED_PROMPT}"
  echo "============================================"
  echo "Dry run complete. No execution performed."
  exit 0
fi

# ── Execute ─────────────────────────────────────────────────
START_TS="$(date +%s)"
START_ISO="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

EXIT_CODE=0
# Use gtimeout (coreutils) if available, otherwise run without timeout
if command -v gtimeout &>/dev/null; then
  echo "${ENRICHED_PROMPT}" | gtimeout "${TIMEOUT}" "${CODEX_CMD[@]}" || EXIT_CODE=$?
elif command -v timeout &>/dev/null; then
  echo "${ENRICHED_PROMPT}" | timeout "${TIMEOUT}" "${CODEX_CMD[@]}" || EXIT_CODE=$?
else
  echo "${ENRICHED_PROMPT}" | "${CODEX_CMD[@]}" || EXIT_CODE=$?
fi

END_TS="$(date +%s)"
DURATION=$(( END_TS - START_TS ))

# ── Detect changed files ───────────────────────────────────
FILES_CHANGED="[]"
if command -v git &>/dev/null && git -C "${DIR}" rev-parse --git-dir &>/dev/null; then
  FILES_CHANGED="$(git -C "${DIR}" diff --name-only HEAD 2>/dev/null | jq -R -s 'split("\n") | map(select(length > 0))')"
fi

# ── Log to dispatches.jsonl ─────────────────────────────────
DISPATCHES_LOG="${NEXUS_ROOT}/logs/dispatches.jsonl"
PROMPT_SUMMARY="$(echo "${PROMPT}" | cut -c1-100)"
DISPATCH_ID="d-${TASK_ID}-$(date +%s)"

DISPATCH_ENTRY="$(jq -c -n \
  --arg id "${DISPATCH_ID}" \
  --arg timestamp "${START_ISO}" \
  --arg taskId "${TASK_ID}" \
  --arg mode "${MODE}" \
  --arg model "${MODEL}" \
  --arg prompt_summary "${PROMPT_SUMMARY}" \
  --argjson duration_seconds "${DURATION}" \
  --argjson exit_code "${EXIT_CODE}" \
  --argjson files_changed "${FILES_CHANGED}" \
  '{
    id: $id,
    timestamp: $timestamp,
    taskId: $taskId,
    mode: $mode,
    model: $model,
    prompt_summary: $prompt_summary,
    duration_seconds: $duration_seconds,
    exit_code: $exit_code,
    files_changed: $files_changed,
    validated: false,
    reviewed_by: null,
    review_result: null
  }'
)"

echo "${DISPATCH_ENTRY}" >> "${DISPATCHES_LOG}"

# ── Update usage.json ───────────────────────────────────────
USAGE_FILE="${NEXUS_ROOT}/logs/usage.json"
TODAY="$(date +%Y-%m-%d)"

if [[ ! -f "${USAGE_FILE}" ]]; then
  echo '{"total_dispatches":0,"total_duration_seconds":0,"by_mode":{},"by_model":{},"session_history":[]}' > "${USAGE_FILE}"
fi

UPDATED_USAGE="$(jq \
  --arg mode "${MODE}" \
  --arg model "${MODEL}" \
  --argjson duration "${DURATION}" \
  --arg today "${TODAY}" \
  '
  .total_dispatches += 1 |
  .total_duration_seconds += $duration |
  .by_mode[$mode] = ((.by_mode[$mode] // 0) + 1) |
  .by_model[$model] = ((.by_model[$model] // 0) + 1) |
  (
    if (.session_history | map(select(.date == $today)) | length) > 0 then
      .session_history |= map(
        if .date == $today then
          .dispatches += 1 | .duration_seconds += $duration
        else . end
      )
    else
      .session_history += [{"date": $today, "dispatches": 1, "duration_seconds": $duration}]
    end
  )
  ' "${USAGE_FILE}"
)"

echo "${UPDATED_USAGE}" > "${USAGE_FILE}"

# ── Summary ─────────────────────────────────────────────────
echo ""
echo "── Dispatch Complete ──"
echo "  ID:        ${DISPATCH_ID}"
echo "  Task:      ${TASK_ID}"
echo "  Mode:      ${MODE}"
echo "  Duration:  ${DURATION}s"
echo "  Exit Code: ${EXIT_CODE}"
echo "  Output:    ${OUTPUT_FILE}"
echo "  Files Changed: $(echo "${FILES_CHANGED}" | jq -r 'length')"
