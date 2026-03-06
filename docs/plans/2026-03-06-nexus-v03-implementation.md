# Nexus v0.3 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Transform Nexus from a shell-script-based orchestration system into a frictionless skill-based system with passive knowledge capture, automatic board surfacing, and Codex focused on adversarial review.

**Architecture:** Replace the "remember to call a script" model with automatic triggers baked into CLAUDE.md and Claude Code hooks. Keep SQLite as the backend (schema unchanged). Add a post-commit hook for passive knowledge capture. Rewrite the orchestration skill to embed automatic board/knowledge checks. Narrow Codex's role to adversarial review only.

**Tech Stack:** Bash (hooks, SQLite queries), Markdown (skills, CLAUDE.md), SQLite (existing schema, no changes), Claude Code hooks system (`.claude/settings.local.json`)

**Context:** This builds on v0.2 (8/8 tests passing, SQLite backend). The battle-test on Quantlab revealed that shell scripts create too much friction — see `docs/plans/2026-03-06-nexus-v03-battle-test-findings.md`.

---

## Background for the Implementer

### What Nexus Is
Nexus is a multi-agent orchestration system where Claude Code (you) orchestrates Codex CLI as a coordinated agent swarm. It has:
- A **SQLite database** (`nexus/nexus.db`) with tables: `tasks`, `knowledge`, `events`, `dispatches`, `usage`
- **Shell scripts** in `nexus/scripts/` for task board, knowledge base, dispatch, reflect, status
- **Skills** in `nexus/skills/` that teach Claude how to orchestrate (markdown docs loaded via CLAUDE.md)
- **Config** in `nexus/config.json` for Codex model, routing rules, dispatch backend

### The Problem (v0.2)
During a real battle-test, the shell scripts were never used because they add friction. Claude's built-in tools (Agent, Read, Edit) were faster. Knowledge was lost because nobody remembered to call `nexus-reflect.sh extract`. The task board was invisible.

### The Solution (v0.3)
1. Add a Claude Code hook that fires after every commit → prompts knowledge extraction
2. Rewrite CLAUDE.md to auto-surface board at session start
3. Rewrite the orchestration skill to embed knowledge checks into the natural flow
4. Focus Codex on adversarial review (not worker tasks)
5. Sync MEMORY.md with SQLite knowledge base

### Key Files You'll Touch
- `CLAUDE.md` — Project instructions loaded every session
- `nexus/skills/nexus-orchestrate.md` — Core orchestration skill
- `nexus/skills/nexus-reflect.md` — Self-improvement skill
- `nexus/scripts/nexus-reflect.sh` — Reflect script (keep, add new subcommand)
- `.claude/settings.local.json` — Claude Code hooks and permissions
- `nexus/tests/test-nexus.sh` — Integration tests

### What NOT to Change
- `nexus/schema.sql` — Schema is solid, no changes
- `nexus/nexus.db` — Don't touch the database directly
- `nexus/scripts/nexus-dispatch.sh` — Keep as Codex shell fallback
- `nexus/scripts/nexus-board.sh` — Keep (still useful for CLI access)
- `nexus/scripts/nexus-knowledge.sh` — Keep (still useful for CLI access)
- `nexus/config.json` — Keep current structure
- `.mcp.json` — Keep Codex MCP registration

---

### Task 1: Add Post-Commit Hook for Passive Knowledge Capture

The core v0.3 innovation: after every `git commit`, Claude is prompted to extract a one-line learning. This replaces the manual `nexus-reflect.sh extract` workflow.

**Files:**
- Create: `nexus/hooks/post-commit-knowledge.sh`
- Modify: `.claude/settings.local.json`
- Test: `nexus/tests/test-nexus.sh` (add hook test)

**Step 1: Create the hook script**

