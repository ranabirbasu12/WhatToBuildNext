# Nexus Board — Task Board Management Skill

## Overview

The Nexus task board is the shared source of truth for what needs doing, who's doing it, and what state it's in. This skill teaches you how to manage tasks effectively.

## Creating Tasks

### When to Create Tasks

- When the human describes a goal that requires multiple steps
- When planning a feature implementation
- When breaking down a complex bug fix
- When organizing a code review cycle

### Task Granularity

Each task should be **one agent's work session** — something completable in a single dispatch or focused work period.

Too big: "Build the authentication system"
Right size: "Implement JWT validation middleware"
Too small: "Add an import statement"

### Creating Well-Defined Tasks

```bash
./nexus/scripts/nexus-board.sh add \
  --title "Implement JWT validation middleware" \
  --desc "Create Express middleware at src/middleware/auth.ts that: extracts Bearer token from Authorization header, verifies with jsonwebtoken, attaches decoded user to req.user, returns 401 for invalid/missing tokens. Include tests." \
  --assignee codex \
  --mode worker \
  --priority 1 \
  --depends T001
```

Key fields:
- **title**: Short, imperative, specific
- **desc**: Full spec — what to build, where it goes, acceptance criteria
- **assignee**: `claude` (you handle), `codex` (dispatch), `human` (needs their input)
- **mode**: `worker` (single task), `sub-conductor` (complex, Codex decomposes), `reviewer` (audit)
- **priority**: 1 (highest) to 5 (lowest)
- **depends**: Task IDs that must complete first

## Task Lifecycle

```
pending → in_progress → review → done
                ↓          ↓
             failed    changes_requested → in_progress (retry)
                ↓
           escalated (after 3 retries)
```

### Status Transitions

| From | To | When |
|---|---|---|
| pending | in_progress | Agent starts working on it |
| in_progress | review | Implementation complete, needs review |
| in_progress | failed | Implementation failed |
| review | done | Review approved |
| review | in_progress | Review requested changes (retry) |
| failed | in_progress | Retrying (if retryCount < 3) |
| failed | escalated | retryCount >= 3, needs human |

### Updating Status

```bash
# Start work
./nexus/scripts/nexus-board.sh update --id T001 --status in_progress

# Move to review
./nexus/scripts/nexus-board.sh update --id T001 --status review

# Mark done with review info
./nexus/scripts/nexus-board.sh update --id T001 --status done --reviewed-by codex --review-status approved

# Record a retry
./nexus/scripts/nexus-board.sh update --id T001 --retry
./nexus/scripts/nexus-board.sh update --id T001 --status in_progress --note "Retry: fixing missing null check"

# Escalate
./nexus/scripts/nexus-board.sh update --id T001 --status escalated --note "3 retries exhausted. Core issue: [description]"
```

## Presenting the Board

### Quick Summary

```bash
./nexus/scripts/nexus-board.sh summary
```

Show this to the human at milestones or when they ask "what's the status?"

### Verbal Summary

When updating the human, be concise:

> "Board update: 5 tasks total. 2 done (auth middleware, user model). 2 in progress — I'm working on the API routes, Codex is writing tests. 1 pending (deployment config, blocked on API routes). No issues."

## Dependency Management

Tasks can depend on other tasks:

```bash
# T002 depends on T001
./nexus/scripts/nexus-board.sh add --title "Write auth tests" --depends T001 --assignee codex
```

Before dispatching a task, check its dependencies:
```bash
./nexus/scripts/nexus-board.sh show --id T002
# Check that all tasks in "dependencies" array have status "done"
```

**Never dispatch a task whose dependencies aren't done.**

## Board Hygiene

- Don't create tasks for trivial work (single-line fixes, typos)
- Clean up failed tasks — either retry or escalate, don't leave them rotting
- Add notes to tasks as work progresses — future context for retries
- Update the board before showing status to the human
