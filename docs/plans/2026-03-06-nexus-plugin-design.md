# Nexus Plugin Design — Portable Multi-Agent Orchestration

## Problem

Nexus v0.3 works but is trapped in the `WhatToBuildNext?` repo. Shell scripts and hardcoded paths mean you can't use Nexus from another project. The goal: `cd ~/GitHub/quantlab && /nexus-setup` and Nexus just works there.

## Solution

Package Nexus as a Claude Code plugin distributed via GitHub. Hybrid data model: project-local DB for tasks/dispatches, global DB for cross-project knowledge. Hooks handle automation. Slash commands provide the interface.

## Architecture

### Plugin Layout

```
nexus-plugin/                        # GitHub repo: ranabirbasu12/nexus-plugin
├── .claude-plugin/
│   └── plugin.json                  # Manifest: name, version, description, author
├── skills/
│   ├── orchestrate/SKILL.md         # Core workflow: routing, knowledge queries, natural flow
│   ├── review/SKILL.md              # Codex adversarial review patterns
│   ├── reflect/SKILL.md             # Passive knowledge capture & retro
│   └── setup/SKILL.md               # Project init: create .nexus/, detect stack
├── commands/
│   ├── nexus.md                     # /nexus — main entry (board summary + recent knowledge)
│   ├── nexus-setup.md               # /nexus-setup — init project
│   ├── nexus-board.md               # /nexus-board — show task board
│   ├── nexus-review.md              # /nexus-review — dispatch Codex review
│   └── nexus-retro.md               # /nexus-retro — session retrospective + promote
├── agents/
│   └── codex-reviewer.md            # Custom agent type for adversarial review
├── hooks/
│   ├── hooks.json                   # SessionStart + PostToolUse registration
│   ├── run-hook.cmd                 # Cross-platform wrapper
│   ├── session-start                # Surfaces board + expiring knowledge
│   └── post-commit                  # Passive knowledge capture prompt
├── lib/
│   ├── nexus-db.sh                  # DB init, migrate, query helpers
│   ├── nexus-dispatch.sh            # Codex dispatch with context injection
│   ├── schema.sql                   # SQLite schema (same as v0.2)
│   └── helpers.sh                   # Shared functions: find_project_root, sql_escape, etc.
├── LICENSE
└── README.md
```

### Data Layout (Hybrid Model)

**Per-project** (created by `/nexus-setup`):
```
<project-root>/
├── .nexus/
│   ├── nexus.db              # Tasks, dispatches, events, local knowledge
│   ├── conventions.md        # Project-specific code conventions
│   └── project-state.md      # Living architecture doc
```

**Global** (created on first use):
```
~/.nexus/
├── global.db                 # Promoted knowledge, user prefs, global patterns
└── config.json               # Codex model, dispatch settings, routing rules
```

Both databases use the same SQLite schema from v0.2. The `knowledge` table in `global.db` adds one column: `project TEXT` to track where a pattern originated.

**Resolution order for knowledge queries:**
1. Local `.nexus/nexus.db` (project-specific)
2. Global `~/.nexus/global.db` (cross-project)
3. Merged, deduped, sorted by confidence then recency

**Promotion flow:**
1. Knowledge enters local DB via post-commit hook
2. At session end (`/nexus-retro`), Claude suggests promotion candidates
3. Promoted entries copied to `global.db` with `project` tag
4. Local entry remains (still useful for project queries)

### Hooks

**`hooks.json`:**
```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|resume|clear|compact",
        "hooks": [{
          "type": "command",
          "command": "'${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd' session-start",
          "async": false
        }]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{
          "type": "command",
          "command": "'${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd' post-commit",
          "timeout": 5000
        }]
      }
    ]
  }
}
```

**`session-start` hook:**
1. Detect `.nexus/` in current directory (walk up to project root)
2. If absent → "Run /nexus-setup to enable Nexus for this project"
3. If present → query local DB for pending tasks, query global DB for expiring knowledge
4. Output combined dashboard as `additionalContext`

**`post-commit` hook:**
1. Check if `$TOOL_INPUT` contains `git commit`
2. Check if `.nexus/nexus.db` exists
3. Output `[NEXUS KNOWLEDGE CAPTURE]` prompt with commit info and DB path
4. Claude decides to write entry or skip

