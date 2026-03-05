# Nexus — Multi-Agent Orchestration System

## Design Document

**Date:** 2026-03-05
**Status:** Approved
**Author:** Claude Code + Ranabir Basu

---

## Overview

Nexus is a Claude Code extension that orchestrates Claude Code and OpenAI Codex CLI as a coordinated multi-agent system. You talk to Claude Code. It plans, dispatches, reviews, and integrates — routing work to itself or Codex based on task characteristics. Both agents share a task board, knowledge base, and project context.

Think of it as a local, free alternative to Perplexity Computer — but purpose-built for software engineering with two powerhouse agents instead of 19 models behind an API wall.

## Design Principles

1. **Verify, never trust** — The orchestrator independently validates all agent work
2. **Knowledge compounds** — Every lesson persists in a shared knowledge base; every agent gets primed before work
3. **Escalate, don't loop** — 3 retries max on failure, then escalate to the human
4. **Lightweight by design** — 2 agents, not 18. Simple task board, not a framework
5. **Cost-aware** — Track every Codex dispatch: tokens, time, model used
6. **Invisible integration** — No new CLI to learn. You talk to Claude Code; Nexus is how it thinks

## Architecture

### Agent Hierarchy

```
Human (Captain — steers at design decisions, architectural crossroads, disagreements)
  └─ Claude Code (Conductor / Orchestrator)
       ├─ Claude Subagents (parallel research, exploration, review)
       ├─ Codex as Worker (single well-defined task via codex exec)
       ├─ Codex as Sub-Conductor (complex task; Codex spawns its own sub-agents)
       │    ├─ codex worker agent
       │    ├─ codex explorer agent
       │    └─ codex worker agent
       ├─ Codex as Reviewer (code audit via codex review / codex exec)
       └─ Cross-review loop (Claude reviews Codex's work, Codex reviews Claude's)
```

### Routing Logic — When to Use What

| Task Characteristic | Assigned To | Reasoning |
|---|---|---|
| Architecture, planning, design decisions | Claude Code | Deep reasoning, big-picture thinking |
| Well-defined implementation task | Codex Worker | Fast, cheap, executes specs well |
| Complex multi-file feature (decomposable) | Codex Sub-Conductor | Spawns its own agents, parallel work |
| Code audit / security review | Codex Reviewer | Excellent at systematic audits |
| Multi-tool workflow (DB + deploy + code) | Claude Code | MCP server access (Supabase, Vercel, etc.) |
| Research / codebase exploration | Claude Subagent | Parallel exploration, synthesis |
| Needs human intuition | Escalate to Human | Design choices, "feels wrong" moments |
| High-risk or disagreement | Both agents independently | Compare approaches, present to human |

### Human Involvement Model — "Smart Captain"

- **Routine work:** Claude orchestrates, human gets summary at milestones
- **Design decisions:** Claude presents options with recommendation, human steers
- **Disagreements:** Both agent perspectives shown, human decides
- **Stuck/failing:** Auto-escalate after 3 retries
- **Always available:** Human can look over shoulder and jump in anytime

## System Components

### Layer 0: Context Persistence

The shared memory that prevents agents from starting blind.

```
nexus/context/
├── project-state.md    # Living architecture doc — Claude maintains
├── knowledge.jsonl     # Patterns, gotchas, decisions — both agents contribute
└── conventions.md      # Code style, project rules, preferences
```

**project-state.md** — Updated after every significant change. Contains:
- Current architecture overview
- Service inventory (what exists, what each module does)
- Recent decisions and their rationale
- Known issues and tech debt

**knowledge.jsonl** — Append-only log of learnings:
```json
{
  "id": "k_001",
  "timestamp": "2026-03-05T10:00:00Z",
  "type": "gotcha|pattern|decision|anti-pattern",
  "fact": "Clear description of the learning",
  "recommendation": "What to do about it",
  "confidence": "high|medium|low",
  "source": "claude|codex|human",
  "tags": ["relevant", "tags"],
  "affectedFiles": ["src/path/to/file.ts"]
}
```

**conventions.md** — Injected into every Codex dispatch so it follows project rules.

### Layer 1: Task Board

```
nexus/board/
└── tasks.json
```

Lightweight shared task tracker. Structure:

```json
{
  "tasks": [
    {
      "id": "T001",
      "title": "Implement JWT middleware",
      "description": "Create Express middleware for JWT validation...",
      "status": "pending|in_progress|review|done|failed|escalated",
      "assignee": "claude|codex|human",
      "dispatchMode": "worker|sub-conductor|reviewer",
      "priority": 1,
      "dependencies": ["T000"],
      "parentTask": null,
      "subtasks": ["T001a", "T001b"],
      "reviewedBy": "claude|codex|null",
      "reviewStatus": "pending|approved|changes_requested",
      "retryCount": 0,
      "notes": [],
      "createdAt": "2026-03-05T10:00:00Z",
      "completedAt": null
    }
  ]
}
```

### Layer 2: Dispatch Engine

The core skill that teaches Claude Code how to work with Codex.

