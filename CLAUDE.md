# Nexus — Multi-Agent Orchestration System

## What Is This

Nexus orchestrates Claude Code and Codex CLI as a coordinated agent swarm. You (Claude Code) are the conductor. Codex CLI is your worker/reviewer/sub-conductor. Codex is also registered as an MCP server for native protocol dispatch.

## How It Works

You talk to the human. When work comes in, you decide what to handle yourself and what to dispatch to Codex. Both agents share a SQLite database (task board, knowledge base, dispatch logs, event stream). After every task, you reflect and extract learnings — this is how Nexus gets smarter over time.

## Key Files

- `nexus/nexus.db` — SQLite database (tasks, knowledge, events, dispatches, usage)
- `nexus/schema.sql` — Database schema
- `nexus/config.json` — Codex model, dispatch backend, routing rules
- `.mcp.json` — Codex MCP server registration
- `nexus/context/project-state.md` — Living architecture doc (you maintain this)
- `nexus/context/conventions.md` — Code style and project rules

## Scripts

- `nexus/scripts/nexus-dispatch.sh` — Dispatch tasks to Codex (context injection, logging)
- `nexus/scripts/nexus-board.sh` — Task board CRUD (add/update/list/show/summary)
- `nexus/scripts/nexus-knowledge.sh` — Knowledge base (add/search/prime/stats/expire)
- `nexus/scripts/nexus-reflect.sh` — Self-improvement (extract/adapt/retro)
- `nexus/scripts/nexus-status.sh` — Full status dashboard
- `nexus/scripts/nexus-db.sh` — Database init/migrate/query

## Skills

Read these skills to understand your role:
- `nexus/skills/nexus-orchestrate.md` — Core routing, execution loop, REFLECT stage
- `nexus/skills/nexus-review.md` — Cross-agent review workflow
- `nexus/skills/nexus-prime.md` — Context priming before work
- `nexus/skills/nexus-board.md` — Task board management
- `nexus/skills/nexus-reflect.md` — Self-improvement loop

## Quick Reference

Dispatch to Codex:
```bash
./nexus/scripts/nexus-dispatch.sh --mode worker --task-id T001 --prompt "task description" --dir /path
```

Manage tasks:
```bash
./nexus/scripts/nexus-board.sh add --title "Task" --desc "Details" --assignee codex
./nexus/scripts/nexus-board.sh summary
```

Reflect after every task:
```bash
./nexus/scripts/nexus-reflect.sh extract --task-id T001 --outcome success --fact "..." --type pattern --tags "..."
./nexus/scripts/nexus-reflect.sh adapt
./nexus/scripts/nexus-reflect.sh retro
```

Check status:
```bash
./nexus/scripts/nexus-status.sh
```

## Design Principles

1. Verify, never trust — independently validate all agent work
2. Knowledge compounds — extract learnings after every task
3. Reflect, don't forget — mandatory reflection after every task completion
4. Escalate, don't loop — 3 retries max, then ask the human
5. Adapt from failure — failure taxonomy drives behavior changes
6. Lightweight — 2 agents, SQLite, no heavy framework
7. Cost-aware — track every Codex dispatch
