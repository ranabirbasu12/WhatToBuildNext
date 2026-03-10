# How to Use This Template

> This is the instruction manual for starting a new idea in the monorepo.
> Copy this entire `_template/` directory, rename it, and fill in the blanks.

## Quick Start

```bash
# From the repo root
cp -r ideas/_template ideas/my-new-idea
cd ideas/my-new-idea

# Update package.json
# Change @ideas/IDEA_NAME to @ideas/my-new-idea
# Change ONE_LINE_DESCRIPTION to your actual description

# Update README.md
# Replace all IDEA_NAME and ONE_LINE_DESCRIPTION placeholders

# Start sparring
# Open docs/brainstorm.md and start writing
```

## The Idea Lifecycle

```
SPARRING ──→ DESIGNING ──→ BUILDING ──→ BATTLE-TESTING ──→ SHIPPING
    │             │            │              │                 │
    │             │            │              │                 └─ It's live
    │             │            │              └─ Use it for real
    │             │            └─ Write code
    │             └─ Architecture, data model, API
    └─ Brainstorm, validate, kill bad ideas fast

    At any point:
    ──→ PAUSED (we'll come back)
    ──→ ARCHIVED (keep for reference)
    ──→ KILLED (write postmortem, move on)
```

## What to Fill In and When

### During SPARRING (exploring the idea)

| File | Purpose | Priority |
|------|---------|----------|
| `README.md` | Problem, idea, risks, prior art | Do first |
| `docs/brainstorm.md` | Raw session notes | During conversations |
| `docs/user-research.md` | Who needs this? Validation | Before committing to build |
| `docs/competitive-analysis.md` | What exists? Where are gaps? | Before committing to build |

### During DESIGNING (architecture)

| File | Purpose | Priority |
|------|---------|----------|
| `docs/design.md` | Architecture, data model, APIs | Before writing code |
| `docs/decisions.md` | Log every significant choice | Ongoing |
| `README.md` | Update tech stack and key decisions | After major decisions |

### During BUILDING (implementation)

| File | Purpose | Priority |
|------|---------|----------|
| `src/` | Source code | The actual work |
| `tests/` | Tests | Alongside code |
| `scripts/` | Automation | As needed |
| `.planning/` | GSD/Metaswarm planning files | If using plugins |
| `docs/decisions.md` | Keep logging decisions | Ongoing |
| `docs/learnings.md` | Technical discoveries | When you learn something |

### When ENDING (paused, archived, or killed)

| File | Purpose | Priority |
|------|---------|----------|
| `docs/postmortem.md` | Honest reflection | Always write this |
| `docs/learnings.md` | What carries forward | Always update this |
| `README.md` | Update status | Update the status badge |

## Directory Structure

```
ideas/my-new-idea/
├── package.json               # Turborepo workspace package
├── README.md                  # The idea's homepage — problem, solution, status
├── TEMPLATE_GUIDE.md          # This file (delete after setup)
│
├── docs/                      # All thinking and documentation
│   ├── brainstorm.md          # Raw sparring session notes
│   ├── design.md              # Architecture and technical design
│   ├── decisions.md           # Decision log with rationale
│   ├── learnings.md           # What we learned (most valuable artifact)
│   ├── competitive-analysis.md # What exists, where are the gaps
│   ├── user-research.md       # Who needs this, validation results
│   └── postmortem.md          # Fill when idea ends (pause/archive/kill)
│
├── src/                       # Source code
│   └── README.md              # Common structures by project type
│
├── tests/                     # Tests
│   └── README.md              # Testing conventions and guidelines
│
├── scripts/                   # Automation scripts
│   └── README.md              # Common scripts and guidelines
│
└── .planning/                 # GSD / Metaswarm planning files
    └── README.md              # How to use planning plugins here
```

## Tips

### 1. Kill fast, learn always

Most ideas should die in SPARRING. That's fine. The learnings carry forward. Always write `docs/postmortem.md` and `docs/learnings.md` — even for killed ideas.

### 2. The docs/ folder is the real product

Code can be rewritten. Knowledge can't. The brainstorm notes, decisions, and learnings are worth more than the implementation.

### 3. Don't over-template

Not every idea needs every file. A weekend hack might only need `README.md` and `docs/brainstorm.md`. A serious project might use all of them. Use what helps, skip what doesn't.

### 4. Keep README.md as the source of truth

If someone (including future Claude) opens this idea, the README should tell them everything they need to know in 60 seconds: what it is, what state it's in, and where to look next.

### 5. Decisions are sacred

Every time you think "let's just go with X" — write it in `docs/decisions.md`. Future you will thank you when you can't remember why you chose Postgres over SQLite.

### 6. Learnings compound

The `docs/learnings.md` from a killed idea might be the most useful thing in the entire monorepo. Patterns, tools, domain knowledge — they all transfer.
