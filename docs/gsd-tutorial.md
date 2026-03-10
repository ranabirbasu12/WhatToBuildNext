# GSD (Get Shit Done) — Tutorial

> A hierarchical project planning and execution system for solo development with Claude Code.
> Version: 1.22.4

---

## Table of Contents

1. [What Is GSD?](#what-is-gsd)
2. [What's Already Running](#whats-already-running)
3. [Quick Start — New Project](#quick-start--new-project)
4. [Quick Start — Existing Project](#quick-start--existing-project)
5. [The Full Workflow](#the-full-workflow)
6. [Quick Tasks (Ad-Hoc Work)](#quick-tasks-ad-hoc-work)
7. [Phase Management](#phase-management)
8. [Milestones](#milestones)
9. [Monitoring & Health](#monitoring--health)
10. [Profiles & Settings](#profiles--settings)
11. [Context Management](#context-management)
12. [Command Reference](#command-reference)
13. [File Structure](#file-structure)
14. [Tips & Best Practices](#tips--best-practices)

---

## What Is GSD?

GSD manages the full lifecycle of a project:

```
Research → Plan → Execute → Verify → Complete
```

It works by:
- Breaking your project into **phases** (foundation, features, polish, etc.)
- Breaking phases into **plans** (concrete task lists)
- Executing plans with **atomic commits** per task
- Tracking everything in **STATE.md** (persistent project memory)
- Verifying work before marking anything complete

You describe what you want. GSD plans it, builds it, and verifies it.

---

## What's Already Running

GSD installs three hooks that are always active:

### 1. Status Line
Your Claude Code status bar shows:
- Current model
- Active task (if any)
- Context usage bar with color coding:
  - Green: < 50% used
  - Yellow: 50–65%
  - Orange: 65–80%
  - Red (blinking): > 80%

### 2. Context Monitor
After every tool use, GSD checks how much context remains:
- **Warning** at 35% remaining — wrap up current work
- **Critical** at 25% remaining — stop immediately

### 3. Update Checker
Checks for new GSD versions at session start. If an update is available, the status line shows `⬆ /gsd:update`.

---

## Quick Start — New Project

Start a brand new project from scratch:

```
/gsd:new-project
```

GSD will walk you through:
1. **Discovery** — asks questions about your vision, goals, constraints
2. **Research** — investigates the domain, stack options, best practices
3. **Requirements** — creates scoped requirements with IDs (REQ-001, REQ-002...)
4. **Roadmap** — generates phased roadmap with goals and success measures

This creates a `.planning/` directory in your project with:
- `PROJECT.md` — vision, requirements, success criteria
- `REQUIREMENTS.md` — scoped requirements
- `ROADMAP.md` — phased plan
- `STATE.md` — project memory (tracks where you are)
- `config.json` — workflow settings

**After setup, plan your first phase:**

```
/gsd:plan-phase 1
```

**Then execute it:**

```
/gsd:execute-phase 1
```

That's the core loop. Plan → execute → verify → next phase.

---

## Quick Start — Existing Project

For a project that already has code (like Quantlab):

```
/gsd:map-codebase
```

This analyzes your existing project and creates:
- `ARCHITECTURE.md` — how the system is structured
- `STACK.md` — languages, frameworks, dependencies
- `STRUCTURE.md` — directory layout and key files
- `CONVENTIONS.md` — coding patterns and style
- `TESTING.md` — test setup and coverage
- `INTEGRATIONS.md` — external services and APIs
- `CONCERNS.md` — tech debt, risks, issues

After mapping, you can plan phases on top of the existing codebase.

---

## The Full Workflow

### Step 1: Discuss (Optional)

Before planning, capture your vision:

```
/gsd:discuss-phase 1
```

This creates `CONTEXT.md` with:
- Your vision for how the phase should work/feel
- **Essentials** — things you care about (these become **locked decisions**)
- **Boundaries** — what NOT to do

Locked decisions are **non-negotiable** — the planner must implement them exactly as you specified.

### Step 2: Research (Optional)

For specialized domains (3D, ML, audio, games):

```
/gsd:research-phase 1
```

Creates `RESEARCH.md` with expert patterns, library comparisons, and pitfalls to avoid.

### Step 3: Preview (Optional)

See what GSD will do before committing:

```
/gsd:list-phase-assumptions 1
```

No files created — just a conversational preview.

### Step 4: Plan

Create the execution plan:

```
/gsd:plan-phase 1
```

This generates `PLAN.md` files — one per logical unit of work. Each plan contains:
- Objective (what and why)
- Context (references to related docs)
- Tasks (concrete, actionable items)
- Verification criteria
- Output spec

**Plans ARE prompts** — the executor agent reads them directly as instructions.

### Step 5: Execute

Run the plan:

```
/gsd:execute-phase 1
```

Or execute a specific plan:

```
/gsd:execute-plan .planning/phases/01-foundation/01-01-PLAN.md
```

The executor:
- Works through tasks one by one
- Creates an **atomic commit** for each task
- Produces `SUMMARY.md` with what was done, challenges, and commits
- Updates `STATE.md`

### Step 6: Verify

Check the work:

```
/gsd:verify-phase 1
```

This reviews all summaries against plans, detects gaps, and flags issues.

For deeper verification:

```
/gsd:verify-work 1
```

### Step 7: Complete

Mark the phase as done:

```
/gsd:complete-phase 1
```

Updates `STATE.md` and `ROADMAP.md`, then move to the next phase.

---

## Quick Tasks (Ad-Hoc Work)

For one-off tasks that don't need full phase ceremony:

```
/gsd:quick "fix the database connection timeout"
```

### Flags

| Flag | Effect |
|------|--------|
| `--discuss` | Lightweight discussion before planning |
| `--full` | Adds plan-checking + verification |
| `--discuss --full` | Both (composable) |

### Examples

```
/gsd:quick "add dark mode toggle"
/gsd:quick "fix login bug" --discuss
/gsd:quick "refactor auth middleware" --full
/gsd:quick "add rate limiting" --discuss --full
```

Quick tasks are tracked in `.planning/quick/QCK-001/`, `.planning/quick/QCK-002/`, etc.

---

## Phase Management

### Add a Phase

```
/gsd:add-phase "API integration layer"
```

Appends a new phase to the roadmap with the next available number.

### Insert a Phase

```
/gsd:insert-phase 2 "Security hardening"
```

Inserts after phase 2, renumbers all subsequent phases.

### Remove a Phase

```
/gsd:remove-phase 3
/gsd:remove-phase 3 --force    # skip confirmation
```

### Plan Gap Closure

If verification found issues:

```
/gsd:plan-milestone-gaps 1
```

Creates plans specifically to address gaps found during verification.

---

## Milestones

Group phases into logical releases:

### Start a Milestone

```
/gsd:new-milestone
```

### Complete a Milestone

```
/gsd:complete-milestone v1.0
/gsd:complete-milestone v1.0 --name "Initial Release"
/gsd:complete-milestone v1.0 --archive-phases    # move phase dirs to milestones/
```

### Audit a Milestone

```
/gsd:audit-milestone
```

Checks all phases in the current milestone for completeness and quality.

### Transition Between Milestones

```
/gsd:transition
```

Merges branches, archives phases, prepares for next milestone.

---

## Monitoring & Health

### Progress

```
/gsd:progress
```

Shows completion percentage, phase breakdown, and execution metrics.

### Health Check

```
/gsd:health
/gsd:health --repair    # auto-fix issues
```

Validates `.planning/` structure, detects missing or orphaned files.

### Debug

```
/gsd:debug
```

Inspects `.planning/` state, validates all references, detects corruption.

### Diagnose Issues

```
/gsd:diagnose-issues
```

Scans for common problems and suggests fixes.

---

## Profiles & Settings

### Profiles

```
/gsd:set-profile interactive    # more control, more questions
/gsd:set-profile standard       # balanced (default)
/gsd:set-profile yolo           # less ceremony, faster execution
```

### Settings

```
/gsd:settings
```

Configure:
- **Granularity** — how detailed plans should be
- **Git strategy** — branching model, commit frequency
- **Agent deployment** — local or remote

---

## Context Management

Claude Code has a finite context window. GSD helps you manage it:

### Watch the Status Line

The context bar tells you how much room you have. When it turns orange/red, start wrapping up.

### Pause Before Running Out

```
/gsd:pause-work
```

Saves your exact position to `STATE.md` — current phase, plan, task, decisions made, blockers.

### Resume Later

In a new session:

```
/gsd:resume-project
```

Loads `STATE.md` and continues from exactly where you left off.

### Add Tests Separately

If context is tight, add tests in a dedicated session:

```
/gsd:add-tests 1
```

Auto-detects your testing conventions and generates test files for the phase.

---

## Command Reference

### Project Setup
| Command | Description |
|---------|-------------|
| `/gsd:new-project` | Initialize new project from scratch |
| `/gsd:map-codebase` | Analyze existing codebase |

### Phase Planning
| Command | Description |
|---------|-------------|
| `/gsd:discuss-phase <N>` | Capture vision before planning |
| `/gsd:research-phase <N>` | Domain research for specialized work |
| `/gsd:list-phase-assumptions <N>` | Preview what GSD will do |
| `/gsd:plan-phase <N>` | Create execution plans |

### Phase Execution
| Command | Description |
|---------|-------------|
| `/gsd:execute-phase <N>` | Execute all plans in phase |
| `/gsd:execute-plan <file>` | Execute specific plan file |

### Phase Verification
| Command | Description |
|---------|-------------|
| `/gsd:validate-phase <N>` | Check phase completeness |
| `/gsd:verify-phase <N>` | Comprehensive verification |
| `/gsd:verify-work <N>` | Post-execution quality check |

### Phase Operations
| Command | Description |
|---------|-------------|
| `/gsd:add-phase <desc>` | Add new phase to roadmap |
| `/gsd:insert-phase <after> <desc>` | Insert phase after specific number |
| `/gsd:remove-phase <N>` | Remove phase, renumber subsequent |
| `/gsd:complete-phase <N>` | Mark phase as done |

### Milestones
| Command | Description |
|---------|-------------|
| `/gsd:new-milestone` | Start new milestone |
| `/gsd:complete-milestone <ver>` | Archive milestone |
| `/gsd:audit-milestone` | Audit current milestone |
| `/gsd:transition` | Transition between milestones |

### Quick Tasks
| Command | Description |
|---------|-------------|
| `/gsd:quick <desc>` | Execute ad-hoc task |
| `/gsd:check-todos` | List pending inline todos |
| `/gsd:add-todo` | Add structured todo |

### Project Health
| Command | Description |
|---------|-------------|
| `/gsd:progress` | Show completion status |
| `/gsd:health` | Check `.planning/` integrity |
| `/gsd:debug` | Debug GSD state |
| `/gsd:diagnose-issues` | Scan for problems |

### Workflow
| Command | Description |
|---------|-------------|
| `/gsd:pause-work` | Save state, pause execution |
| `/gsd:resume-project` | Resume from saved state |
| `/gsd:plan-milestone-gaps <N>` | Plan closure for gaps |

### Config
| Command | Description |
|---------|-------------|
| `/gsd:set-profile <name>` | Change workflow profile |
| `/gsd:settings` | View/modify configuration |
| `/gsd:update` | Update to latest version |
| `/gsd:help` | Show command reference |

---

## File Structure

After running `/gsd:new-project`, your project gets:

```
.planning/
├── config.json                  # Workflow config
├── STATE.md                     # Project memory — where you are, decisions, blockers
├── PROJECT.md                   # Vision, success criteria
├── REQUIREMENTS.md              # Scoped requirements (REQ-001, REQ-002...)
├── ROADMAP.md                   # Phased plan with goals
├── codebase/                    # (brownfield only, from /gsd:map-codebase)
│   ├── ARCHITECTURE.md
│   ├── STACK.md
│   ├── STRUCTURE.md
│   ├── CONVENTIONS.md
│   ├── TESTING.md
│   ├── INTEGRATIONS.md
│   └── CONCERNS.md
├── research/                    # (optional, from /gsd:research-phase)
│   └── ...
├── phases/
│   ├── 01-foundation/
│   │   ├── CONTEXT.md           # Your vision (from /gsd:discuss-phase)
│   │   ├── 01-01-PLAN.md        # Execution plan
│   │   └── 01-01-SUMMARY.md     # Execution result
│   ├── 02-features/
│   │   └── ...
│   └── ...
├── quick/                       # Quick tasks
│   ├── QCK-001/
│   │   ├── PLAN.md
│   │   └── SUMMARY.md
│   └── ...
└── milestones/                  # (after /gsd:complete-milestone)
    └── v1.0-MILESTONE.md
```

### Key Files to Know

| File | Purpose |
|------|---------|
| `STATE.md` | **Most important** — project memory. Tracks position, decisions, blockers. |
| `PLAN.md` | Execution prompt for the executor agent. Tasks + verification criteria. |
| `SUMMARY.md` | What was actually done. Tasks completed, challenges, commits. |
| `CONTEXT.md` | Your locked decisions. Non-negotiable for the planner. |
| `ROADMAP.md` | Big picture — all phases with goals and success measures. |

---

## Tips & Best Practices

### 1. Use `/gsd:discuss-phase` for Important Phases

If you have opinions about how something should work, discuss first. Your decisions get **locked** — the planner can't override them.

### 2. Start with `/gsd:set-profile yolo` for Exploration

Less ceremony, faster iteration. Switch to `interactive` when you need more control.

### 3. Watch the Context Bar

When it turns orange, you're running low. Use `/gsd:pause-work` to save state before you hit the wall.

### 4. Use Quick Tasks for Small Stuff

Don't create a whole phase for a bug fix. `/gsd:quick "fix X"` is designed for this.

### 5. Verify Before Completing

Always run `/gsd:verify-phase` before `/gsd:complete-phase`. Catches gaps early.

### 6. Resume, Don't Restart

If a session ends, start the next one with `/gsd:resume-project` — it loads your exact position from `STATE.md`.

### 7. Keep GSD Updated

```
/gsd:update
```

GSD evolves fast. New features and fixes ship regularly.

### 8. Use `--discuss --full` for Critical Quick Tasks

When a quick task touches important code:

```
/gsd:quick "refactor payment processing" --discuss --full
```

Gets you discussion + plan-checking + verification — full safety net without phase overhead.
