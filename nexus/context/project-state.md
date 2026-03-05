# Nexus — Project State

## Architecture
Nexus is a multi-agent orchestration system running as Claude Code skills.
Claude Code (Opus 4.6) acts as conductor, dispatching to Codex CLI (gpt-5.3-codex) for execution.
Both agents share a task board (JSON), knowledge base (JSONL), and project context (markdown).

## Components
- `nexus/scripts/nexus-dispatch.sh` — Dispatches tasks to Codex with context injection, output capture, and usage logging
- `nexus/scripts/nexus-board.sh` — CRUD for the shared task board (add/update/list/show/summary)
- `nexus/scripts/nexus-knowledge.sh` — Knowledge base management (add/search/prime/stats)
- `nexus/scripts/nexus-status.sh` — Unified status dashboard
- `nexus/tests/test-nexus.sh` — Automated test suite (4 tests, all passing)
- `nexus/skills/*.md` — Claude Code skills for orchestration, review, priming, board management

## Dispatch Modes
| Mode | Use Case |
|---|---|
| worker | Well-defined single task |
| reviewer | Code audit / security review |
| sub-conductor | Complex task (Codex spawns its own agents) |

## Recent Decisions
- 2026-03-05: Chose Claude Code extension approach over standalone CLI
- 2026-03-05: Code-first scope, extensible architecture
- 2026-03-05: Inspired by Metaswarm (execution loop, knowledge base) but kept lightweight
- 2026-03-05: Cross-review is mandatory — Codex audited Claude's code, found 15 issues

## Proven Workflows
1. Codex as Worker: dispatched test writing task, validated independently — works
2. Codex as Reviewer: audited all scripts, found jq injection + crashes — works
3. Claude fixes Codex findings: applied 8 fixes from audit — works
4. Codex builds test suite: 4/4 passing, self-corrected assertion bug — works

## Known Issues
- No file locking for concurrent task board access (minor — single-user for now)
- CSV parsing keeps whitespace in tags/depends (cosmetic)
- Codex sandbox blocks network — can't install packages during dispatch
- Knowledge base IDs based on line count, not max ID (can collide after deletions)

## Stats
- Total dispatches: 3 (2 worker, 1 reviewer)
- Knowledge base: 6 entries
- Test coverage: board, knowledge, dispatch (dry-run), status
