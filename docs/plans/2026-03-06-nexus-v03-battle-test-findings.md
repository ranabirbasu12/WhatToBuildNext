# Nexus v0.3 — Battle Test Findings & Design Revision

## What Happened

We battle-tested Nexus on Quantlab (329-file Python quant trading system). Two sessions, ~90 minutes total, 13 commits fixing real infrastructure issues: lazy imports, DB path centralization, shared utility extraction, broken module boundaries.

**The uncomfortable truth: Nexus was barely used during the actual work.**

## What Went Right (v0.1/v0.2 Design)

1. **Design principles held up.** "Verify, never trust" and "knowledge compounds" proved correct — we validated every change independently, and each discovery fed into the next fix.
2. **SQLite schema is solid.** The tasks/knowledge/events/dispatches tables are well-designed. Nothing needs schema changes.
3. **The orchestration skill's routing matrix is correct.** The decision heuristic accurately predicts what Claude should handle vs. Codex.

## What Went Wrong (Actual Usage)

### Problem 1: Nexus tools weren't the path of least resistance

During the infrastructure audit, the natural workflow was:
1. Dispatch parallel Explore agents (Claude's built-in Agent tool)
2. Read results, identify issues
3. Fix with Edit/Write tools
4. Commit with Bash

At no point did the natural flow include:
- `nexus-board.sh add` to create a task
- `nexus-dispatch.sh` to send work to Codex
- `nexus-reflect.sh extract` to log a finding
- `nexus-knowledge.sh add` to persist a pattern

**Why:** The shell scripts require context-switching out of the coding flow. Typing a bash command to log knowledge feels like overhead when you're mid-fix.

### Problem 2: Codex had no role

The Explore agents (Claude subagents) did everything Codex was supposed to do:
- Codebase scanning (3 parallel agents found duplicates, import issues, strategy compliance)
- Pattern detection (found 3 duplicate utilities, 7 hardcoded paths, 2 broken imports)
- Code auditing (found strategy registry gaps, missing exports)

Codex's differentiator was supposed to be cost (cheaper for grunt work) and independence (different model = different perspective). But Claude's subagents are:
- Faster (same session, no shell dispatch overhead)
- Better context (inherit conversation state)
- More capable (full tool access including Glob, Grep, Read)

### Problem 3: Knowledge was lost

We discovered valuable, reusable patterns:
- `__getattr__` lazy loading pattern for Python `__init__.py`
- `try/except ImportError` fallback pattern for optional config imports
- The config.py constant convention (centralized DB paths with env var overrides)
- "Scripts can be self-contained; only core modules need shared utilities"

None of these were persisted to the knowledge base. They exist only in conversation context and auto-memory, which is fragile.

### Problem 4: Task board was invisible

32 tasks from previous Quantlab work exist in SQLite. But during this session, we never checked them. The board wasn't surfaced, so completed tasks from Round 5/6 (T031, T032 still pending) were forgotten.

## Root Cause Analysis

The core issue is **friction at the interface boundary**. Nexus v0.2 has good abstractions (task board, knowledge base, reflect loop) but the interface is bash scripts. Using them requires:

1. Remembering to use them (cognitive overhead)
2. Constructing the right CLI arguments (syntax overhead)
3. Waiting for shell execution (latency overhead)
4. Parsing text output (context-switch overhead)

When Claude Code already has Edit, Read, Bash, Agent tools that are zero-friction, adding shell script calls on top feels like wearing a backpack to run a sprint.

## Proposed v0.3 Changes

### Change 1: Make Nexus a Claude Code Skill (not scripts)

Replace shell scripts with a `/nexus` skill that Claude Code can invoke natively. The skill reads/writes SQLite directly via Bash, but the *decision* to log knowledge or update tasks is baked into the workflow, not bolted on.

The orchestrate skill should include automatic triggers:
- **After every commit**: extract knowledge (what changed, why, what pattern)
- **Before dispatching subagents**: check knowledge base for relevant priors
- **After subagent results**: log findings to knowledge base
- **At session start**: surface pending tasks and recent knowledge

### Change 2: Passive Knowledge Capture

Instead of requiring explicit `nexus-reflect.sh extract` calls, the reflect loop should be:

1. **Hooks-based**: A post-commit hook that prompts Claude to extract a one-line learning
2. **Conversation-mining**: At session end, scan the conversation for patterns/decisions/gotchas and auto-suggest knowledge entries
3. **Promotion rules**: If the same pattern appears 3+ times across sessions, promote to `conventions.md`

### Change 3: Codex as Adversarial Reviewer Only

Stop trying to use Codex as a worker for tasks Claude can do itself. Instead, focus Codex on what it's uniquely good at:

1. **Adversarial code review**: "Here's what I changed. Find what I missed."
2. **Alternative perspective**: "I designed X this way. What would you do differently?"
3. **Security audit**: "Review this for OWASP top 10 issues."

This matches real usage — in v0.1, the most valuable Codex dispatch was T002 (audit all scripts, found 15 issues). The worker dispatches were fine but not better than Claude doing the work directly.

### Change 4: Surface the Board Automatically

At conversation start, if there are pending/in-progress tasks, show them. Don't wait for the human to ask. The CLAUDE.md already loads — add a startup check:

```
## On Session Start
1. Check `nexus/nexus.db` for pending tasks
2. Check knowledge base for entries expiring within 7 days
3. Show brief status if anything needs attention
```

### Change 5: Structured Session Memory

The auto-memory file (`MEMORY.md`) proved more useful than the knowledge base during this session. Consider:
- Using MEMORY.md as the *primary* knowledge interface for Claude
- Using SQLite knowledge table as the *queryable archive*
- Sync between them: new MEMORY.md entries get written to SQLite for search/analytics

## What to Keep Unchanged

- SQLite schema (well-designed, no changes needed)
- Dispatch script (still useful as Codex shell fallback)
- Design principles (all 7 principles proved correct)
- Config structure (routing rules, model config)
- The reflect loop *concept* (just change the *interface* from scripts to automatic)

## Success Criteria for v0.3

1. A full work session where knowledge is captured automatically (no manual extract calls)
2. Codex dispatched for at least one adversarial review that finds a real issue
3. Pending tasks surfaced at session start without being asked
4. At least 3 knowledge entries created passively during normal coding flow
5. Session retrospective generated automatically at session end

## Non-Goals

- Replacing Claude's Agent tool with Codex for scouting work
- Building a UI/dashboard (terminal-only is fine)
- Supporting more than 2 agents (Claude + Codex is the sweet spot)
- Real-time collaboration between agents (sequential is fine)
