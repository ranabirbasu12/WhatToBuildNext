# Nexus — Project State

## Architecture
Nexus is a multi-agent orchestration system running as Claude Code skills.
Claude Code (Opus 4.6) acts as conductor, dispatching to Codex CLI (gpt-5.3-codex) for execution.
Codex is registered as an MCP server for native protocol dispatch (with shell fallback).
All state lives in SQLite (nexus/nexus.db): tasks, knowledge, events, dispatches, usage.

## Components
- `nexus/scripts/nexus-dispatch.sh` — Dispatches tasks to Codex with context injection, output capture, and usage logging
- `nexus/scripts/nexus-board.sh` — CRUD for the shared task board (SQLite backend)
- `nexus/scripts/nexus-knowledge.sh` — Knowledge base management with expiry (SQLite backend)
- `nexus/scripts/nexus-reflect.sh` — Self-improvement: extract knowledge, detect failure patterns, session retrospective
- `nexus/scripts/nexus-status.sh` — Unified status dashboard with failure taxonomy
- `nexus/scripts/nexus-db.sh` — Database init, migration, and query tool
- `nexus/tests/test-nexus.sh` — Automated test suite (8 tests, all passing)
- `nexus/skills/*.md` — Claude Code skills for orchestration, review, priming, board, reflect

## Dispatch Modes
| Mode | Use Case |
|---|---|
| worker | Well-defined single task |
| reviewer | Code audit / security review |
| sub-conductor | Complex task (Codex spawns its own agents) |

## Dispatch Backends
| Backend | Method |
|---|---|
| mcp | Native MCP protocol via codex mcp-server (primary) |
| shell | codex exec with pipe (fallback) |

## Self-Improvement Loop
1. REFLECT after every task — extract knowledge with evidence
2. ADAPT before new work — check failure patterns, adjust routing
3. RETRO at session end — summarize wins/failures, update project state
4. Knowledge expires after 90 days — auto-pruned

## Failure Taxonomy
timeout, bad_spec, env_missing, test_flake, review_reject, crash

## Recent Decisions
- 2026-03-05: Chose Claude Code extension approach over standalone CLI
- 2026-03-05: Inspired by Metaswarm but kept lightweight
- 2026-03-05: Cross-review is mandatory
- 2026-03-05: v0.2 — Migrated to SQLite, added self-improvement loop, MCP integration

## Proven Workflows
1. Codex as Worker: dispatched test writing, implementation tasks — works
2. Codex as Reviewer: audited scripts, found 15 real issues — works
3. Cross-review: Codex reviews Claude's code, Claude reviews Codex's — works
4. Nexus improving Nexus: meta-bootstrapping via cross-review — works
5. Codex as Architect: reviewed v0.2 design, added SQLite + event log ideas — works

## Known Issues
- Codex sandbox blocks network — can't install packages during dispatch
- MCP dispatch not yet tested end-to-end (shell fallback works)

## Stats
- Total dispatches: 5 (2 worker, 2 reviewer, 1 v0.2 architecture review)
- Knowledge base: 6 entries (with 90-day expiry)
- Test coverage: 8 tests (db, board, knowledge, dispatch, status, reflect x3)
