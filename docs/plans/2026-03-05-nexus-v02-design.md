# Nexus v0.2 Design — MCP Integration, Self-Improvement Loop, SQLite Backend

## Context

Nexus v0.1 works: 3 successful Codex dispatches, cross-review caught 15 issues, 4/4 tests passing. But the shell-pipe dispatch is brittle, knowledge extraction is manual, and JSON/JSONL state has known issues (ID collision, no locking, no queryable analytics). This design addresses all three.

Codex reviewed the v0.1 architecture and contributed recommendations (dispatch T006). Both agents agree on the direction.

## Pillar 1: MCP Integration

### What Changes

Replace `codex exec` shell pipes with native MCP protocol. Codex CLI has `codex mcp-server` (stdio MCP server) built in.

### Architecture

```
Claude Code
    |
    |-- MCP Protocol (stdio) --> codex mcp-server (gpt-5.3-codex)
    |
    |-- MCP Protocol --> Supabase, Vercel, Playwright (existing)
```

Codex becomes just another MCP server alongside Supabase/Vercel/Playwright. Claude Code calls Codex tools the same way it calls any MCP tool.

### Config Change

```json
{
  "codex": {
    "dispatchBackend": "mcp",
    "fallbackBackend": "shell",
    "model": "gpt-5.3-codex",
    "maxRetries": 3,
    "timeoutSeconds": 300
  }
}
```

### MCP Server Registration

Add to Claude Code's MCP config (`.claude/settings.json` or project-level):

```json
{
  "mcpServers": {
    "codex": {
      "command": "codex",
      "args": ["mcp-server", "-c", "model=\"gpt-5.3-codex\""]
    }
  }
}
```

### New Dispatch Flow

1. Claude Code calls Codex MCP tool with enriched prompt (same context injection as v0.1)
2. Codex MCP server processes the request, executes, returns structured result
3. Claude Code logs the dispatch to SQLite (same fields as v0.1 dispatches.jsonl)
4. No more pipe hacking, timeout gymnastics, or output file parsing

### Fallback

`nexus-dispatch.sh` remains functional. If MCP fails or is unavailable, the orchestration skill falls back to shell dispatch. Config flag controls which backend is primary.

### What We Keep

- Same logging schema (dispatches, usage tracking)
- Same context injection (project state, conventions, knowledge)
- Same dispatch modes (worker, reviewer, sub-conductor)
- Same validation/review workflow

## Pillar 2: Self-Improvement Loop

### The Reflect Stage

After every task completion (by either agent), a mandatory reflection runs:

```
TASK COMPLETE --> REFLECT --> EXTRACT KNOWLEDGE --> UPDATE METRICS --> ADAPT
```

### 2a. Automatic Knowledge Extraction

After each task, the completing agent generates a structured reflection:

```json
{
  "fact": "What was learned",
  "recommendation": "What to do differently",
  "type": "gotcha|pattern|decision|anti-pattern",
  "confidence": "high|medium|low",
  "evidence": "file:line, error text, or test result",
  "tags": ["relevant", "tags"],
  "files": ["affected/files"],
  "sourceTaskId": "T001",
  "outcome": "success|failed|retry",
  "expiresAt": "2026-06-05T00:00:00Z"
}
```

Rules for persisting:
- Must have concrete evidence (not vague observations)
- Must not duplicate existing knowledge (check by fact similarity)
- Confidence must be medium or higher
- Entries expire after 90 days by default (configurable)

### 2b. Failure Taxonomy and Detection

Dispatch logs gain a `failureType` field:

| Type | Trigger |
|---|---|
| `timeout` | Dispatch exceeded time limit |
| `bad_spec` | Task failed due to unclear requirements |
| `env_missing` | Missing tool/dependency in sandbox |
| `test_flake` | Tests pass sometimes, fail sometimes |
| `review_reject` | Reviewer found significant issues |
| `crash` | Non-zero exit with no useful output |

Rolling counters tracked per taxonomy + per task type in SQLite.

### 2c. Adaptation Rules

When patterns emerge, Nexus adapts:

| Pattern | Adaptation |
|---|---|
| `bad_spec` count > 2 in session | Enforce acceptance criteria template before dispatch |
| `timeout` on similar tasks | Auto-split into smaller subtasks, reduce context payload |
| Same file retried 3+ times | Force reviewer mode + human checkpoint |
| `env_missing` repeated | Add to conventions, warn before dispatch |
| Review rejection rate > 50% for a mode | Switch assignee (codex->claude or vice versa) |

### 2d. Session-End Retrospective

At session end (or on demand), generate:
- Top 3 failure modes this session
- Top 3 winning patterns
- Knowledge base changes (added, expired, updated)
- Routing effectiveness (which agent performed better on which task types)
- Update project-state.md with session learnings

## Pillar 3: SQLite Backend

### Why

Solves multiple v0.1 issues simultaneously:
- ID collision (auto-increment primary keys)
- No file locking (SQLite handles concurrency)
- CSV whitespace parsing (proper typed columns)
- No queryable analytics (SQL queries)
- Non-atomic writes (SQLite transactions)

### Schema

