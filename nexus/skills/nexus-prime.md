# Nexus Prime — Context Priming Skill

## Overview

Before any work begins — whether handled by Claude or dispatched to Codex — the agent must be primed with relevant context. This skill defines how to load, maintain, and update the shared context system.

## Before Starting Work

### Load Context

Every task should start with:

```bash
# 1. Read current project state
cat nexus/context/project-state.md

# 2. Read conventions
cat nexus/context/conventions.md

# 3. Load relevant knowledge (now from SQLite, filters expired entries)
./nexus/scripts/nexus-knowledge.sh prime --tags "relevant,tags"

# 4. Check the task board for context
./nexus/scripts/nexus-board.sh show --id T001
```

For Codex dispatches, `nexus-dispatch.sh` handles context injection automatically. For Claude's own work, read these files directly.

### Choosing Knowledge Tags

Match tags to the task domain:
- Working on auth? → `--tags "auth,jwt,security"`
- Working on database? → `--tags "db,schema,migration"`
- Working on frontend? → `--tags "ui,react,css"`
- General work? → Omit tags to get all entries (up to --max limit)

## Maintaining Project State

### When to Update `project-state.md`

Update at **milestones**, not after every small change:
- New service or module added
- Architecture decision made
- Major feature completed
- Significant bug discovered
- Tech debt identified

### What Goes In `project-state.md`

```markdown
# Project Name — Project State

## Architecture
[High-level description of the system]

## Services
[List of services/modules and what they do]

## Recent Decisions
[Date: decision and rationale]

## Known Issues
[Current bugs, tech debt, risks]
```

Keep it concise — this gets injected into every Codex prompt, so every byte counts.

## Maintaining the Knowledge Base

### When to Add Entries

After completing any task, ask: "Did we learn something reusable?"

Add entries for:
- **Gotchas**: Surprising behavior, hidden requirements, things that tripped us up
- **Patterns**: Successful approaches worth repeating
- **Decisions**: Why we chose X over Y (prevents re-debating)
- **Anti-patterns**: Things we tried that didn't work (prevents repeating mistakes)

### Entry Quality

Good entry:
```bash
./nexus/scripts/nexus-knowledge.sh add \
  --type gotcha \
  --fact "Express middleware order matters: auth must come before rate-limiting or rate limits apply to unauthenticated requests" \
  --rec "Always order middleware: cors → auth → rate-limit → routes" \
  --confidence high \
  --tags "express,middleware,auth" \
  --files "src/app.ts"
```

Bad entry:
```bash
# Too vague, no actionable recommendation
./nexus/scripts/nexus-knowledge.sh add \
  --type pattern \
  --fact "Be careful with middleware"
```

### Knowledge Hygiene

Periodically review the knowledge base:
```bash
./nexus/scripts/nexus-knowledge.sh stats
```

If entries become outdated or wrong, the knowledge.jsonl file can be edited directly (it's just newline-delimited JSON).

### Knowledge Expiry

Knowledge entries expire after 90 days by default. To clean up expired entries:

```bash
./nexus/scripts/nexus-knowledge.sh expire
```

To check what's expiring soon, use the reflect retro command which shows entries expiring within 7 days.

## Maintaining Conventions

### When to Update `conventions.md`

- When the team establishes a new convention
- When a convention proves problematic and needs changing
- When a new technology is adopted

### Keep It Actionable

Every convention should be something an agent can follow without ambiguity:
- "Use camelCase for variables" (clear)
- "Write clean code" (not actionable)

## Context Size Awareness

Everything in `nexus/context/` gets injected into Codex prompts. Be mindful of size:
- `project-state.md`: Keep under 500 words
- `conventions.md`: Keep under 300 words
- `knowledge.jsonl`: The prime command limits output (default 20 entries)

If context grows too large, prune aggressively. Stale information is worse than no information.
