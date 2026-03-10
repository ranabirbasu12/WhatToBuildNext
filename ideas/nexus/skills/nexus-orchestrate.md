# Nexus Orchestrate v0.3 — Frictionless Multi-Agent Workflow

## Overview

You are Claude Code running with Nexus. Codex CLI is available as an adversarial reviewer. This skill teaches you how to work naturally while Nexus captures knowledge, tracks tasks, and surfaces relevant context automatically.

**v0.3 philosophy:** Don't context-switch to use Nexus. Nexus works through you, not alongside you.

## The Golden Rules

1. **Verify, never trust** — independently validate all agent work
2. **Knowledge compounds** — extract learnings after every significant commit
3. **Reflect, don't forget** — the post-commit hook reminds you; follow through
4. **Escalate, don't loop** — 3 retries max, then ask the human
5. **Codex reviews, Claude builds** — use Codex for adversarial review, not grunt work

## Session Start

At conversation start, run:
```bash
./nexus/scripts/nexus-session-start.sh
```

If pending tasks exist, acknowledge them. If knowledge is expiring, decide: promote to `conventions.md` or let expire.

## Routing Decision Matrix (v0.3)

| Signal | Route To | Why |
|---|---|---|
| Any implementation work | **You (Claude)** | You have full tool access, context, subagents |
| Codebase scanning/auditing | **Claude Explore subagents** | Faster, better context than Codex |
| Code review of YOUR work | **Codex Reviewer** | Different model = different perspective |
| Security audit | **Codex Reviewer** | Systematic, adversarial review |
| "What did I miss?" checks | **Codex Reviewer** | Fresh eyes on your changes |
| Design decisions | **Escalate to Human** | Their intuition matters |
| High-risk changes | **You + Codex review** | Build it, then get adversarial review |

### Quick Decision Heuristic

1. Can you do this with your normal tools? → **You handle it**
2. Is this done and needs a second opinion? → **Codex Reviewer**
3. Is this a security/architecture concern? → **Escalate to Human first**

## The Natural Workflow

### BEFORE Starting Work

```bash
# Check for relevant prior knowledge
sqlite3 nexus/nexus.db "SELECT fact, recommendation FROM knowledge WHERE (expires_at IS NULL OR expires_at > datetime('now')) ORDER BY created_at DESC LIMIT 5;"
```

If the work relates to a specific domain, filter by tags:
```bash
sqlite3 nexus/nexus.db "SELECT fact, recommendation FROM knowledge WHERE (expires_at IS NULL OR expires_at > datetime('now')) AND EXISTS (SELECT 1 FROM json_each(tags) WHERE json_each.value IN ('relevant','tag')) LIMIT 10;"
```

### DURING Work

Work normally with your tools (Read, Edit, Write, Agent, Bash). Don't interrupt your flow for Nexus — the post-commit hook handles knowledge capture.

For significant task tracking:
```bash
# Quick task creation (only for multi-step work)
sqlite3 nexus/nexus.db "INSERT INTO tasks (id, title, description, assignee, priority, status, mode, created_at) VALUES ((SELECT printf('T%03d', COALESCE(MAX(CAST(SUBSTR(id,2) AS INTEGER)),0)+1) FROM tasks), 'Title', 'Description', 'claude', 1, 'in_progress', 'worker', datetime('now'));"
```

### AFTER Each Commit

The post-commit hook will prompt you. When you see `[NEXUS KNOWLEDGE CAPTURE]`:
1. If the commit taught something reusable → write the knowledge entry
2. If the commit was trivial → skip

Write knowledge directly via SQLite (faster than the script):
```bash
sqlite3 nexus/nexus.db "INSERT INTO knowledge (id, type, fact, recommendation, confidence, source, tags, files, expires_at, created_at) VALUES ((SELECT printf('k_%03d', COALESCE(MAX(CAST(SUBSTR(id,3) AS INTEGER)),0)+1) FROM knowledge), 'pattern', 'What was learned', 'What to do next time', 'medium', 'claude', '[\"tag1\",\"tag2\"]', '[]', datetime('now', '+90 days'), datetime('now'));"
```

### AFTER Significant Milestones

Send your work to Codex for adversarial review:
```bash
./nexus/scripts/nexus-dispatch.sh \
  --mode reviewer \
  --task-id TXXX \
  --prompt "Review the recent changes (git diff HEAD~N). Find: bugs, security issues, missed edge cases, convention violations. Be critical — find what I missed." \
  --dir /path/to/project
```

Read the output, verify Codex's findings, fix real issues.

## When to Pull the Human In

Always escalate for:
- Architecture decisions
- Security boundaries
- Schema changes
- When you're unsure (trust your judgment)
- Three failures on the same task

## Session End

Before the conversation ends:
```bash
./nexus/scripts/nexus-reflect.sh retro
```

Review the retrospective. If MEMORY.md needs updating, update it. If conventions.md needs a new entry from today's learnings, add it.

## Anti-Patterns to Avoid

- **Don't use shell scripts when SQLite is faster** — `sqlite3 nexus/nexus.db "..."` is zero-friction
- **Don't dispatch worker tasks to Codex** — your Explore subagents are faster and have better context
- **Don't skip the post-commit knowledge prompt** — it's the core of v0.3
- **Don't forget to send significant work to Codex for review** — the adversarial perspective finds real bugs
- **Don't create tasks for every small fix** — only track multi-step work on the board