```sql
-- Tasks (replaces board/tasks.json)
CREATE TABLE tasks (
  id TEXT PRIMARY KEY,           -- T001, T002, ...
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  assignee TEXT NOT NULL CHECK(assignee IN ('claude','codex','human')),
  priority INTEGER NOT NULL CHECK(priority BETWEEN 1 AND 5),
  status TEXT NOT NULL DEFAULT 'pending'
    CHECK(status IN ('pending','in_progress','review','done','failed','escalated')),
  mode TEXT NOT NULL CHECK(mode IN ('worker','reviewer','sub-conductor')),
  parent_id TEXT REFERENCES tasks(id),
  reviewed_by TEXT CHECK(reviewed_by IN ('claude','codex')),
  review_status TEXT DEFAULT 'pending'
    CHECK(review_status IN ('pending','approved','changes_requested')),
  retry_count INTEGER DEFAULT 0,
  depends TEXT DEFAULT '[]',     -- JSON array of task IDs
  notes TEXT DEFAULT '[]',       -- JSON array of strings
  created_at TEXT NOT NULL,
  completed_at TEXT
);

-- Knowledge base (replaces context/knowledge.jsonl)
CREATE TABLE knowledge (
  id TEXT PRIMARY KEY,           -- k_001, k_002, ...
  type TEXT NOT NULL CHECK(type IN ('gotcha','pattern','decision','anti-pattern')),
  fact TEXT NOT NULL,
  recommendation TEXT DEFAULT '',
  confidence TEXT NOT NULL CHECK(confidence IN ('high','medium','low')),
  source TEXT NOT NULL CHECK(source IN ('claude','codex','human')),
  tags TEXT DEFAULT '[]',        -- JSON array
  files TEXT DEFAULT '[]',       -- JSON array
  source_task_id TEXT,
  outcome TEXT CHECK(outcome IN ('success','failed','retry')),
  expires_at TEXT,
  created_at TEXT NOT NULL
);

-- Event log (new - drives analytics and self-improvement)
CREATE TABLE events (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  timestamp TEXT NOT NULL,
  event_type TEXT NOT NULL,      -- task_created, dispatched, reviewed, retried, escalated, knowledge_added, etc.
  task_id TEXT,
  agent TEXT,                    -- claude, codex, human
  payload TEXT DEFAULT '{}'      -- JSON blob for event-specific data
);

-- Dispatches (replaces logs/dispatches.jsonl)
CREATE TABLE dispatches (
  id TEXT PRIMARY KEY,
  timestamp TEXT NOT NULL,
  task_id TEXT NOT NULL,
  mode TEXT NOT NULL,
  model TEXT NOT NULL,
  backend TEXT NOT NULL DEFAULT 'shell', -- shell or mcp
  prompt_summary TEXT,
  duration_seconds INTEGER,
  exit_code INTEGER,
  failure_type TEXT,             -- NEW: timeout, bad_spec, env_missing, etc.
  files_changed TEXT DEFAULT '[]',
  validated INTEGER DEFAULT 0,
  reviewed_by TEXT,
  review_result TEXT
);

-- Usage tracking (replaces logs/usage.json)
CREATE TABLE usage (
  date TEXT PRIMARY KEY,
  dispatches INTEGER DEFAULT 0,
  duration_seconds INTEGER DEFAULT 0
);
```

### Migration

A one-time migration script reads existing JSON/JSONL files and populates SQLite:
- `board/tasks.json` -> `tasks` table
- `context/knowledge.jsonl` -> `knowledge` table
- `logs/dispatches.jsonl` -> `dispatches` table
- `logs/usage.json` -> `usage` table

After migration, JSON/JSONL files are kept as backups but no longer written to.

### Script Changes

All bash scripts (`nexus-board.sh`, `nexus-knowledge.sh`, `nexus-status.sh`) switch from `jq` to `sqlite3` queries. Same CLI interface, different backend.

### File Location

```
nexus/nexus.db          -- Single SQLite database
nexus/board/tasks.json  -- Kept as backup after migration
nexus/context/knowledge.jsonl -- Kept as backup after migration
```

## Implementation Order

1. **SQLite backend** — Foundation everything else builds on
2. **Migrate existing scripts** to use SQLite
3. **Self-improvement loop** — Reflect stage, failure taxonomy, adaptation rules
4. **MCP integration** — Register Codex as MCP server, new dispatch flow
5. **Update skills** — Teach orchestration skill about new capabilities
6. **Tests** — Update test suite for new backend
7. **Session retrospective** — End-of-session summary generation

## What We Explicitly Skip (YAGNI)

- A/B testing prompt variants (not enough volume)
- Daemon/cron-based reflection (session-based instead)
- Semantic similarity dedup for knowledge (simple string matching is fine for now)
- Event sourcing for board state (direct SQLite writes; event log is append-only for analytics)

## Success Criteria

- All v0.1 tests still pass (adapted for SQLite)
- MCP dispatch works end-to-end with fallback to shell
- Knowledge auto-extracted after at least one real task
- Failure taxonomy populated after at least one failure
- Session retrospective generates meaningful summary
- Zero data loss during migration from JSON to SQLite
