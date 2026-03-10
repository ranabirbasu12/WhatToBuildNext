# .planning/

GSD and Metaswarm planning files go here. Created automatically by:

```
/gsd:new-project        # Creates PROJECT.md, REQUIREMENTS.md, ROADMAP.md, STATE.md
/gsd:map-codebase       # Creates codebase/ analysis docs
/metaswarm:setup        # Creates coverage config, BEADS tracking
```

## If Using GSD

```
.planning/
├── config.json
├── STATE.md
├── PROJECT.md
├── REQUIREMENTS.md
├── ROADMAP.md
├── phases/
│   ├── 01-foundation/
│   │   ├── 01-01-PLAN.md
│   │   └── 01-01-SUMMARY.md
│   └── ...
└── quick/
    └── QCK-001/
```

## If Using Metaswarm

```
.beads/
├── tasks.db
├── knowledge/
│   ├── patterns.jsonl
│   ├── gotchas.jsonl
│   └── decisions.jsonl
├── plans/
│   └── active-plan.md
└── context/
    ├── project-context.md
    └── execution-state.md
```

## If Using Both

GSD for the macro (roadmap, phases), metaswarm for the micro (quality-gated execution):

```
/gsd:new-project                          # Plan the project
/gsd:plan-phase 1                         # Create phase plan
/metaswarm:start-task <phase 1 goals>     # Quality-gated execution
/gsd:complete-phase 1                     # Mark done
```

See `docs/gsd-vs-metaswarm.md` in the repo root for a full comparison.
