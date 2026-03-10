# GSD vs Metaswarm — Detailed Comparison

> Two plugin approaches to AI-assisted software development with Claude Code.

---

## One-Line Summary

- **GSD**: Project manager — plans your roadmap, breaks it into phases, executes sequentially.
- **Metaswarm**: Quality enforcer — decomposes tasks into work units, gates every step with independent reviewers.

---

## Philosophy

| | GSD | Metaswarm |
|---|---|---|
| **Core belief** | Structure drives productivity | Trust nothing, verify everything |
| **Metaphor** | A disciplined solo developer with a detailed plan | A team of specialists with strict QA |
| **Approach** | Plan big, execute phase by phase | Decompose, implement, gate, commit |
| **Who decides quality?** | Verification step after execution | Independent adversarial reviewers at every phase |
| **Failure model** | Fix and re-verify | Retry with fresh reviewer (prevent anchoring bias) |

---

## Architecture

| | GSD | Metaswarm |
|---|---|---|
| **Agent count** | 13 | 18 |
| **Orchestration** | Linear (phase → plan → execute → verify) | DAG-based (parallel work units with dependency graph) |
| **State storage** | Markdown files (STATE.md, PLAN.md, SUMMARY.md) | JSONL knowledge base + SQLite (BEADS) + markdown plans |
| **Project config** | `.planning/config.json` | `.coverage-thresholds.json` + `.metaswarm/` |
| **Directory** | `.planning/` | `.beads/` + `.metaswarm/` |
| **Context recovery** | `STATE.md` (narrative) + `/gsd:pause-work` / `/gsd:resume-project` | `.beads/plans/active-plan.md` + `execution-state.md` (structured) |

---

## Workflow Comparison

### GSD Workflow
```
new-project → discuss-phase → plan-phase → execute-phase → verify-phase → complete-phase
                                                                              │
                                                                         next phase
```

### Metaswarm Workflow
```
start-task → research → plan → plan-review-gate (3 reviewers) → design-review-gate (5 agents)
                                                                          │
                                                          work-unit-decomposition
                                                                          │
                                                    ┌─────────────────────┼─────────────────────┐
                                                    │                     │                     │
                                               wu-001                wu-002                wu-003
                                            (4-phase loop)       (4-phase loop)       (4-phase loop)
                                                    │                     │                     │
                                                    └─────────────────────┼─────────────────────┘
                                                                          │
                                                              final-review → PR → shepherd → merge
```

---

## Quality Enforcement

| Aspect | GSD | Metaswarm |
|--------|-----|-----------|
| **Pre-execution review** | None (optional `/gsd:list-phase-assumptions`) | Plan Review Gate (3 reviewers) + Design Review Gate (5 agents) |
| **During execution** | Executor handles everything | 4-phase loop: implement → validate → adversarial review → commit |
| **Post-execution review** | `/gsd:verify-phase` (single pass) | Final comprehensive review (cross-unit integration) |
| **Coverage enforcement** | Not built in | Blocking gate via `.coverage-thresholds.json` |
| **Reviewer independence** | Same agent verifies | Fresh reviewer instance every time (no anchoring bias) |
| **Gate nature** | Advisory (you can proceed after verify) | Blocking (FAIL = retry or escalate, never skip) |
| **Review verdict** | Narrative (gaps found, suggestions) | Binary PASS/FAIL with file:line evidence |
| **Max retries** | No limit | 3 per gate, then escalate to human |

---

## Agent Comparison

### GSD Agents (13)

| Agent | Role |
|-------|------|
| gsd-planner | Creates PLAN.md from phase goals |
| gsd-executor | Executes tasks, creates SUMMARY.md |
| gsd-verifier | Post-execution quality checks |
| gsd-plan-checker | Reviews plans for correctness |
| gsd-project-researcher | Initial project research |
| gsd-phase-researcher | Domain/ecosystem research |
| gsd-research-synthesizer | Synthesizes across sources |
| gsd-debugger | Failure analysis |
| gsd-codebase-mapper | Maps existing codebases |
| gsd-roadmapper | Creates roadmaps |
| gsd-nyquist-auditor | Plan completeness validation |
| gsd-integration-checker | External dependency checks |
| gsd-plan-checker | Pre-execution plan verification |

### Metaswarm Agents (18)

| Agent | Role |
|-------|------|
| Swarm Coordinator | Meta-orchestrator across worktrees |
| Issue Orchestrator | Main coordinator per issue |
| Researcher | Codebase exploration |
| Architect | Implementation planning |
| Product Manager | Use case validation |
| Designer | UX/API design review |
| Security Design | Threat modeling (STRIDE) |
| CTO | TDD readiness review |
| Coder | TDD implementation |
| Test Automator | Test generation + coverage |
| Code Reviewer | Pre-PR pattern enforcement |
| Security Auditor | Vulnerability scanning |
| PR Shepherd | PR lifecycle management |
| Knowledge Curator | Learning extraction |
| Metrics Agent | Analytics |
| Slack Coordinator | Notifications |
| SRE Agent | Infrastructure monitoring |
| Customer Service Agent | Support triage |

