# Nexus Reflect — Self-Improvement Skill

## Overview

Nexus learns from every task. This skill defines the mandatory reflection loop that extracts knowledge, detects failure patterns, and adapts behavior over time.

## The Reflect Loop

After every task completion (by either agent):

1. **Extract** — What did we learn? Add to knowledge base.
2. **Adapt** — Are failure patterns emerging? Adjust behavior.
3. **Retro** — At session end, summarize the session.

## When to Extract Knowledge

Always extract after:
- A task succeeds (what worked well?)
- A task fails (what went wrong?)
- A review finds issues (what pattern does this suggest?)
- An unexpected behavior is discovered (gotcha)
- A design decision is made (why did we choose X over Y?)

### Good Extractions

Evidence-based, actionable:
```bash
./nexus/scripts/nexus-reflect.sh extract \
  --task-id T001 \
  --outcome success \
  --fact "SQLite json_each() enables tag-based filtering without jq" \
  --rec "Use json_each() for any JSON array searches in SQLite" \
  --type pattern \
  --confidence high \
  --tags "sqlite,json,query"
```

### Bad Extractions

Vague, no evidence:
```bash
# DON'T DO THIS
./nexus/scripts/nexus-reflect.sh extract \
  --task-id T001 \
  --outcome success \
  --fact "SQLite is good" \
  --type pattern
```

## When to Check Adaptations

Run `adapt` before starting new work:
```bash
./nexus/scripts/nexus-reflect.sh adapt
```

This checks for:
- Recurring failures (bad specs, timeouts, crashes)
- Stuck tasks (3+ retries without resolution)
- Environmental issues (missing tools)

If adaptations are suggested, follow them before proceeding.

## Session Retrospective

At session end (or when the human asks):
```bash
./nexus/scripts/nexus-reflect.sh retro
```

Shows: tasks completed, dispatch stats, failure modes, knowledge added, routing effectiveness.

Use this to update `project-state.md` with session learnings.

## Failure Taxonomy

When extracting from failures, classify the failure type:

| Type | When to Use |
|---|---|
| timeout | Dispatch exceeded time limit |
| bad_spec | Task failed due to unclear requirements |
| env_missing | Missing tool/dependency in sandbox |
| test_flake | Tests pass sometimes, fail sometimes |
| review_reject | Reviewer found significant issues |
| crash | Non-zero exit with no useful output |

```bash
./nexus/scripts/nexus-reflect.sh extract \
  --task-id T001 \
  --outcome failed \
  --fact "Codex timed out on large file refactor" \
  --rec "Split large refactors into per-file tasks" \
  --type gotcha \
  --failure-type timeout \
  --tags "codex,timeout,refactor"
```

## Knowledge Lifecycle

1. **Created** — Added via extract (90-day expiry by default)
2. **Active** — Returned in search/prime, injected into Codex prompts
3. **Expiring** — Within 7 days of expiry, flagged in retro
4. **Expired** — Excluded from queries, cleaned up via `nexus-knowledge.sh expire`

Knowledge that proves consistently useful should be promoted to `conventions.md` (permanent, no expiry).