**Codex dispatch modes:**

| Mode | Command | Use Case |
|---|---|---|
| Worker | `codex exec "<prompt>" --full-auto -C <dir>` | Single well-defined task |
| Sub-conductor | `codex exec "<prompt>" --full-auto -C <dir>` (with multi_agent enabled) | Complex decomposable task |
| Reviewer | `codex exec "Review this code for: ..." --full-auto -C <dir>` | Code audit |
| Quick review | `codex review` | Git-diff based review |

**Prompt injection pattern for Codex dispatches:**
```
[PROJECT CONTEXT]
{contents of project-state.md}

[CONVENTIONS]
{contents of conventions.md}

[RELEVANT KNOWLEDGE]
{filtered entries from knowledge.jsonl}

[TASK]
{task description from board}

[DELIVERABLES]
{specific expected outputs}
```

### Layer 3: Execution Loop

Every task follows this cycle:

```
PRIME
  Load relevant knowledge entries (filtered by tags/files)
  Load project context
  Load conventions

PLAN
  Claude breaks down the work
  Creates/updates tasks on the board
  Identifies dispatch targets

DISPATCH
  Route to Claude, Codex, or both based on routing logic
  Inject context into Codex prompt
  Log dispatch to dispatches.jsonl

VALIDATE
  Orchestrator independently runs tests/checks
  Never trust agent self-reports
  Compare output against task deliverables

ADVERSARIAL REVIEW
  The OTHER agent reviews the work
  Claude reviews Codex output for architectural coherence
  Codex reviews Claude output for bugs/edge cases

RESOLVE
  If approved → mark done, extract learnings to knowledge base
  If changes needed → retry (max 3)
  If stuck → escalate to human with both perspectives
```

### Layer 4: Usage Tracking

```
nexus/logs/
├── dispatches.jsonl    # Every Codex call logged
└── usage.json          # Aggregated cost/token tracking
```

**dispatches.jsonl entry:**
```json
{
  "id": "d_001",
  "timestamp": "2026-03-05T10:30:00Z",
  "taskId": "T001",
  "mode": "worker",
  "model": "gpt-5.3-codex",
  "prompt_summary": "Implement JWT middleware",
  "duration_seconds": 45,
  "exit_code": 0,
  "files_changed": ["src/middleware/auth.ts"],
  "validated": true,
  "reviewed_by": "claude",
  "review_result": "approved"
}
```

**usage.json:**
```json
{
  "total_dispatches": 42,
  "total_duration_seconds": 1893,
  "by_mode": {
    "worker": 30,
    "sub-conductor": 5,
    "reviewer": 7
  },
  "by_model": {
    "gpt-5.3-codex": 42
  },
  "session_history": [
    { "date": "2026-03-05", "dispatches": 12, "duration": 540 }
  ]
}
```

## File Structure

```
nexus/
├── context/
│   ├── project-state.md
│   ├── knowledge.jsonl
│   └── conventions.md
├── board/
│   └── tasks.json
├── logs/
│   ├── dispatches.jsonl
│   └── usage.json
├── skills/
│   ├── nexus-orchestrate.md   # Core dispatch & routing skill
│   ├── nexus-review.md        # Cross-review workflow skill
│   ├── nexus-prime.md         # Context priming skill
│   └── nexus-board.md         # Task board management skill
├── scripts/
│   └── nexus-status.sh        # Quick terminal view of board + usage
└── config.json                # Routing rules, model preferences, thresholds
```

## Config

```json
{
  "codex": {
    "model": "gpt-5.3-codex",
    "defaultMode": "worker",
    "fullAuto": true,
    "multiAgent": true,
    "maxRetries": 3,
    "timeoutSeconds": 300
  },
  "routing": {
    "autoDispatchThreshold": "medium",
    "alwaysReview": true,
    "humanEscalationTriggers": [
      "architecture_decision",
      "security_boundary",
      "schema_change",
      "agent_disagreement",
      "three_failures"
    ]
  },
  "tracking": {
    "logDispatches": true,
    "logUsage": true
  }
}
```

## What Nexus Is NOT

- Not a web app or GUI — terminal only
- Not a framework others install — it's skills + config for Claude Code
- Not trying to replace either agent — it makes them better together
- Not Perplexity Computer — no cloud dependency, no subscription, runs locally
- Not Metaswarm — no 18 personas, no BEADS dependency, no heavy setup

## Inspirations

- **Perplexity Computer** — Multi-model orchestration with automatic routing
- **Metaswarm** — Execution loop, adversarial review, knowledge base, independent verification
- **Codex Multi-Agent** — Native sub-agent spawning, worktree isolation, role system

## Success Criteria

1. Claude Code can dispatch tasks to Codex and collect results without manual intervention
2. Shared task board is readable and updated by both agents
3. Cross-review catches bugs that single-agent review misses
4. Knowledge base grows and prevents repeat mistakes
5. Human gets pulled in at the right moments — not too much, not too little
6. Usage tracking gives clear visibility into Codex consumption
