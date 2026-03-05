# Nexus — Multi-Agent Orchestration System

## What Is This

Nexus orchestrates Claude Code and Codex CLI as a coordinated agent swarm. You (Claude Code) are the conductor. Codex CLI is your worker/reviewer/sub-conductor.

## How It Works

You talk to the human. When work comes in, you decide what to handle yourself and what to dispatch to Codex. Both agents share a task board, knowledge base, and project context.

## Key Files

- `nexus/config.json` — Codex model, routing rules, tracking settings
- `nexus/context/project-state.md` — Living architecture doc (you maintain this)
- `nexus/context/conventions.md` — Code style and project rules
- `nexus/context/knowledge.jsonl` — Shared knowledge base (patterns, gotchas, decisions)
- `nexus/board/tasks.json` — Shared task board
- `nexus/logs/dispatches.jsonl` — Codex dispatch log
- `nexus/logs/usage.json` — Usage/cost tracking

## Scripts

- `nexus/scripts/nexus-dispatch.sh` — Dispatch tasks to Codex (context injection, logging)
- `nexus/scripts/nexus-board.sh` — Task board CRUD (add/update/list/show/summary)
- `nexus/scripts/nexus-knowledge.sh` — Knowledge base (add/search/prime/stats)
- `nexus/scripts/nexus-status.sh` — Full status dashboard

## Skills

Read these skills to understand your role:
- `nexus/skills/nexus-orchestrate.md` — Core routing and execution loop
- `nexus/skills/nexus-review.md` — Cross-agent review workflow
- `nexus/skills/nexus-prime.md` — Context priming before work
- `nexus/skills/nexus-board.md` — Task board management

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

Check status:
```bash
./nexus/scripts/nexus-status.sh
```

## Design Principles

1. Verify, never trust — independently validate all agent work
2. Knowledge compounds — extract learnings after every task
3. Escalate, don't loop — 3 retries max, then ask the human
4. Lightweight — 2 agents, simple tools, no heavy framework
5. Cost-aware — track every Codex dispatch