Create `nexus/hooks/post-commit-knowledge.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────
# post-commit-knowledge.sh — Passive Knowledge Capture Hook
# Called by Claude Code after every git commit. Outputs a
# prompt reminding Claude to extract knowledge from the commit.
# ─────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NEXUS_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
DB_FILE="${NEXUS_ROOT}/nexus.db"

# Get the last commit info
COMMIT_MSG="$(git log -1 --pretty=%s 2>/dev/null || echo 'unknown')"
COMMIT_FILES="$(git diff --name-only HEAD~1 HEAD 2>/dev/null | head -10 || echo 'unknown')"

# Output the prompt for Claude to see
cat <<EOF
[NEXUS KNOWLEDGE CAPTURE]
Commit: ${COMMIT_MSG}
Files changed: ${COMMIT_FILES}

Extract a one-line learning from this commit. Run:
sqlite3 "${DB_FILE}" "INSERT INTO knowledge (id, type, fact, recommendation, confidence, source, tags, files, expires_at, created_at) VALUES ((SELECT printf('k_%03d', COALESCE(MAX(CAST(SUBSTR(id,3) AS INTEGER)),0)+1) FROM knowledge), 'pattern', '<FACT>', '<RECOMMENDATION>', 'medium', 'claude', '[]', '[]', datetime('now', '+90 days'), datetime('now'));"

If this commit has no reusable learning (e.g., trivial fix, formatting), skip.
EOF
```

**Step 2: Make it executable**

Run: `chmod +x nexus/hooks/post-commit-knowledge.sh`

**Step 3: Register the hook in Claude Code settings**

Read `.claude/settings.local.json`, then edit it to add the hook. The current content has a `permissions` block. Add a `hooks` block:

Edit `.claude/settings.local.json` to add after the `permissions` block:

```json
{
  "permissions": {
    "allow": [
      "Bash(codex:*)",
      "WebSearch",
      "WebFetch(domain:www.perplexity.ai)",
      "WebFetch(domain:www.the-ai-corner.com)",
      "WebFetch(domain:www.thesys.dev)",
      "WebFetch(domain:developers.openai.com)",
      "WebFetch(domain:github.com)",
      "WebFetch(domain:news.ycombinator.com)",
      "Bash(chmod +x:*)",
      "Bash(./nexus/scripts/nexus-dispatch.sh:*)",
      "Bash(./nexus/scripts/nexus-board.sh:*)",
      "Bash(./nexus/scripts/nexus-knowledge.sh:*)",
      "Bash(::*)",
      "Bash(python3:*)",
      "Bash(./nexus/scripts/nexus-status.sh:*)",
      "Bash(mv:*)",
      "Bash(sqlite3:*)"
    ]
  },
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "if echo \"$TOOL_INPUT\" | grep -q 'git commit'; then bash ./nexus/hooks/post-commit-knowledge.sh; fi",
            "timeout": 5000
          }
        ]
      }
    ]
  }
}
```

**Step 4: Test the hook**

Add a test to `nexus/tests/test-nexus.sh`:

```bash
# Test: post-commit hook script exists and is executable
test_post_commit_hook() {
  local hook="nexus/hooks/post-commit-knowledge.sh"
  assert_file_exists "$hook"
  assert_file_executable "$hook"

  # Test it runs without error (won't have git context in test, but should not crash)
  local output
  output=$(bash "$hook" 2>&1) || true
  # Should contain the knowledge capture prompt marker
  echo "$output" | grep -q "NEXUS KNOWLEDGE CAPTURE" || {
    echo "FAIL: Hook output missing NEXUS KNOWLEDGE CAPTURE marker"
    return 1
  }
  echo "PASS: post-commit hook"
}
```

**Step 5: Commit**

```bash
git add nexus/hooks/post-commit-knowledge.sh .claude/settings.local.json nexus/tests/test-nexus.sh
git commit -m "feat(nexus): add post-commit hook for passive knowledge capture"
```

---

### Task 2: Add Session-Start Board Surfacing to CLAUDE.md

Make the task board and expiring knowledge visible automatically when a new conversation starts.

**Files:**
- Modify: `CLAUDE.md`
- Create: `nexus/scripts/nexus-session-start.sh`
- Test: `nexus/tests/test-nexus.sh` (add session-start test)

**Step 1: Create the session-start script**