### Key Differences

- **GSD** agents are task-oriented (plan this, execute that, verify this)
- **Metaswarm** agents are role-oriented (I'm the architect, I'm the security reviewer)
- **GSD** has research-focused agents (phase-researcher, research-synthesizer, nyquist-auditor)
- **Metaswarm** has operations agents (SRE, Slack, Metrics, Customer Service)
- **Metaswarm** separates security into two agents (design-time + audit-time)

---

## Project Planning

| Capability | GSD | Metaswarm |
|-----------|-----|-----------|
| **Project initialization** | `/gsd:new-project` (deep questioning → research → requirements → roadmap) | `/metaswarm:setup` (detect stack, configure coverage) |
| **Roadmap creation** | Built-in (ROADMAP.md with phases, goals, success measures) | Not built-in (focuses on task-level execution) |
| **Phase management** | Full lifecycle (add, insert, remove, complete, reorder) | No phase concept (work units within a single task) |
| **Milestones** | Built-in (new, complete, audit, transition, archive) | Not built-in |
| **Brownfield analysis** | `/gsd:map-codebase` (7 analysis documents) | Researcher agent (inline analysis, not persisted as docs) |
| **Vision capture** | `/gsd:discuss-phase` → CONTEXT.md with locked decisions | Brainstorming extension → design review gate |
| **Domain research** | `/gsd:research-phase` → RESEARCH.md | Researcher agent (integrated into workflow) |

**Winner: GSD** — significantly stronger project planning and roadmap management.

---

## Execution

| Capability | GSD | Metaswarm |
|-----------|-----|-----------|
| **Execution model** | Sequential (plan by plan within a phase) | Parallel (DAG-based work units) |
| **Commit granularity** | Atomic per task | Atomic per work unit |
| **TDD enforcement** | Not enforced (executor decides) | Mandatory (RED-GREEN-REFACTOR) |
| **File scope enforcement** | Not enforced | Enforced (verified via `git diff --name-only`) |
| **Independent validation** | Executor self-reports | Orchestrator runs validation independently |
| **Quick tasks** | `/gsd:quick` with `--discuss` and `--full` flags | Same pipeline for all task sizes |
| **External tool delegation** | No | Codex CLI + Gemini CLI with escalation chain |

**Winner: Metaswarm** — more rigorous execution with independent validation and parallel work units.

---

## PR & Delivery

| Capability | GSD | Metaswarm |
|-----------|-----|-----------|
| **PR creation** | Not built-in | Automatic after final review |
| **CI monitoring** | Not built-in | PR Shepherd polls every 60s |
| **Auto-fix CI failures** | Not built-in | Lint, format, type errors, test failures |
| **Review comment handling** | Not built-in | Categorize, fix, mark deferred, resolve threads |
| **Merge** | Not built-in | Squash-merge to main after all checks pass |

**Winner: Metaswarm** — full PR lifecycle management vs none.

---

## Knowledge Management

| Capability | GSD | Metaswarm |
|-----------|-----|-----------|
| **Format** | Narrative markdown (STATE.md) | Structured JSONL (6 category files) |
| **Categories** | Single file (decisions, blockers, progress all mixed) | Separate files: patterns, gotchas, decisions, anti-patterns, codebase-facts, api-behaviors |
| **Capture** | Implicit (STATE.md updated during execution) | Explicit (`/metaswarm:self-reflect` extracts from PRs) |
| **Priming** | `/gsd:resume-project` loads STATE.md | `/metaswarm:prime` with filters (files, keywords, work type) |
| **Queryable** | No (read the whole file) | Yes (filter by tags, files, confidence, type) |

**Winner: Metaswarm** — structured, queryable, categorized knowledge vs narrative state file.

---

## Context Management

| Capability | GSD | Metaswarm |
|-----------|-----|-----------|
| **Context monitoring** | Built-in hooks (WARNING at 35%, CRITICAL at 25%) | No built-in monitoring |
| **Status line** | Model, task, context bar with color coding | No status line |
| **Pause/resume** | `/gsd:pause-work` + `/gsd:resume-project` | `.beads/context/execution-state.md` (auto-persisted) |
| **State persistence** | STATE.md (narrative, human-readable) | Structured files (plan, context, execution state) |

**Winner: GSD** — proactive context monitoring and visual status line.

---

## Configuration & Profiles

| Capability | GSD | Metaswarm |
|-----------|-----|-----------|
| **Profiles** | 3 modes: `interactive`, `standard`, `yolo` | No profiles |
| **Granularity control** | Configurable (how detailed plans should be) | Fixed (always detailed) |
| **Git strategy** | Configurable (branching, commit frequency) | Fixed (atomic commits, squash-merge) |
| **Coverage thresholds** | Not built-in | Configurable per-metric (lines, branches, functions, statements) |
| **External tool budgets** | Not applicable | Per-task and per-session USD circuit breakers |

