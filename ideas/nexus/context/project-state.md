# Nexus — Project State

## Architecture (v0.3)
Nexus is a multi-agent orchestration system running as Claude Code skills.
Claude Code (Opus 4.6) is the builder — handles all implementation, scanning, and reasoning.
Codex CLI (gpt-5.3-codex) is the adversarial reviewer — finds what Claude missed.
Codex is registered as an MCP server for native protocol dispatch (with shell fallback).
All state lives in SQLite (nexus/nexus.db): tasks, knowledge, events, dispatches, usage.
Knowledge is captured passively via post-commit hooks, not manual script calls.

## What Changed in v0.3

**From v0.2 → v0.3:**
- Shell scripts → Direct SQLite access as primary interface (zero friction)
- Manual knowledge extraction → Post-commit hook prompts Claude automatically
- Codex as worker/reviewer → Codex as adversarial reviewer only
- Invisible task board → Session-start script surfaces pending tasks
- MEMORY.md separate from SQLite → Memory sync script bridges both
- Script-heavy orchestration skill → Frictionless workflow embedded in natural coding

**Battle-test findings (Quantlab, 2026-03-06):**
The v0.2 shell scripts were never used during 90 min of real work because they added friction. Claude's built-in Agent tool (Explore subagents) outperformed Codex for codebase scanning. Knowledge was lost because nobody called the extract scripts. See `docs/plans/2026-03-06-nexus-v03-battle-test-findings.md`.

## Components

### Scripts
- `nexus/scripts/nexus-dispatch.sh` — Dispatches tasks to Codex (context injection, logging)
- `nexus/scripts/nexus-board.sh` — CRUD for the shared task board
- `nexus/scripts/nexus-knowledge.sh` — Knowledge base management with expiry
- `nexus/scripts/nexus-reflect.sh` — Self-improvement: extract knowledge, detect patterns, session retro
- `nexus/scripts/nexus-session-start.sh` — **v0.3** Session start: surfaces pending tasks + expiring knowledge
- `nexus/scripts/nexus-memory-sync.sh` — **v0.3** MEMORY.md ↔ SQLite knowledge sync
- `nexus/scripts/nexus-status.sh` — Unified status dashboard
- `nexus/scripts/nexus-db.sh` — Database init, migration, query

### Hooks
- `nexus/hooks/post-commit-knowledge.sh` — **v0.3** Post-commit hook for passive knowledge capture

### Skills
- `nexus/skills/nexus-orchestrate.md` — **v0.3** Frictionless workflow, direct SQLite, no script ceremony
- `nexus/skills/nexus-review.md` — **v0.3** Codex as adversarial reviewer only
- `nexus/skills/nexus-reflect.md` — **v0.3** Passive knowledge capture via hooks
- `nexus/skills/nexus-prime.md` — Context priming before work
- `nexus/skills/nexus-board.md` — Task board management

### Tests
- `nexus/tests/test-nexus.sh` — 13 tests (8 v0.2 + 5 v0.3), all passing

## Codex Role (v0.3)

| Dispatch Mode | Use |
|---|---|
| reviewer | Adversarial code review, security audit, architecture review |

Worker and sub-conductor modes remain supported but are not the default. Claude's Explore subagents handle scanning and implementation work faster with better context.

## Knowledge Flow (v0.3)

```
Commit → Post-commit hook → Claude writes knowledge entry (or skips)
Session end → Retro → Promote patterns to conventions.md
Next session → Session-start → Shows pending tasks + expiring knowledge
```

## Failure Taxonomy
timeout, bad_spec, env_missing, test_flake, review_reject, crash

## Key Decisions
- 2026-03-05: Chose Claude Code extension approach over standalone CLI
- 2026-03-05: v0.2 — SQLite, self-improvement loop, MCP integration
- 2026-03-06: v0.3 — Shell scripts create friction; switched to hooks + direct SQLite
- 2026-03-06: v0.3 — Codex narrowed to adversarial reviewer (Claude subagents faster for all else)
- 2026-03-06: v0.3 — Passive knowledge capture via post-commit hooks

## Known Issues
- Codex sandbox blocks network — can't install packages during dispatch
- MCP dispatch not yet tested end-to-end (shell fallback works)
- Post-commit hook depends on Claude Code hooks system (settings.local.json)