Create `nexus/scripts/nexus-session-start.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────
# nexus-session-start.sh — Session Start Dashboard
# Shows pending tasks and expiring knowledge at conversation start.
# Designed to be called from CLAUDE.md instructions.
# ─────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NEXUS_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
DB_FILE="${NEXUS_ROOT}/nexus.db"

if [[ ! -f "$DB_FILE" ]]; then
  echo "Nexus DB not found. Run: ./nexus/scripts/nexus-db.sh init"
  exit 0
fi

if ! command -v sqlite3 &>/dev/null; then
  echo "sqlite3 not available."
  exit 0
fi

# ── Pending/In-Progress Tasks ──
PENDING=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM tasks WHERE status IN ('pending', 'in_progress');")
if [[ "$PENDING" -gt 0 ]]; then
  echo "=== Nexus: ${PENDING} Active Tasks ==="
  sqlite3 "$DB_FILE" "SELECT id || ' [' || UPPER(status) || '] (' || assignee || ') ' || title FROM tasks WHERE status IN ('pending', 'in_progress') ORDER BY priority, id;"
  echo ""
fi

# ── Knowledge Expiring Within 7 Days ──
if [[ "$(uname)" == "Darwin" ]]; then
  EXP_DATE=$(date -u -v+7d +"%Y-%m-%dT%H:%M:%SZ")
else
  EXP_DATE=$(date -u -d "+7 days" +"%Y-%m-%dT%H:%M:%SZ")
fi
EXPIRING=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM knowledge WHERE expires_at IS NOT NULL AND expires_at <= '${EXP_DATE}' AND expires_at > datetime('now');")
if [[ "$EXPIRING" -gt 0 ]]; then
  echo "=== Nexus: ${EXPIRING} Knowledge Entries Expiring Soon ==="
  sqlite3 "$DB_FILE" "SELECT id || ' [' || type || '] ' || fact || ' (expires: ' || DATE(expires_at) || ')' FROM knowledge WHERE expires_at IS NOT NULL AND expires_at <= '${EXP_DATE}' AND expires_at > datetime('now') ORDER BY expires_at;"
  echo ""
  echo "Review these entries. Promote valuable ones to conventions.md or renew them."
fi

# ── If nothing needs attention, stay quiet ──
if [[ "$PENDING" -eq 0 && "$EXPIRING" -eq 0 ]]; then
  echo "Nexus: No pending tasks or expiring knowledge. Ready to work."
fi
```

**Step 2: Make it executable**

Run: `chmod +x nexus/scripts/nexus-session-start.sh`

**Step 3: Update CLAUDE.md to add session-start instructions**

Add this section after the "## Design Principles" section in `CLAUDE.md`:

```markdown

## On Session Start

Run this at the start of every conversation:
```bash
./nexus/scripts/nexus-session-start.sh
```

If there are pending tasks, acknowledge them before starting new work. If there are expiring knowledge entries, decide whether to promote (add to `nexus/context/conventions.md`) or let expire.
```

**Step 4: Add test**

Add to `nexus/tests/test-nexus.sh`:

```bash
test_session_start_script() {
  local script="nexus/scripts/nexus-session-start.sh"
  assert_file_exists "$script"
  assert_file_executable "$script"

  # Should run without error and produce output
  local output
  output=$(bash "$script" 2>&1)
  local exit_code=$?
  if [[ $exit_code -ne 0 ]]; then
    echo "FAIL: session-start script exited with code $exit_code"
    return 1
  fi
  echo "PASS: session-start script"
}
```

**Step 5: Commit**

```bash
git add nexus/scripts/nexus-session-start.sh CLAUDE.md nexus/tests/test-nexus.sh
git commit -m "feat(nexus): add session-start board surfacing"
```

---

### Task 3: Rewrite Orchestration Skill for v0.3

Replace the shell-script-heavy orchestration skill with one that embeds knowledge and board checks into the natural Claude Code workflow. The key change: instead of "remember to call scripts", the skill says "do these things as part of your normal work".

**Files:**
- Modify: `nexus/skills/nexus-orchestrate.md`

**Step 1: Rewrite the orchestration skill**

Replace the entire content of `nexus/skills/nexus-orchestrate.md` with:

```markdown
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
```

**Step 2: Commit**

```bash
git add nexus/skills/nexus-orchestrate.md
git commit -m "feat(nexus): rewrite orchestration skill for v0.3 frictionless workflow"
```

---

### Task 4: Rewrite Reflect Skill for v0.3

Update the reflect skill to match the new passive capture model.

**Files:**
- Modify: `nexus/skills/nexus-reflect.md`

**Step 1: Rewrite the reflect skill**

Replace the entire content of `nexus/skills/nexus-reflect.md` with:

```markdown
# Nexus Reflect v0.3 — Passive Self-Improvement

## Overview

Nexus learns from every session. In v0.3, knowledge capture is passive — triggered by hooks and natural workflow, not manual script calls.

## How Knowledge Flows

```
Commit → Post-commit hook → Claude sees prompt → Writes knowledge entry (or skips)
                                                         ↓
