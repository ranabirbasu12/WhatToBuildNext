# Nexus v0.3 — Multi-Agent Orchestration System

## What Is This

Nexus orchestrates Claude Code and Codex CLI. You (Claude Code) are the builder. Codex CLI is your adversarial reviewer. Nexus captures knowledge passively, surfaces pending work automatically, and stays out of your way.

## How It Works

You talk to the human. You handle all implementation work using your normal tools (Read, Edit, Write, Agent, Bash). After significant work, you dispatch Codex for adversarial review. Knowledge is captured automatically via post-commit hooks. The task board surfaces at session start.

## On Session Start

Run this at the start of every conversation:
```bash
./nexus/scripts/nexus-session-start.sh
```

If there are pending tasks, acknowledge them. If knowledge is expiring, decide: promote to `nexus/context/conventions.md` or let expire.

## Key Files

- `nexus/nexus.db` — SQLite database (tasks, knowledge, events, dispatches, usage)
- `nexus/schema.sql` — Database schema (unchanged since v0.2)
- `nexus/config.json` — Codex model, dispatch backend, routing rules
- `.mcp.json` — Codex MCP server registration
- `nexus/context/project-state.md` — Living architecture doc (update at milestones)
- `nexus/context/conventions.md` — Permanent patterns (promoted from knowledge base)

## Skills

Read these to understand your role:
- `nexus/skills/nexus-orchestrate.md` — Core workflow (v0.3: frictionless, no script ceremony)
- `nexus/skills/nexus-review.md` — Codex adversarial review (v0.3: reviewer only, not worker)
- `nexus/skills/nexus-reflect.md` — Passive knowledge capture (v0.3: hooks-based)
- `nexus/skills/nexus-prime.md` — Context priming before work
- `nexus/skills/nexus-board.md` — Task board management

## Quick Reference

### Direct SQLite (preferred — zero friction):
```bash
# Query knowledge
sqlite3 nexus/nexus.db "SELECT fact, recommendation FROM knowledge WHERE (expires_at IS NULL OR expires_at > datetime('now')) ORDER BY created_at DESC LIMIT 5;"

# Add knowledge
sqlite3 nexus/nexus.db "INSERT INTO knowledge (id, type, fact, recommendation, confidence, source, tags, files, expires_at, created_at) VALUES ((SELECT printf('k_%03d', COALESCE(MAX(CAST(SUBSTR(id,3) AS INTEGER)),0)+1) FROM knowledge), 'pattern', 'FACT', 'REC', 'medium', 'claude', '[]', '[]', datetime('now', '+90 days'), datetime('now'));"

# Quick task creation
sqlite3 nexus/nexus.db "INSERT INTO tasks (id, title, description, assignee, priority, status, mode, created_at) VALUES ((SELECT printf('T%03d', COALESCE(MAX(CAST(SUBSTR(id,2) AS INTEGER)),0)+1) FROM tasks), 'Title', 'Desc', 'claude', 1, 'in_progress', 'worker', datetime('now'));"

# Check pending tasks
sqlite3 nexus/nexus.db "SELECT id, title, status FROM tasks WHERE status IN ('pending','in_progress') ORDER BY priority;"
```

### Scripts (still available for complex operations):
```bash
./nexus/scripts/nexus-dispatch.sh --mode reviewer --task-id TXXX --prompt "Review..." --dir /path
./nexus/scripts/nexus-board.sh summary
./nexus/scripts/nexus-reflect.sh retro
./nexus/scripts/nexus-session-start.sh
./nexus/scripts/nexus-memory-sync.sh export
./nexus/scripts/nexus-status.sh
```

## Design Principles

1. **Verify, never trust** — independently validate all agent work
2. **Knowledge compounds** — extract learnings after every significant commit
3. **Reflect, don't forget** — post-commit hook reminds you; follow through
4. **Escalate, don't loop** — 3 retries max, then ask the human
5. **Adapt from failure** — failure taxonomy drives behavior changes
6. **Lightweight** — 2 agents, SQLite, no heavy framework
7. **Cost-aware** — track every Codex dispatch
8. **Zero friction** — use SQLite directly, don't ceremony with scripts
