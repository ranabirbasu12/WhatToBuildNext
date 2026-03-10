# Metaswarm — Tutorial

> Multi-agent orchestration framework for spec-driven, quality-gated software development.
> Version: 0.10.0

---

## Table of Contents

1. [What Is Metaswarm?](#what-is-metaswarm)
2. [Core Concept: The Swarm](#core-concept-the-swarm)
3. [Getting Started](#getting-started)
4. [The Full Workflow](#the-full-workflow)
5. [The 18 Agents](#the-18-agents)
6. [Quality Gates](#quality-gates)
7. [Work Units & Dependency Graphs](#work-units--dependency-graphs)
8. [The 4-Phase Execution Loop](#the-4-phase-execution-loop)
9. [Coverage Enforcement](#coverage-enforcement)
10. [Human Checkpoints](#human-checkpoints)
11. [Knowledge Base](#knowledge-base)
12. [External Tools (Codex & Gemini)](#external-tools-codex--gemini)
13. [PR Shepherd](#pr-shepherd)
14. [Context Recovery](#context-recovery)
15. [Command Reference](#command-reference)
16. [File Structure](#file-structure)
17. [Anti-Patterns (What NOT to Do)](#anti-patterns-what-not-to-do)
18. [Real-World Example](#real-world-example)
19. [Tips & Best Practices](#tips--best-practices)

---

## What Is Metaswarm?

Metaswarm decomposes software tasks into work units, assigns them to specialized AI agents, and enforces independent quality gates at every step. Instead of one agent doing everything, 18 specialists handle research, planning, implementation, review, security, and delivery.

The core principle: **Trust nothing. Verify everything. Review adversarially.**

Every piece of work goes through a 4-phase loop:
1. **Implement** — a coding agent writes tests first (TDD), then implementation
2. **Validate** — the orchestrator independently runs tests, lint, type-check, coverage
3. **Adversarial Review** — a fresh reviewer checks against the spec (binary PASS/FAIL)
4. **Commit** — only after passing all gates

---

## Core Concept: The Swarm

```
                    Issue Orchestrator
                    (coordinates everything)
                           │
          ┌────────────────┼────────────────┐
          │                │                │
     Research          Planning         Execution
          │                │                │
     Researcher       Architect         Coder
                      PM Agent       Test Automator
                      Designer       Code Reviewer
                    Security Design  Security Auditor
                      CTO Agent
                           │
                    Quality Gates
                    (blocking, not advisory)
                           │
                      PR Shepherd
                    (CI, reviews, merge)
                           │
                   Knowledge Curator
                   (extract learnings)
```

Every agent is a specialist. The Issue Orchestrator coordinates them, routes work, and enforces gates. No agent self-certifies — an independent party always validates.

---

## Getting Started

### Step 1: Setup

```
/metaswarm:setup
```

This detects your project stack and configures metaswarm:

**Auto-detected** (no questions asked):
- Language (Node.js, Python, Go, Rust, Java, Ruby)
- Framework (Next.js, React, Vue, Express, etc.)
- Package manager (npm, pnpm, yarn, bun)
- Test runner (vitest, jest, pytest, go test, etc.)
- Coverage tool

**You'll be asked**:
- Coverage threshold percentage (default: 100%)
- External tools setup (Codex CLI, Gemini CLI)?
- Pre-commit hooks (Husky)?
- BEADS task tracking?

**Creates**:
- `.coverage-thresholds.json` — coverage enforcement config
- Appends metaswarm section to `CLAUDE.md`
- Command shims for quick access

### Step 2: Prime Knowledge

```
/metaswarm:prime
```

Loads relevant knowledge base entries into context. Useful before starting any work.

### Step 3: Start Work

```
/metaswarm:start-task
```

This is the main entry point. Describe your task and metaswarm handles the rest — research, planning, review gates, execution, PR creation.

---

## The Full Workflow

Metaswarm follows a 9-phase pipeline:

### Phase 1: Research

The **Researcher** agent explores your codebase:
- Finds relevant patterns, conventions, existing code
- Maps architecture and dependencies
- Identifies constraints

### Phase 2: Planning

The **Architect** agent creates an implementation plan:
- Breaks the task into work units with dependencies
- Defines file scopes per work unit
- Sets Definition of Done (DoD) items for each unit

### Phase 3: Plan Review Gate

**3 adversarial reviewers** check the plan in parallel:

| Reviewer | Focus |
|----------|-------|
| Feasibility | Do file paths exist? Are dependencies ordered correctly? Does the approach match the codebase? |
| Completeness | Are all requirements mapped? Are verification steps defined? Edge cases covered? |
| Scope & Alignment | Does it match the user's request? Any scope creep? Complexity proportional? |

**ALL 3 must PASS.** Max 3 iterations, then escalate to you.

### Phase 4: Design Review Gate

**5 specialists** review in parallel:

| Agent | Focus |
|-------|-------|
| Product Manager | Use case clarity, user benefits, scope |
| Architect | Technical architecture, dependencies, patterns |
| Designer | API design, UX/DX, consistency |
| Security Design | Threat modeling (STRIDE), auth/authz, OWASP Top 10 |
| CTO | TDD readiness, codebase alignment |

**ALL 5 must APPROVE.** Max 3 iterations, then escalate.

### Phase 5: Work Unit Decomposition

The plan is broken into work units — each with:
- Unique ID
- Spec and DoD items
- File scope (what files this unit may touch)
- Dependencies (DAG for parallel execution)
- Optional human checkpoint flag

### Phase 6: Orchestrated Execution

Each work unit goes through the [4-phase execution loop](#the-4-phase-execution-loop).

### Phase 7: Final Comprehensive Review

After all units pass individually, a cross-unit integration check catches issues that per-unit reviews can't see.

### Phase 8: PR Creation

GitHub PR created with full context.

### Phase 9: PR Shepherd

Autonomous PR lifecycle management — CI fixes, review responses, thread resolution, merge.

---

## The 18 Agents

### Orchestration

| Agent | Role |
|-------|------|
| **Swarm Coordinator** | Meta-orchestrator for parallel work across worktrees |
| **Issue Orchestrator** | Main coordinator per issue — creates plans, decomposes work, manages workflow |

### Research & Planning

| Agent | Role |
|-------|------|
| **Researcher** | Codebase exploration, pattern discovery |
| **Architect** | Implementation planning, service structure design |
| **Product Manager** | Use case validation, scope verification |
| **Designer** | UX/API design review, developer experience |
| **Security Design** | Threat modeling (STRIDE), auth/authz design |
| **CTO** | TDD readiness review, plan approval |

### Implementation

| Agent | Role |
|-------|------|
| **Coder** | TDD implementation (RED-GREEN-REFACTOR) |
| **Test Automator** | Test generation and coverage enforcement |

### Review

| Agent | Role |
|-------|------|
| **Code Reviewer** | Internal pre-PR review, pattern enforcement |
| **Security Auditor** | Security code review, vulnerability scanning |

### Delivery

| Agent | Role |
|-------|------|
| **PR Shepherd** | PR lifecycle: CI monitoring, review comments, thread resolution, merge |

### Support

| Agent | Role |
|-------|------|
| **Knowledge Curator** | Extracts learnings from PRs and reviews |
| **Metrics Agent** | Analytics and reporting |
| **Slack Coordinator** | Notifications |
| **SRE Agent** | Infrastructure monitoring |
| **Customer Service Agent** | User support triage |

---

## Quality Gates

Gates are **blocking state transitions**, not suggestions. FAIL means retry or escalate — never skip.

### Gate Types

| Gate | When | Who | Protocol |
|------|------|-----|----------|
| **Plan Review** | After planning | 3 adversarial reviewers (parallel) | ALL must PASS, max 3 iterations |
| **Design Review** | After plan review | 5 specialists (parallel) | ALL must APPROVE, max 3 iterations |
| **Validation** | After implementation | Orchestrator (independent) | Runs tsc, eslint, tests, coverage |
| **Adversarial Review** | After validation | Fresh reviewer (no prior context) | Binary PASS/FAIL against DoD items |
| **Coverage** | During validation | Orchestrator | Reads `.coverage-thresholds.json`, blocks on failure |
| **Final Review** | After all units | Orchestrator | Cross-unit integration check |

### Key Rules

- On FAIL, spawn a **fresh** reviewer for re-review (prevents anchoring bias)
- Never pass prior findings to new reviewers — only spec, DoD, and diff
- Max 3 retries per gate, then escalate to human with full failure history
- Coverage gates read from `.coverage-thresholds.json` — no hardcoded values

---

## Work Units & Dependency Graphs

### Work Unit Structure

Each work unit has:

| Field | Description |
|-------|-------------|
| **ID** | Unique identifier (e.g., `bd-wu-001`) |
| **Title** | Human-readable name |
| **Spec** | What to build and why |
| **DoD Items** | Enumerated, verifiable checklist |
| **File Scope** | Files this unit may touch (enforced via `git diff --name-only`) |
| **Dependencies** | Other units that must complete first |
| **Human Checkpoint** | Whether to pause for human review |

### Dependency DAG

Work units form a directed acyclic graph:

```
wu-001 (schema) ───┐
                    ├──→ wu-003 (API endpoints) ───→ wu-005 (integration tests)
wu-002 (utils)  ───┘                                        │
                                                             ▼
wu-004 (UI components)  ──────────────────────────→ wu-006 (e2e tests)
```

- Units at the same depth with no interdependencies run in parallel
- Convergence points for validation/review (don't validate in parallel)
- Sequential commits maintain clean git history

### Pre-Flight Checklist

Before submitting to Design Review Gate, verify:

**Architecture:**
- Data access through service layer (no direct DB calls from routes)
- Single responsibility per work unit (max ~5 files)
- Error handling strategy specified
- No hard-coded config (env vars for external service config)

**Dependencies:**
- Minimal dependencies (only what's actually imported)
- No circular dependencies
- Integration work units exist to wire components
- Parallel work units have no overlapping file scopes

**API Contracts (if applicable):**
- Every HTTP endpoint: method, path, request schema, all response codes
- WebSocket specs: client-to-server AND server-to-client message types
- Protocol details: heartbeat, reconnection, acknowledgments

**Security:**
- Trust boundaries identified
- Input validation specified for every endpoint
- Rate limiting for expensive operations
- Auth/authz requirements documented

**UI/UX (if applicable):**
- User flows documented
- Empty, loading, and error states defined
- Component hierarchy documented
- Integration work units explicitly created

---

## The 4-Phase Execution Loop

For each work unit:

### Phase 1: IMPLEMENT

A **Coder** agent receives:
- The work unit spec and DoD items
- File scope restrictions
- Project Context Document (patterns, completed work, tooling)

The coder writes tests first (TDD: RED-GREEN-REFACTOR), then implementation.

### Phase 2: VALIDATE

The **Orchestrator** independently runs:
- Type checking (`tsc --noEmit`)
- Linting (`eslint`)
- Tests (full test suite)
- Coverage enforcement (reads `.coverage-thresholds.json`)

The orchestrator **never trusts the coder's report** — it runs everything itself.

### Phase 3: ADVERSARIAL REVIEW

A **fresh reviewer** (new instance, no prior context) checks:
- Each DoD item against the actual diff
- File scope compliance (via `git diff --name-only`)
- Provides file:line evidence for each finding

Verdict is binary: **PASS** or **FAIL**. Not suggestions — binary.

### Phase 4: COMMIT

Only after PASS:
- Changes committed with clear message
- Project Context Document updated
- SERVICE-INVENTORY.md updated (if applicable)

On FAIL at any phase:
1. Fix specific issue
2. Re-run from Phase 1 with fresh reviewer
3. Max 3 retries, then escalate with full failure history

---

## Coverage Enforcement

### Configuration

`.coverage-thresholds.json` is the single source of truth:

```json
{
  "thresholds": {
    "lines": 100,
    "branches": 100,
    "functions": 100,
    "statements": 100
  },
  "enforcement": {
    "command": "pnpm test:coverage",
    "blockPRCreation": true,
    "blockTaskCompletion": true
  }
}
```

### Enforcement Points

1. **Phase 2 (VALIDATE)** — runs enforcement command before adversarial review
2. **Coverage Gate** — blocks commit if below threshold
3. **CI Job** — GitHub Actions enforces on every push

### Commands by Test Runner

| Runner | Command |
|--------|---------|
| Vitest (pnpm) | `pnpm vitest run --coverage` |
| Jest (npm) | `npx jest --coverage` |
| Pytest | `pytest --cov --cov-fail-under=<threshold>` |
| Go | `go test -coverprofile=coverage.out ./...` |
| Cargo | `cargo tarpaulin --fail-under <threshold>` |

---

## Human Checkpoints

### When to Set Them

- After database schema changes
- After security-sensitive code modifications
- After first work unit in a new architectural pattern
- Before destructive/irreversible operations
- Before work units depending on external services (need API keys, credentials)
- At natural boundaries you specify

### What a Checkpoint Looks Like

```markdown
## Checkpoint: <name>

### Completed Work Units
| WU | Title | Status | Review |
|----|-------|--------|--------|
| WU-001 | Schema migration | PASS | Adversarial PASS |
| WU-002 | Service layer | PASS | Adversarial PASS |

### Key Decisions Made
- <decision>: <rationale>

### What Comes Next
- WU-003: <description>

### Questions for Human
- <question>

---
**Action required**: Reply to continue, or provide feedback to adjust course.
```

**Do NOT continue past a checkpoint without your response.** This is a gate, not a notification.

---

## Knowledge Base

### How It Works

Metaswarm maintains a JSONL knowledge base that agents reference during work.

### Entry Schema

```json
{
  "id": "unique-identifier",
  "type": "pattern|gotcha|decision|anti-pattern|codebase-fact|api-behavior",
  "fact": "Clear description",
  "recommendation": "What to do about it",
  "confidence": "high|medium|low",
  "tags": ["relevant", "tags"],
  "affectedFiles": ["src/path/to/file.ts"],
  "provenance": [{"source": "human|agent|review", "reference": "PR #123"}],
  "createdAt": "2026-01-01T00:00:00Z"
}
```

### Categories

| File | What It Contains |
|------|-----------------|
| `patterns.jsonl` | Reusable best practices |
| `gotchas.jsonl` | Common pitfalls |
| `decisions.jsonl` | Architectural choices with rationale |
| `anti-patterns.jsonl` | What to avoid |
| `codebase-facts.jsonl` | Code-specific knowledge |
| `api-behaviors.jsonl` | External API quirks |

### Selective Priming

Agents don't load everything — only what's relevant:

```
/metaswarm:prime
```

Filter by files, keywords, or work type to get only the knowledge that matters for the current task.

---

## External Tools (Codex & Gemini)

Metaswarm can delegate to external AI tools for cost savings and cross-model review.

### Architecture

- **Phase 1**: External tool works in isolated git worktree
- **Phase 2**: Orchestrator independently validates
- **Phase 3**: Cross-model review (writer reviewed by different model)
- **Phase 4**: Merge worktree after all phases pass

### Escalation Chain

| Availability | Chain |
|-------------|-------|
| Two tools | A (2 attempts) → B (2 attempts) → Claude (1 attempt) → human |
| One tool | A (2 attempts) → Claude (1 attempt) → human |
| No tools | Pure metaswarm (unchanged behavior) |

### Configuration

`.metaswarm/external-tools.yaml`:
- Per-adapter: enabled, model, timeout, sandbox
- Per-session: default implementer, escalation order
- Budget: per-task and per-session USD circuit breakers

### Health Check

```
/metaswarm:external-tools-health
```

Checks installation, authentication, and reachability for Codex and Gemini.

---

## PR Shepherd

### What It Does

Autonomously manages a PR from creation to merge:

```
/metaswarm:pr-shepherd <pr-number>
```

### State Machine

```
MONITORING → FIXING → HANDLING_REVIEWS → WAITING_FOR_USER → DONE
```

### Auto-Fixes

| Failure | Fix |
|---------|-----|
| Lint failures | Run linter |
| Prettier failures | Run formatter |
| Type errors | Fix types |
| Test failures | Fix with TDD |

### Review Handling

- Categorizes comments (actionable vs out-of-scope)
- Fixes actionable items
- Marks deferred items with rationale + GitHub issue link
- Resolves threads after addressing
- **Phase 7 iteration loop**: checks for new comments after fixes (critical — automated reviewers post within 1-2 minutes of each push)

### Success Criteria

- All CI checks green
- All threads resolved
- PR squash-merged to main

---

## Context Recovery

### What Gets Persisted

| File | Contents |
|------|----------|
| `.beads/plans/active-plan.md` | Reviewed and approved implementation plan |
| `.beads/context/project-context.md` | Tooling, completed work units, patterns |
| `.beads/context/execution-state.md` | Current work unit, phase, retry count |

### Recovery Protocol

If context is lost mid-execution:

1. Check if `.beads/plans/active-plan.md` exists with `status: in-progress`
2. Read the approved plan
3. Reload completed work from project context
4. Find where execution stopped via execution state
5. Prime knowledge for recovery: `/metaswarm:prime`
6. Resume from current work unit and phase

### Cleanup After Completion

After PR is created or plan is abandoned:
- Plan status updated to `completed`
- Execution state archived (not deleted)

---

## Command Reference

### Core Workflow

| Command | Description |
|---------|-------------|
| `/metaswarm:start-task` | Begin tracked work — full orchestration pipeline |
| `/metaswarm:setup` | Interactive project setup — detect stack, configure |
| `/metaswarm:prime` | Load relevant knowledge before work |

### Review & Quality

| Command | Description |
|---------|-------------|
| `/metaswarm:design-review-gate` | Trigger 5-agent design review |
| `/metaswarm:plan-review-gate` | Trigger 3-reviewer plan review |
| `/metaswarm:brainstorming-extension` | Brainstorm with auto design review |

### PR & Delivery

| Command | Description |
|---------|-------------|
| `/metaswarm:pr-shepherd` | Monitor PR through to merge |
| `/metaswarm:handling-pr-comments` | Address PR review feedback systematically |
| `/metaswarm:create-issue` | Create comprehensive GitHub issue |

### External Tools

| Command | Description |
|---------|-------------|
| `/metaswarm:external-tools` | Delegate to Codex/Gemini with cross-model review |

### Introspection

| Command | Description |
|---------|-------------|
| `/metaswarm:self-reflect` | Extract learnings from PR reviews and sessions |
| `/metaswarm:status` | Diagnostic status report |
| `/metaswarm:visual-review` | Screenshot web pages for visual review |

### Execution

| Command | Description |
|---------|-------------|
| `/metaswarm:orchestrated-execution` | 4-phase loop: implement, validate, review, commit |

---

## File Structure

After running `/metaswarm:setup`, your project gets:

```
project/
├── .coverage-thresholds.json     # Coverage enforcement config
├── .beads/                       # Task tracking (if BEADS enabled)
│   ├── tasks.db                  # Task database
│   ├── knowledge/                # Knowledge base (JSONL files)
│   │   ├── patterns.jsonl
│   │   ├── gotchas.jsonl
│   │   ├── decisions.jsonl
│   │   ├── anti-patterns.jsonl
│   │   ├── codebase-facts.jsonl
│   │   └── api-behaviors.jsonl
│   ├── plans/
│   │   └── active-plan.md        # Current approved plan
│   └── context/
│       ├── project-context.md    # Living project context
│       └── execution-state.md    # Current execution position
├── .metaswarm/                   # Metaswarm config (if external tools)
│   └── external-tools.yaml       # Codex/Gemini configuration
└── CLAUDE.md                     # Updated with metaswarm section
```

---

## Anti-Patterns (What NOT to Do)

These are the top mistakes that break metaswarm's quality model:

| # | Don't | Why | Do Instead |
|---|-------|-----|-----------|
| 1 | **Self-certify** — coder says "tests pass", orchestrator believes it | Coders can hallucinate or skip steps | Orchestrator runs validation independently |
| 2 | **Skip adversarial review** — "code looks fine" | Confirmation bias misses spec violations | Always run review against DoD |
| 3 | **Reuse reviewer** — same agent re-reviews after FAIL | Anchoring bias | Spawn fresh reviewer instance |
| 4 | **Pass prior findings to new reviewer** | Creates anchoring bias | Pass only spec, DoD, diff |
| 5 | **Trust file scope claims** — "I only changed in-scope files" | Agents may touch out-of-scope files | Verify with `git diff --name-only` |
| 6 | **Combine phases** — "implement and validate together" | Removes independence | Run each phase distinctly |
| 7 | **Continue past checkpoint without human response** | Defeats checkpoint purpose | Wait for response |
| 8 | **Skip final review** — "all units passed individually" | Misses cross-unit integration issues | Always run final review |
| 9 | **Skip coverage enforcement** — "tests pass, that's enough" | Untested code paths | Run enforcement from `.coverage-thresholds.json` |
| 10 | **Build UI in isolation** — tested but never wired in | Users can't interact with unwired components | Include integration work units |
| 11 | **Proceed without credentials** — build features needing API keys | Runtime failures | Checkpoint before external-service work |
| 12 | **Treat FAIL as advisory** — "it's just a suggestion" | Undermines trust model | Gates are blocking transitions |
| 13 | **Use `--no-verify`** — bypass pre-commit hooks | Skips lint/type/format checks | Fix the underlying issue |
| 14 | **Skip design review after brainstorming** | Unreviewed designs reach implementation | Always run 5-agent review |
| 15 | **Skip plan review gate** | Plans with gaps reach execution | Always run 3-reviewer gate |

---

## Real-World Example

Here's a one-shot build using metaswarm's full pipeline:

```
/metaswarm:start-task Build a collaborative todo list with AI chat.

Tech stack: Node.js + Hono, React + Vite, SQLite, SSE for real-time,
Anthropic Claude SDK, Vitest + 100% coverage.

Definition of Done:
1. Users create/complete/delete todos via UI
2. Todos persist in SQLite
3. Changes sync in real-time across tabs (SSE)
4. AI assistant can read and modify todos
5. AI responses stream in real-time
6. All API endpoints have input validation
7. 100% test coverage on backend services
8. Clean responsive UI (mobile-friendly)

Set human checkpoints after database schema and AI integration.
```

**What happens automatically:**

1. **Researcher** explores your project
2. **Architect** creates implementation plan with work units
3. **Plan Review Gate** — 3 reviewers validate feasibility, completeness, scope
4. **Design Review Gate** — 5 agents review in parallel
5. **Work units decomposed** — DoD items, file scopes, dependency DAG
6. **External dependency check** — asks for API keys (Anthropic)
7. **For each work unit:**
   - Coder implements with TDD
   - Orchestrator validates independently
   - Fresh reviewer checks DoD with file:line evidence
   - Commit after PASS
8. **Human checkpoints** after schema and AI integration
9. **Final review** — cross-unit integration check
10. **PR created and shepherded** to merge

All from one prompt.

---

## Tips & Best Practices

### 1. Always Start with `/metaswarm:setup`

Run this once per project. It creates the coverage config and CLAUDE.md integration that everything else depends on.

### 2. Use `/metaswarm:prime` Before Starting Work

Loads relevant knowledge so agents don't repeat past mistakes.

### 3. Set Human Checkpoints for Risky Work

Database schemas, security code, external service integration — checkpoint these. Better to pause and confirm than to redo.

### 4. Trust the Gates

When a gate says FAIL, it found something real. Don't try to bypass it. Fix the issue and let a fresh reviewer re-evaluate.

### 5. Run `/metaswarm:self-reflect` Before Creating PRs

Extract learnings while implementation context is fresh. Commit knowledge updates as part of the PR.

### 6. Use External Tools for Cost Savings

Codex and Gemini can handle implementation while Claude reviews. Cross-model adversarial review catches more issues than single-model.

### 7. Provide Clear DoD Items

The more specific your Definition of Done, the better the adversarial review. Vague items get vague reviews.

### 8. Keep Work Units Small

Max ~5 files per work unit. Smaller units = faster reviews, cleaner commits, easier rollback.

### 9. Let PR Shepherd Handle the Merge

Don't manually push fixes after CI fails. Let `/metaswarm:pr-shepherd` handle lint, format, type errors, and test failures automatically.

### 10. Check `/metaswarm:status` When Things Feel Off

Runs diagnostics on your metaswarm setup and identifies configuration issues.

---

## GSD vs Metaswarm — When to Use Which

| Aspect | GSD | Metaswarm |
|--------|-----|-----------|
| **Focus** | Project planning & phase management | Quality-gated multi-agent execution |
| **Best for** | Greenfield projects, roadmap planning, phase-by-phase delivery | Rigorous implementation with adversarial review |
| **Agents** | 13 specialized agents | 18 specialized agents |
| **Quality gates** | Verification after execution | Blocking gates at every phase |
| **Coverage** | Not enforced | Enforced via `.coverage-thresholds.json` |
| **External tools** | No | Codex CLI + Gemini CLI delegation |
| **PR management** | No | Full PR shepherd lifecycle |
| **Knowledge base** | STATE.md (narrative) | JSONL knowledge base (structured) |
| **Quick tasks** | `/gsd:quick` | `/metaswarm:start-task` (same pipeline, any size) |
| **Context recovery** | STATE.md + pause/resume | `.beads/` directory with plan + state files |

**Use GSD** when you need to plan a multi-phase project from scratch, manage a roadmap, and execute phase by phase with atomic commits.

**Use metaswarm** when you need rigorous quality enforcement, adversarial review, coverage gates, and autonomous PR management.

**Use both** — GSD for the macro (phases, roadmap, project memory) and metaswarm for the micro (quality-gated execution within each phase).