Session end → Retro → Review knowledge → Promote patterns to conventions.md
                                                         ↓
Next session → Session-start script → Shows pending tasks + expiring knowledge
```

## The Post-Commit Prompt

After every `git commit`, you'll see a `[NEXUS KNOWLEDGE CAPTURE]` prompt. When you see it:

**Write an entry if:**
- You discovered a reusable pattern (e.g., "Python `__getattr__` lazy loading")
- You fixed a gotcha others would hit (e.g., "DuckDB needs explicit string cast for dates")
- You made a design decision worth recording (e.g., "Chose SQLite over JSON for state")
- You found an anti-pattern to avoid (e.g., "Don't use `Path(__file__).parents[5]` for paths")

**Skip if:**
- The commit is a trivial fix (typo, formatting, version bump)
- The knowledge is already in the database or conventions.md
- The learning is too specific to this exact situation

## Writing Good Knowledge Entries

Good (specific, actionable):
```sql
INSERT INTO knowledge (...) VALUES (..., 'pattern',
  'Python __getattr__ in __init__.py enables lazy loading without breaking existing imports',
  'Use module-path mapping dict + importlib.import_module() for heavy sub-packages',
  'high', 'claude', '["python","imports","performance"]', ...);
```

Bad (vague, not actionable):
```sql
INSERT INTO knowledge (...) VALUES (..., 'pattern',
  'Lazy loading is good',
  '', 'low', 'claude', '[]', ...);
```

## Session Retrospective

At session end, run:
```bash
./nexus/scripts/nexus-reflect.sh retro
```

Then do three things:
1. **Review knowledge created this session** — are entries specific and actionable?
2. **Check for promotion candidates** — if a pattern appeared 3+ times, add to `conventions.md`
3. **Update MEMORY.md** — add session-level learnings (architecture insights, user preferences)

## Knowledge Lifecycle

1. **Created** — via post-commit prompt or manual entry (90-day expiry)
2. **Active** — returned in queries, shown in session-start dashboard
3. **Expiring** — flagged at session start within 7 days of expiry
4. **Promoted** — moved to `conventions.md` (permanent, no expiry)
5. **Expired** — cleaned up via `./nexus/scripts/nexus-knowledge.sh expire`

## Failure Taxonomy (unchanged from v0.2)

| Type | When to Use |
|---|---|
| timeout | Dispatch exceeded time limit |
| bad_spec | Task failed due to unclear requirements |
| env_missing | Missing tool/dependency in sandbox |
| test_flake | Tests pass sometimes, fail sometimes |
| review_reject | Reviewer found significant issues |
| crash | Non-zero exit with no useful output |
```

**Step 2: Commit**

```bash
git add nexus/skills/nexus-reflect.md
git commit -m "feat(nexus): rewrite reflect skill for v0.3 passive capture model"
```

---

### Task 5: Add Codex Adversarial Review Skill

Create a focused skill for the new Codex role: adversarial reviewer only.

**Files:**
- Modify: `nexus/skills/nexus-review.md`

**Step 1: Read the current review skill**

Read `nexus/skills/nexus-review.md` to understand what exists.

**Step 2: Rewrite the review skill**

Replace the content of `nexus/skills/nexus-review.md` with:

```markdown
# Nexus Review v0.3 — Codex as Adversarial Reviewer

## Overview

In v0.3, Codex's sole role is adversarial review. Claude builds, Codex finds what Claude missed. This is Codex's highest-value contribution — the battle test showed worker dispatches weren't better than Claude doing the work directly, but the audit dispatch (T002) found 15 real issues.

## When to Request Codex Review

**Always request review after:**
- Completing a feature or significant refactor (5+ files changed)
- Fixing a security-related bug
- Changing database schema or API contracts
- Any work touching authentication, authorization, or data handling

**Skip review for:**
- Formatting/style-only changes
- Adding comments or documentation
- Single-file, low-risk changes
- Changes already covered by passing tests

## How to Dispatch a Review

```bash
./nexus/scripts/nexus-dispatch.sh \
  --mode reviewer \
  --task-id TXXX-review \
  --prompt "Review the recent changes (git diff HEAD~N). Check for:
1. Bugs and logic errors
2. Security vulnerabilities (OWASP top 10)
3. Edge cases and error handling gaps
4. Convention violations
5. What would you do differently?
Be adversarial — your job is to find what I missed." \
  --dir /path/to/project