### Commands

**`/nexus-setup`** — Project initialization:
1. Check if `.nexus/` exists (offer re-init or skip)
2. Create `.nexus/` directory
3. Init SQLite DB from `schema.sql`
4. Detect project stack (language, framework, test runner)
5. Create starter `conventions.md` and `project-state.md`
6. Create `~/.nexus/global.db` and `~/.nexus/config.json` if missing
7. Add `.nexus/nexus.db` to `.gitignore`
8. Optionally commit `.nexus/conventions.md` and `.nexus/project-state.md`

**`/nexus`** — Main entry:
- Show board summary + recent knowledge from local DB

**`/nexus-board`** — Task board:
- Show pending/in-progress tasks from local DB

**`/nexus-review`** — Codex adversarial review:
- Takes optional scope argument
- Runs dispatch script from `lib/`
- Logs to local DB

**`/nexus-retro`** — Session retrospective:
- Tasks completed, dispatches, knowledge added
- Suggest knowledge promotion to global
- Prompt MEMORY.md update

### Skills

Skills teach Claude *how to think* when Nexus is active:

- **orchestrate** — Routing matrix (Claude builds, Codex reviews), direct SQLite patterns, natural workflow
- **review** — When/how to dispatch Codex, review templates, triage findings
- **reflect** — Post-commit prompt handling, good vs bad knowledge entries, promotion rules
- **setup** — Project detection, init flow, migration from v0.3

### Codex Integration

**`agents/codex-reviewer.md`** — Custom agent type:
- Adversarial review specialization
- Three templates: post-feature, security audit, architecture review
- Context-injects from local conventions + global knowledge

**`lib/nexus-dispatch.sh`** — Portable dispatch:
- Finds DB at `.nexus/nexus.db` (not hardcoded)
- Reads config from `~/.nexus/config.json`
- Injects context from `.nexus/conventions.md`, `.nexus/project-state.md`, both knowledge DBs
- Shell fallback for Codex execution
- Logs to local DB

### Installation

**GitHub repo:** `ranabirbasu12/nexus-plugin`

**Registration in `~/.claude/settings.json`:**
```json
{
  "extraKnownMarketplaces": {
    "nexus-marketplace": {
      "source": {
        "source": "github",
        "repo": "ranabirbasu12/nexus-plugin"
      }
    }
  },
  "enabledPlugins": {
    "nexus@nexus-marketplace": true
  }
}
```

**Versioning:** Git tags (v0.4, v0.5, etc.)

### Migration from v0.3

The `/nexus-setup` skill detects the old `nexus/nexus.db` layout in `WhatToBuildNext?` and offers to import:
- Copy knowledge entries to local `.nexus/nexus.db`
- Promote cross-project patterns to `~/.nexus/global.db`
- Copy pending tasks (T031, T032) to local DB

## What Stays the Same

- SQLite schema (tasks, knowledge, events, dispatches, usage)
- Design principles (all 8 from v0.3)
- Codex as adversarial reviewer (v0.3 role)
- Passive knowledge capture (post-commit hook)
- Direct SQLite as primary interface

## What Changes

| v0.3 | Plugin |
|---|---|
| Hardcoded to `WhatToBuildNext?/nexus/` | Portable: `.nexus/` per project |
| Single DB | Hybrid: local + global |
| Shell scripts as interface | `/nexus-*` slash commands |
| Skills in repo | Skills in plugin (auto-loaded) |
| Manual hook setup in settings.local.json | Plugin hooks.json (auto-registered) |
| No project detection | `/nexus-setup` detects stack |

## Success Criteria

1. `cd ~/GitHub/quantlab && /nexus-setup` creates `.nexus/` and initializes DB
2. Session-start in Quantlab shows its pending tasks automatically
3. Post-commit hook captures knowledge to Quantlab's `.nexus/nexus.db`
4. `/nexus-retro` promotes a pattern to `~/.nexus/global.db`
5. Opening a different project shows global knowledge from Quantlab session
6. Plugin installable via GitHub marketplace registration

## Non-Goals

- GUI or dashboard (terminal only)
- More than 2 agents (Claude + Codex)
- Real-time agent collaboration
- Auto-sync between projects (manual promotion only)