**Draw** — different configuration strengths.

---

## Command Count

| Category | GSD | Metaswarm |
|----------|-----|-----------|
| Project setup | 2 | 1 |
| Planning | 4 | 0 (integrated into start-task) |
| Execution | 2 | 1 |
| Verification | 3 | 2 (plan + design review gates) |
| Phase/milestone management | 7 | 0 |
| Quick tasks | 3 | 0 |
| PR & delivery | 0 | 3 |
| Knowledge | 0 | 2 |
| Health & debug | 4 | 2 |
| Config | 4 | 1 |
| **Total** | **~29** | **~12** |

GSD has more commands because it manages the full project lifecycle. Metaswarm has fewer because it focuses on task-level orchestration.

---

## Overlap

These capabilities exist in both:

| Capability | GSD Way | Metaswarm Way |
|-----------|---------|---------------|
| **Research** | `/gsd:research-phase` with dedicated researcher agents | Researcher agent during `/metaswarm:start-task` |
| **Planning** | `/gsd:plan-phase` → PLAN.md | Architect agent → work unit decomposition |
| **Execution** | `/gsd:execute-phase` → atomic commits | Orchestrated execution → 4-phase loop |
| **Verification** | `/gsd:verify-phase` / `/gsd:verify-work` | Adversarial review gate (per work unit) + final review |
| **Codebase analysis** | `/gsd:map-codebase` (7 documents) | Researcher agent (inline, not persisted) |
| **Brainstorming** | Not built-in (uses superpowers:brainstorming) | `/metaswarm:brainstorming-extension` → auto design review |

---

## Gaps

### What GSD Has That Metaswarm Doesn't
- Roadmap management (phases, milestones, phase ordering)
- Project initialization ceremony (deep questioning, requirements, roadmap generation)
- Context monitoring hooks (status line, context usage warnings)
- Workflow profiles (yolo/interactive/standard)
- Quick task mode with minimal ceremony
- Phase discussion with locked decisions
- Pause/resume with explicit state save

### What Metaswarm Has That GSD Doesn't
- Adversarial review gates (blocking, not advisory)
- Coverage enforcement (`.coverage-thresholds.json`)
- PR lifecycle management (shepherd, CI fixes, thread resolution, merge)
- External tool delegation (Codex, Gemini)
- Cross-model adversarial review
- Structured knowledge base (JSONL, queryable)
- Security-focused agents (threat modeling + vulnerability scanning)
- DAG-based parallel execution
- File scope enforcement
- Human checkpoints as blocking gates

---

## When to Use Which

### Use GSD When:
- Starting a brand new project from zero
- You need a roadmap with multiple phases and milestones
- You want flexibility in execution rigor (yolo mode for exploration, interactive for precision)
- You're doing many small tasks (`/gsd:quick`)
- You want visual context monitoring (status bar)
- You want to pause and resume across sessions naturally

### Use Metaswarm When:
- You need rigorous quality enforcement (coverage, adversarial review)
- The task involves security-sensitive code
- You want autonomous PR management (CI fixes, review handling, merge)
- You want to delegate to external tools (Codex, Gemini) for cost savings
- You need structured, queryable knowledge capture
- You want independent verification (not self-reported)

### Use Both When:
- **GSD for the macro** — project initialization, roadmap, phases, milestones, context monitoring
- **Metaswarm for the micro** — quality-gated execution within each phase, PR management, knowledge capture

Example combined workflow:
```
/gsd:new-project                          # GSD: plan the project
/gsd:discuss-phase 1                      # GSD: capture your vision
/gsd:plan-phase 1                         # GSD: create phase plan
/metaswarm:start-task <phase 1 goals>     # Metaswarm: quality-gated execution
/metaswarm:self-reflect                   # Metaswarm: extract learnings
/gsd:complete-phase 1                     # GSD: mark phase done
```

---

## Summary Table

| Dimension | GSD | Metaswarm | Winner |
|-----------|-----|-----------|--------|
| Project planning | Full lifecycle | Task-level only | GSD |
| Execution rigor | Moderate | Very high | Metaswarm |
| Quality gates | Advisory | Blocking | Metaswarm |
| Coverage enforcement | No | Yes | Metaswarm |
| PR management | No | Full lifecycle | Metaswarm |
| External tools | No | Codex + Gemini | Metaswarm |
| Knowledge management | Narrative | Structured JSONL | Metaswarm |
| Context monitoring | Built-in hooks | None | GSD |
| Quick tasks | Dedicated mode | Same pipeline | GSD |
| Roadmap/milestones | Full support | None | GSD |
| Security focus | None | 2 dedicated agents | Metaswarm |
| Flexibility | 3 profiles | Fixed rigorous | GSD |
| Learning curve | Moderate | Steep | GSD |
| Command count | ~29 | ~12 | Draw |