```

## Interpreting Review Results

After Codex returns:

1. **Read the output file** from `nexus/logs/output-TXXX-review-*.md`
2. **Triage each finding:**
   - Real issue → fix it, log knowledge entry
   - False positive → note why in the task
   - Style disagreement → follow conventions.md, ignore if not covered
3. **Log the review result:**
```bash
sqlite3 nexus/nexus.db "UPDATE dispatches SET reviewed_by = 'codex', review_result = 'approved' WHERE task_id = 'TXXX-review';"
```

## Three Review Templates

### 1. Post-Feature Review
```
Review git diff HEAD~N. I just implemented [feature]. Find bugs, edge cases, and security issues I missed. Be critical.
```

### 2. Security Audit
```
Security audit of [files/area]. Check for: injection (SQL, command, XSS), authentication bypass, authorization gaps, sensitive data exposure, insecure defaults. Reference OWASP top 10.
```

### 3. Architecture Review
```
I designed [system] using [approach]. Here's the architecture: [summary]. What would you do differently? What assumptions am I making that could bite us later?
```

## Anti-Patterns

- **Don't use Codex as a worker** — Claude's Explore subagents are faster with better context
- **Don't skip review for significant changes** — Codex finds real issues (15 in v0.1 audit)
- **Don't blindly accept all findings** — triage each one, Codex has false positives
- **Don't retry reviews** — if Codex's review is unhelpful, just move on (it's advisory)
```

**Step 3: Commit**

```bash
git add nexus/skills/nexus-review.md
git commit -m "feat(nexus): rewrite review skill — Codex as adversarial reviewer only"
```

---

### Task 6: Update CLAUDE.md for v0.3

The main CLAUDE.md needs to reflect the new v0.3 workflow: direct SQLite access, no script ceremony, Codex as reviewer only, session-start check.

**Files:**
- Modify: `CLAUDE.md`

**Step 1: Rewrite CLAUDE.md**

Replace the entire content of `CLAUDE.md` with:

```markdown
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
```

**Step 2: Commit**

```bash
git add CLAUDE.md
git commit -m "feat(nexus): rewrite CLAUDE.md for v0.3 frictionless workflow"
```

---

### Task 7: Add Memory Sync Script (MEMORY.md ↔ SQLite)

Create a script that syncs MEMORY.md patterns into the SQLite knowledge base, and vice versa.

**Files:**
- Create: `nexus/scripts/nexus-memory-sync.sh`
- Test: `nexus/tests/test-nexus.sh` (add sync test)

**Step 1: Create the sync script**

Create `nexus/scripts/nexus-memory-sync.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────
# nexus-memory-sync.sh — MEMORY.md ↔ SQLite Knowledge Sync
# Exports recent SQLite knowledge entries as a summary that
# can be reviewed for inclusion in MEMORY.md.
# ─────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NEXUS_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
DB_FILE="${NEXUS_ROOT}/nexus.db"

usage() {
  cat <<'EOF'
Usage: nexus-memory-sync.sh <command>

Commands:
  export    Show recent knowledge entries for MEMORY.md review
  stats     Show sync statistics
EOF
  exit 1
}

require_db() {
  if [[ ! -f "$DB_FILE" ]]; then
    echo "Error: nexus.db not found at $DB_FILE" >&2
    exit 1
  fi
}

cmd_export() {
  echo "=== Recent Knowledge (last 7 days) ==="
  echo "Review these for inclusion in MEMORY.md:"
  echo ""

  sqlite3 "$DB_FILE" "SELECT '- [' || type || '] ' || fact || CASE WHEN recommendation != '' THEN ' -> ' || recommendation ELSE '' END FROM knowledge WHERE created_at >= datetime('now', '-7 days') AND (expires_at IS NULL OR expires_at > datetime('now')) ORDER BY created_at DESC;"

  echo ""
  echo "=== High-Confidence Patterns (candidates for conventions.md) ==="
  echo ""

  sqlite3 "$DB_FILE" "SELECT '- ' || fact || ' -> ' || recommendation FROM knowledge WHERE confidence = 'high' AND type = 'pattern' AND (expires_at IS NULL OR expires_at > datetime('now')) ORDER BY created_at DESC LIMIT 10;"
}

cmd_stats() {
  local total recent high_conf
  total=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM knowledge WHERE expires_at IS NULL OR expires_at > datetime('now');")
  recent=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM knowledge WHERE created_at >= datetime('now', '-7 days') AND (expires_at IS NULL OR expires_at > datetime('now'));")
  high_conf=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM knowledge WHERE confidence = 'high' AND (expires_at IS NULL OR expires_at > datetime('now'));")

  echo "Knowledge Base Stats:"
  echo "  Total active:      ${total}"
  echo "  Added last 7 days: ${recent}"
  echo "  High confidence:   ${high_conf}"
}

# ── Main ──
require_db

if [[ $# -lt 1 ]]; then
  usage
fi

case "$1" in
  export) cmd_export ;;
  stats)  cmd_stats ;;
  *)      echo "Unknown command: $1" >&2; usage ;;
esac
```

