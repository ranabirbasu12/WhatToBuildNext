# Nexus Reflect v0.3 — Passive Self-Improvement

## Overview

Nexus learns from every session. In v0.3, knowledge capture is passive — triggered by hooks and natural workflow, not manual script calls.

## How Knowledge Flows

```
Commit → Post-commit hook → Claude sees prompt → Writes knowledge entry (or skips)
                                                         ↓
Session end → Retro → Review knowledge → Promote patterns to conventions.md
                                                         ↓
Next session → Session-start script → Shows pending tasks + expiring knowledge
```

## The Post-Commit Prompt

After every `git commit`, you'll see a `[NEXUS KNOWLEDGE CAPTURE]` prompt. When you see it:

**Write an entry if:**
- You discovered a reusable pattern (e.g., "Python `__getattr__` lazy loading")
- You fixed a gotcha others would hit (e.g., "DuckDB needs explicit string cast for dates")
- You made a design decision worth recording (e.g., "Chose SQLite over JSON for state")
- You found an anti-pattern to avoid (e.g., "Don't use `Path(__file__).parents[5]` for paths")

**Skip if:**
- The commit is a trivial fix (typo, formatting, version bump)
- The knowledge is already in the database or conventions.md
- The learning is too specific to this exact situation

## Writing Good Knowledge Entries

Good (specific, actionable):
```sql
INSERT INTO knowledge (id, type, fact, recommendation, confidence, source, tags, files, expires_at, created_at)
VALUES ((SELECT printf('k_%03d', COALESCE(MAX(CAST(SUBSTR(id,3) AS INTEGER)),0)+1) FROM knowledge),
  'pattern',
  'Python __getattr__ in __init__.py enables lazy loading without breaking existing imports',
  'Use module-path mapping dict + importlib.import_module() for heavy sub-packages',
  'high', 'claude', '["python","imports","performance"]', '[]',
  datetime('now', '+90 days'), datetime('now'));
```

Bad (vague, not actionable):
```sql
-- DON'T DO THIS
INSERT INTO knowledge (...) VALUES (..., 'pattern', 'Lazy loading is good', '', 'low', ...);
```

## Session Retrospective

At session end, run:
```bash
./nexus/scripts/nexus-reflect.sh retro
```

Then do three things:
1. **Review knowledge created this session** — are entries specific and actionable?
2. **Check for promotion candidates** — if a pattern appeared 3+ times, add to `conventions.md`
3. **Update MEMORY.md** — add session-level learnings (architecture insights, user preferences)

## Knowledge Lifecycle

1. **Created** — via post-commit prompt or manual entry (90-day expiry)
2. **Active** — returned in queries, shown in session-start dashboard
3. **Expiring** — flagged at session start within 7 days of expiry
4. **Promoted** — moved to `conventions.md` (permanent, no expiry)
5. **Expired** — cleaned up via `./nexus/scripts/nexus-knowledge.sh expire`

## Failure Taxonomy (unchanged from v0.2)

| Type | When to Use |
|---|---|
| timeout | Dispatch exceeded time limit |
| bad_spec | Task failed due to unclear requirements |
| env_missing | Missing tool/dependency in sandbox |
| test_flake | Tests pass sometimes, fail sometimes |
| review_reject | Reviewer found significant issues |
| crash | Non-zero exit with no useful output |