**Step 2: Make it executable**

Run: `chmod +x nexus/scripts/nexus-memory-sync.sh`

**Step 3: Add test**

Add to `nexus/tests/test-nexus.sh`:

```bash
test_memory_sync_script() {
  local script="nexus/scripts/nexus-memory-sync.sh"
  assert_file_exists "$script"
  assert_file_executable "$script"

  # Test export subcommand
  local output
  output=$(bash "$script" export 2>&1)
  echo "$output" | grep -q "Recent Knowledge" || {
    echo "FAIL: memory-sync export missing header"
    return 1
  }

  # Test stats subcommand
  output=$(bash "$script" stats 2>&1)
  echo "$output" | grep -q "Knowledge Base Stats" || {
    echo "FAIL: memory-sync stats missing header"
    return 1
  }

  echo "PASS: memory-sync script"
}
```

**Step 4: Commit**

```bash
git add nexus/scripts/nexus-memory-sync.sh nexus/tests/test-nexus.sh
git commit -m "feat(nexus): add memory sync script (MEMORY.md <-> SQLite)"
```

---

### Task 8: Update Config for v0.3 Routing

Update the config to reflect the new routing philosophy: Codex is reviewer-only.

**Files:**
- Modify: `nexus/config.json`

**Step 1: Update config.json**

Replace the content of `nexus/config.json` with:

```json
{
  "codex": {
    "dispatchBackend": "mcp",
    "fallbackBackend": "shell",
    "model": "gpt-5.3-codex",
    "defaultMode": "reviewer",
    "fullAuto": true,
    "multiAgent": true,
    "maxRetries": 3,
    "timeoutSeconds": 300
  },
  "routing": {
    "autoDispatchThreshold": "medium",
    "alwaysReview": true,
    "codexRole": "adversarial-reviewer",
    "reviewTriggers": [
      "feature_complete",
      "security_change",
      "schema_change",
      "multi_file_refactor"
    ],
    "humanEscalationTriggers": [
      "architecture_decision",
      "security_boundary",
      "schema_change",
      "agent_disagreement",
      "three_failures"
    ]
  },
  "knowledge": {
    "postCommitCapture": true,
    "sessionStartSurface": true,
    "defaultExpireDays": 90,
    "promotionThreshold": 3
  },
  "tracking": {
    "logDispatches": true,
    "logUsage": true
  }
}
```

**Step 2: Commit**

```bash
git add nexus/config.json
git commit -m "feat(nexus): update config for v0.3 — Codex as reviewer, passive knowledge"
```

---

### Task 9: Update Test Suite for v0.3

Consolidate the test suite to cover all v0.3 components.

**Files:**
- Modify: `nexus/tests/test-nexus.sh`

**Step 1: Read the current test file**

Read `nexus/tests/test-nexus.sh` to understand the existing structure.

**Step 2: Add v0.3 test section**

After the existing tests, add a new section for v0.3 components. Keep all existing tests (they should still pass — we didn't break v0.2 functionality).

Add these test functions (some were specified in Tasks 1, 2, 7 — consolidate them here):

```bash
# ── v0.3 Tests ──────────────────────────────────────────────

test_v03_hook_exists() {
  assert_file_exists "nexus/hooks/post-commit-knowledge.sh"
  if [[ ! -x "nexus/hooks/post-commit-knowledge.sh" ]]; then
    echo "FAIL: post-commit hook not executable"
    return 1
  fi
  echo "PASS: v0.3 post-commit hook exists and is executable"
}

test_v03_session_start() {
  local output
  output=$(bash nexus/scripts/nexus-session-start.sh 2>&1)
  if [[ $? -ne 0 ]]; then
    echo "FAIL: session-start script failed"
    return 1
  fi
  echo "PASS: v0.3 session-start script runs"
}

test_v03_memory_sync() {
  local output
  output=$(bash nexus/scripts/nexus-memory-sync.sh stats 2>&1)
  echo "$output" | grep -q "Knowledge Base Stats" || {
    echo "FAIL: memory-sync stats missing header"
    return 1
  }
  echo "PASS: v0.3 memory-sync script runs"
}

test_v03_config_reviewer_default() {
  local mode
  mode=$(python3 -c "import json; print(json.load(open('nexus/config.json'))['codex']['defaultMode'])")
  if [[ "$mode" != "reviewer" ]]; then
    echo "FAIL: config defaultMode should be 'reviewer', got '$mode'"
    return 1
  fi
  echo "PASS: v0.3 config has reviewer as default mode"
}

test_v03_claude_md_session_start() {
  grep -q "nexus-session-start.sh" CLAUDE.md || {
    echo "FAIL: CLAUDE.md missing session-start reference"
    return 1
  }
  echo "PASS: v0.3 CLAUDE.md references session-start"
}
```

Also update the main test runner at the bottom to include the new tests:

```bash
# Add to the run_all_tests function or main block:
test_v03_hook_exists
test_v03_session_start
test_v03_memory_sync
test_v03_config_reviewer_default
test_v03_claude_md_session_start
```

**Step 3: Run all tests**

Run: `bash nexus/tests/test-nexus.sh`

Expected: All v0.2 tests pass (8/8) plus all v0.3 tests pass (5/5). Total: 13/13.

**Step 4: Commit**

```bash
git add nexus/tests/test-nexus.sh
git commit -m "test(nexus): add v0.3 test coverage — hooks, session-start, memory-sync, config"
```

---

### Task 10: Update Project State Document

Update the living architecture doc to reflect v0.3.

**Files:**
- Modify: `nexus/context/project-state.md`

**Step 1: Read the current project state**

Read `nexus/context/project-state.md`.

**Step 2: Update to reflect v0.3**

Update the document to describe:
- v0.3 architecture (hooks, passive capture, Codex as reviewer)
- What changed from v0.2
- Current status
- Known limitations

The exact content depends on what's currently in the file, but ensure it covers:
- The new hook-based knowledge capture
- Codex's narrowed role
- Session-start board surfacing
- Direct SQLite access pattern

**Step 3: Commit**

```bash
git add nexus/context/project-state.md
git commit -m "docs(nexus): update project-state.md for v0.3 architecture"
```

---

### Task 11: Run Full Integration Test and Tag Release

Final verification and release tagging.

**Files:**
- None new — verification only

**Step 1: Run the full test suite**

Run: `bash nexus/tests/test-nexus.sh`

Expected: All 13 tests pass (8 v0.2 + 5 v0.3).

**Step 2: Verify session-start works**

Run: `bash nexus/scripts/nexus-session-start.sh`

Expected: Shows pending tasks (T031, T032 should be visible) and any expiring knowledge.

**Step 3: Verify hook script works**

Run: `bash nexus/hooks/post-commit-knowledge.sh`

Expected: Outputs the `[NEXUS KNOWLEDGE CAPTURE]` prompt (may show "unknown" for commit info since we're not in a post-commit context).

**Step 4: Verify memory sync works**

Run: `bash nexus/scripts/nexus-memory-sync.sh stats`

Expected: Shows knowledge base statistics.

**Step 5: Verify config is correct**

Run: `python3 -c "import json; c=json.load(open('nexus/config.json')); print(c['codex']['defaultMode'], c['routing']['codexRole'])"`

Expected: `reviewer adversarial-reviewer`

**Step 6: Commit and tag**

```bash
git tag -a v0.3 -m "Nexus v0.3: Frictionless orchestration with passive knowledge capture"
```

---

## Success Criteria (from battle-test findings)

After implementation, verify these in the next work session:

1. Knowledge is captured automatically after commits (no manual extract calls)
2. Codex dispatched for at least one adversarial review that finds a real issue
3. Pending tasks surfaced at session start without being asked
4. At least 3 knowledge entries created passively during normal coding flow
5. Session retrospective generated at session end
